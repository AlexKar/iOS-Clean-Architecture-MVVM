//
//  SearchMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22.02.19.
//

import Foundation

protocol SearchMoviesUseCaseDelegate: AnyObject {
    func didUpdateMovies(_ movies: [Movie])
}

protocol SearchMoviesUseCase: Delegatable where T == SearchMoviesUseCaseDelegate {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: DelegatesStorage<SearchMoviesUseCaseDelegate>, SearchMoviesUseCase {
    
    private let moviesRepository: any MoviesRepository
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(moviesRepository: any MoviesRepository,
         moviesQueriesRepository: MoviesQueriesRepository) {

        self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository
        
        super.init()
        
        self.moviesRepository.addDelegate(self)
    }
    
    deinit {
        self.moviesRepository.removeDelegate(self)
    }

    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 cached: @escaping (MoviesPage) -> Void,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {

        return moviesRepository.fetchMoviesList(query: requestValue.query,
                                                page: requestValue.page,
                                                cached: cached,
                                                completion: { result in

            if case .success = result {
                self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
            }

            completion(result)
        })
    }
    
}

extension DefaultSearchMoviesUseCase: MoviesRepositoryDelegate {
    func didUpdateMovies(_ movies: [Movie]) {
        notify(using: { $0.didUpdateMovies(movies) })
    }
}

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
