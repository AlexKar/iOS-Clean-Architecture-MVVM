//
//  MoviesQueryListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation
import ModernRIBs

protocol MoviesQueryListRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol MoviesQueryListListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func didSelectMovie(_ query: MovieQuery)
}

protocol MoviesQueryListViewModelInput {
    func didSelect(item: MoviesQueryListItemViewModel)
}

protocol MoviesQueryListViewModelOutput {
    var items: Observable<[MoviesQueryListItemViewModel]> { get }
}

protocol MoviesQueryListViewModel: MoviesQueryListInteractable, MoviesQueryListViewModelInput, MoviesQueryListViewModelOutput { }

final class DefaultMoviesQueryListViewModel: Interactor, MoviesQueryListViewModel {
    weak var router: MoviesQueryListRouting?
    weak var listener: MoviesQueryListListener?

    private let numberOfQueriesToShow: Int
    private let fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase
    
    // MARK: - OUTPUT
    let items: Observable<[MoviesQueryListItemViewModel]> = Observable([])
    
    init(
        numberOfQueriesToShow: Int,
        fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase
    ) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchRecentMovieQueriesUseCase = fetchRecentMovieQueriesUseCase
    }

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        updateMoviesQueries()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    // MARK: Private methods

    private func updateMoviesQueries() {
        let completion: (FetchRecentMovieQueriesUseCase.ResultValue) -> Void = { result in
            switch result {
            case .success(let items):
                self.items.value = items.map { $0.query }.map(MoviesQueryListItemViewModel.init)
            case .failure: break
            }
        }
        fetchRecentMovieQueriesUseCase.fetchRecentsQueries(maxCount: numberOfQueriesToShow, completion: completion)
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesQueryListViewModel {
    func didSelect(item: MoviesQueryListItemViewModel) {
        listener?.didSelectMovie(MovieQuery(query: item.query))
    }
}
