//
//  MoviesRepositoryInterfaces.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

protocol MoviesRepositoryDelegate: AnyObject {
    func didUpdateMovies(_ movies: [Movie])
}

protocol MoviesRepository: Delegatable where T == MoviesRepositoryDelegate {
    
    @discardableResult
    func fetchMoviesList(query: MovieQuery, page: Int,
                         cached: @escaping (MoviesPage) -> Void,
                         completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func markMovie(_ movie: Movie, isFavorite: Bool) -> Cancellable?
}
