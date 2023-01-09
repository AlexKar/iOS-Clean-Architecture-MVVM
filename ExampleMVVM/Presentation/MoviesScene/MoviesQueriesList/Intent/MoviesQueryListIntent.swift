//
//  MoviesQueryListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

typealias MoviesQueryListViewModelDidSelectAction = (MovieQuery) -> Void

enum MoviesQueryListAction: Action {
    case select(item: MoviesQueryListItemState)
}

struct MoviesQueryListState: State {
    let items: [MoviesQueryListItemState]
}

typealias FetchRecentMovieQueriesUseCaseFactory = (
    FetchRecentMovieQueriesUseCase.RequestValue,
    @escaping (FetchRecentMovieQueriesUseCase.ResultValue) -> Void
    ) -> UseCase


final class MoviesQueryListIntent: SUIntent<MoviesQueryListState, MoviesQueryListAction> {
    
    private let numberOfQueriesToShow: Int
    private let fetchRecentMovieQueriesUseCaseFactory: FetchRecentMovieQueriesUseCaseFactory
    private let didSelect: MoviesQueryListViewModelDidSelectAction?
        
    init(numberOfQueriesToShow: Int,
         fetchRecentMovieQueriesUseCaseFactory: @escaping FetchRecentMovieQueriesUseCaseFactory,
         didSelect: MoviesQueryListViewModelDidSelectAction? = nil) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchRecentMovieQueriesUseCaseFactory = fetchRecentMovieQueriesUseCaseFactory
        self.didSelect = didSelect
        
        super.init(state: MoviesQueryListState(items: []))
    }
    
    override func dispatch(_ action: MoviesQueryListAction) {
        switch action {
        case .select(let item):
            didSelect(item: item)
        }
    }
    
    override func load() {
        didLoad()
    }
}

extension MoviesQueryListIntent {
        
    private func didLoad() {
        let request = FetchRecentMovieQueriesUseCase.RequestValue(maxCount: numberOfQueriesToShow)
        let completion: (FetchRecentMovieQueriesUseCase.ResultValue) -> Void = { [weak self] result in
            switch result {
            case .success(let items):
                let items = items.map { $0.query }.map(MoviesQueryListItemState.init)
                self?.state = MoviesQueryListState(items: items)
            case .failure: break
            }
        }
        let useCase = fetchRecentMovieQueriesUseCaseFactory(request, completion)
        useCase.start()
    }
    
    private func didSelect(item: MoviesQueryListItemState) {
        didSelect?(MovieQuery(query: item.query))
    }
}
