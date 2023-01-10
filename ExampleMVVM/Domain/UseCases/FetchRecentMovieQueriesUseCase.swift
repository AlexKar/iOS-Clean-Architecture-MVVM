//
//  FetchRecentMovieQueriesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 11.08.19.
//

import Foundation

// This is another option to create Use Case using more generic way
final class FetchRecentMovieQueriesUseCase {
    typealias ResultValue = (Result<[MovieQuery], Error>)

    private let moviesQueriesRepository: MoviesQueriesRepository

    init(moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (ResultValue) -> Void) {
        moviesQueriesRepository.fetchRecentsQueries(maxCount: maxCount, completion: completion)
    }
}
