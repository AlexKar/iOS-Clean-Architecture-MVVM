//
//  MovieDetailsUseCase.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 21.12.2022.
//

import Foundation

protocol MovieDetailsUseCase {
    func updateMovie(_ movie: Movie)
}

final class DefaultMovieDetailsUseCase: MovieDetailsUseCase {
    
    private let moviesRepository: MoviesRepository

    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    // MARK: - MovieDetailsUseCase
    
    func updateMovie(_ movie: Movie) {
        moviesRepository.updateMovie(movie)
    }
}
