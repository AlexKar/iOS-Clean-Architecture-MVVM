//
//  MovieDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import Foundation

protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
    func favoriteAction()
}

protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var isPosterImageHidden: Bool { get }
    var overview: String { get }
    var rating: String { get }
    var isRatingHidden: Bool { get }
    var isFavoriteIconHidden: Observable<Bool> { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private weak var listener: MoviesListListener?
    
    private let movieDetailsUseCase: any MovieDetailsUseCase
    private var movie: Movie
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

    // MARK: - OUTPUT
    let title: String
    let posterImage: Observable<Data?> = Observable(nil)
    let isPosterImageHidden: Bool
    let overview: String
    let isRatingHidden: Bool
    let rating: String
    let isFavoriteIconHidden: Observable<Bool>
    
    init(movie: Movie,
         listener: MoviesListListener,
         movieDetailsUseCase: any MovieDetailsUseCase,
         posterImagesRepository: PosterImagesRepository) {
        self.movie = movie
        self.listener = listener
        self.movieDetailsUseCase = movieDetailsUseCase
        
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.isPosterImageHidden = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
        self.rating = movie.voteAverage == nil ? "" : String(movie.voteAverage!)
        self.isRatingHidden = movie.voteAverage == nil
        self.isFavoriteIconHidden = Observable(!movie.isFavorite)
        
        self.movieDetailsUseCase.addDelegate(self)
    }
    
    deinit {
        self.movieDetailsUseCase.removeDelegate(self)
    }
    
    private func updateUI() {
        isFavoriteIconHidden.value = !movie.isFavorite
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }

        imageLoadTask = posterImagesRepository.fetchImage(with: posterImagePath, width: width) { result in
            guard self.posterImagePath == posterImagePath else { return }
            switch result {
            case .success(let data):
                self.posterImage.value = data
            case .failure: break
            }
            self.imageLoadTask = nil
        }
    }
    
    func favoriteAction() {
        let isFavorite = isFavoriteIconHidden.value
        movieDetailsUseCase.markMovie(movie, isFavorite: isFavorite)
    }
}

extension DefaultMovieDetailsViewModel: MovieDetailsUseCaseDelegate {
    func didUpdateMovies(_ movies: [Movie]) {
        guard let movie = movies.first(where: { $0.id == movie.id }) else { return }
        self.movie = movie
        updateUI()
    }
}
