//
//  MovieDetailsUseCase.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 21.12.2022.
//

import Foundation

protocol MovieDetailsUseCaseDelegate: AnyObject {
    func didUpdateMovies(_ movies: [Movie])
}

protocol MovieDetailsUseCase: Delegatable where T == MovieDetailsUseCaseDelegate {
    func markMovie(_ movie: Movie, isFavorite: Bool)
}

final class DefaultMovieDetailsUseCase: DelegatesStorage<MovieDetailsUseCaseDelegate>, MovieDetailsUseCase {
    
    private let moviesRepository: any MoviesRepository

    init(moviesRepository: any MoviesRepository) {
        self.moviesRepository = moviesRepository
        
        super.init()
        self.moviesRepository.addDelegate(self)
    }
    
    deinit {
        self.moviesRepository.removeDelegate(self)
    }
    
    // MARK: - MovieDetailsUseCase
    
    func markMovie(_ movie: Movie, isFavorite: Bool) {
        moviesRepository.markMovie(movie, isFavorite: isFavorite)
    }
}

extension DefaultMovieDetailsUseCase: MoviesRepositoryDelegate {
    func didUpdateMovies(_ movies: [Movie]) {
        notify(using: { $0.didUpdateMovies(movies) })
    }
}
