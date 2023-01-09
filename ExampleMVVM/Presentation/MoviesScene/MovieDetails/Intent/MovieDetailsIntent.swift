//
//  MovieDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import Foundation

extension MovieDetailsState {
    init(movie: Movie, posterImage: Data?) {
        self.init(
            title: movie.title ?? "",
            posterImage: posterImage,
            overview: movie.overview ?? "",
            rating: movie.voteAverage == nil ? "" : String(movie.voteAverage!),
            isFavorite: movie.isFavorite
        )
    }
}

final class MovieDetailsIntent: Intent<MovieDetailsState, MovieDetailsAction>   {
    
    private let movieDetailsUseCase: any MovieDetailsUseCase
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private var posterImageData: Data?
    private var movie: Movie
    
    init(movie: Movie,
         movieDetailsUseCase: any MovieDetailsUseCase,
         posterImagesRepository: PosterImagesRepository) {
        self.movie = movie
        self.movieDetailsUseCase = movieDetailsUseCase
        self.posterImagesRepository = posterImagesRepository
        
        self.posterImagePath = movie.posterPath
        
        let state = MovieDetailsState(movie: movie, posterImage: nil)
        super.init(state: state)
        
        self.movieDetailsUseCase.addDelegate(self)
    }
    
    deinit {
        self.movieDetailsUseCase.removeDelegate(self)
    }
    
    override func dispatch(_ action: MovieDetailsAction) {
        super.dispatch(action)
        
        switch action {
        case .updatePosterImage(let width):
            updatePosterImage(width: width)
        case .favoriteButtonPressed:
            favoriteAction()
        }
    }

}

extension MovieDetailsIntent {
    
    private func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }

        imageLoadTask = posterImagesRepository.fetchImage(with: posterImagePath, width: width) { [weak self] result in
            guard let self = self else { return }
            guard self.posterImagePath == posterImagePath else { return }
            switch result {
            case .success(let data):
                self.posterImageData = data
                self.update()
            case .failure: break
            }
            self.imageLoadTask = nil
        }
    }
    
    private func favoriteAction() {
        let isFavorite = !movie.isFavorite
        movieDetailsUseCase.markMovie(movie, isFavorite: isFavorite)
    }
    
    private func update() {
        update(state: MovieDetailsState(movie: self.movie, posterImage: self.posterImageData))
    }
}

extension MovieDetailsIntent: MovieDetailsUseCaseDelegate {
    func didUpdateMovies(_ movies: [Movie]) {
        guard let movie = movies.first(where: { $0.id == movie.id }) else { return }
        self.movie = movie
        update()
    }
}
