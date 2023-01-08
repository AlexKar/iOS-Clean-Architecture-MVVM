//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct MoviesListIntentActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListAction: Action {
    case loadNextPage
    case search(query: String)
    case cancelSearch
    case showQueriesSuggestions
    case closeQueriesSuggestions
    case selectItem(index: Int)
}

enum MoviesListLoadingState: State {
    case fullScreen
    case nextPage
}

struct MoviesListErrorState: State {
    let error: String
    let errorTitle: String
}

struct MoviesListTitlesState: State {
    let screenTitle: String
    let emptyDataTitle: String
    let searchBarPlaceholder: String
}

struct MoviesListState: State {
    let titles: MoviesListTitlesState
    let items: [MoviesListItemState]
    
    let query: String
    let loading: MoviesListLoadingState?
    let error: MoviesListErrorState?
}

final class MoviesListIntent: Intent<MoviesListState, MoviesListAction> {

    private let searchMoviesUseCase: any SearchMoviesUseCase
    private let actions: MoviesListIntentActions?
    
    private let titlesState: MoviesListTitlesState = {
        MoviesListTitlesState(
            screenTitle: NSLocalizedString("Movies", comment: ""),
            emptyDataTitle: NSLocalizedString("Search results", comment: ""),
            searchBarPlaceholder: NSLocalizedString("Search Movies", comment: "")
        )
    }()

    private var currentPage: Int = 0
    private var totalPageCount: Int = 1
    private var hasMorePages: Bool { currentPage < totalPageCount }
    private var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    private var pages: [Int:MoviesPage] = [:]
    private var movies: [String:Int] = [:]
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    
    private var items: [MoviesListItemState] = [] {
        didSet {
           update(state: state(withError: nil))
        }
    }
    private var loading: MoviesListLoadingState? = nil {
        didSet {
           update(state: state(withError: nil))
        }
    }
    private var query: String = "" {
        didSet {
           update(state: state(withError: nil))
        }
    }

    // MARK: - Init

    init(searchMoviesUseCase: any SearchMoviesUseCase,
         actions: MoviesListIntentActions? = nil) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
        
        let state = MoviesListState(
            titles: titlesState,
            items: items,
            query: query,
            loading: loading,
            error: nil
        )
        super.init(state: state)
        
        self.searchMoviesUseCase.addDelegate(self)
    }
    
    deinit {
        self.searchMoviesUseCase.removeDelegate(self)
    }
    
    // MARK: - Intent
    
    override func dispatch(_ action: MoviesListAction) {
        switch action {
        case .search(let query):
            didSearch(query: query)
        case .loadNextPage:
            didLoadNextPage()
        case .cancelSearch:
            didCancelSearch()
        case .showQueriesSuggestions:
            showQueriesSuggestions()
        case .closeQueriesSuggestions:
            closeQueriesSuggestions()
        case .selectItem(let index):
            didSelectItem(at: index)
        }
    }

    // MARK: - Private
    
    private func state(withError error: MoviesListErrorState?) -> MoviesListState {
        MoviesListState(
            titles: titlesState,
            items: items,
            query: query,
            loading: loading,
            error: error
        )
    }

    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages

        pages[moviesPage.page] = moviesPage
        moviesPage.movies.forEach { self.movies[$0.id] = moviesPage.page }

        updateMovieItems()
    }
    
    private func updateMovieItems() {
        items = pages.movies.map(MoviesListItemState.init)
    }

    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.removeAll()
    }

    private func load(movieQuery: MovieQuery, loading: MoviesListLoadingState) {
        self.loading = loading
        query = movieQuery.query

        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: appendPage,
            completion: { result in
                switch result {
                case .success(let page):
                    self.appendPage(page)
                case .failure(let error):
                    self.handle(error: error)
                }
                self.loading = nil
        })
    }

    private func handle(error: Error) {
        let message = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
        let errorState = MoviesListErrorState(error: message, errorTitle: NSLocalizedString("Error", comment: ""))
        update(state: state(withError: errorState))
    }

    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
}

// MARK: - Actions

extension MoviesListIntent {

    private func didLoadNextPage() {
        guard hasMorePages, loading == nil else { return }
        load(movieQuery: .init(query: query),
             loading: .nextPage)
    }

    private func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }

    func didCancelSearch() {
        moviesLoadTask?.cancel()
    }

    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions(update(movieQuery:))
    }

    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }

    func didSelectItem(at index: Int) {
        actions?.showMovieDetails(pages.movies[index])
    }
}

// MARK: - SearchMoviesUseCaseDelegate

extension MoviesListIntent : SearchMoviesUseCaseDelegate {
    
    func didUpdateMovies(_ movies: [Movie]) {
        movies.forEach { movie in
            guard let index = self.movies[movie.id], let page = self.pages[index] else { return }
            let modifiedMovies = page.movies.map { $0.id == movie.id ? movie : $0 }
            let modifiedPage = MoviesPage(page: page.page, totalPages: page.totalPages, movies: modifiedMovies)
            self.pages[page.page] = modifiedPage
        }
        updateMovieItems()
    }

}

// MARK: - Private

private extension Dictionary where Key == Int, Value == MoviesPage {
    var movies: [Movie] {
        let movies = self.keys.sorted().compactMap { self[$0]?.movies }
        return movies.flatMap { $0 }
    }
}
