//
//  DefaultMoviesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//
// **Note**: DTOs structs are mapped into Domains here, and Repository protocols does not contain DTOs

import Foundation

final class DefaultMoviesRepository: DelegatesStorage<MoviesRepositoryDelegate> {

    private let dataTransferService: DataTransferService
    private let cache: MoviesResponseStorage
    private let favoritesCache: FavoriteMoviesStorage

    init(
        dataTransferService: DataTransferService,
        cache: MoviesResponseStorage,
        favoritesCache: FavoriteMoviesStorage
    ) {
        self.dataTransferService = dataTransferService
        self.cache = cache
        self.favoritesCache = favoritesCache
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    public func fetchMoviesList(query: MovieQuery, page: Int,
                                cached: @escaping (MoviesPage) -> Void,
                                completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {

        let requestDTO = MoviesRequestDTO(query: query.query, page: page)
        let task = RepositoryTask()
        
        favoritesCache.fetchFavoritesMoviesIds { result in
            let favoriteMoviesIds = try? result.get()
            
            self.cache.getResponse(for: requestDTO) { result in
                if case let .success(responseDTO?) = result {
                    cached(responseDTO.toDomain(isFavoriteIds: favoriteMoviesIds))
                }
                guard !task.isCancelled else { return }

                let endpoint = APIEndpoints.getMovies(with: requestDTO)
                task.networkTask = self.dataTransferService.request(with: endpoint) { result in
                    switch result {
                    case .success(let responseDTO):
                        self.cache.save(response: responseDTO, for: requestDTO)
                        completion(.success(responseDTO.toDomain(isFavoriteIds: favoriteMoviesIds)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        return task
    }
    
    func markMovie(_ movie: Movie, isFavorite: Bool) -> Cancellable? {
        
        favoritesCache.fetchFavoritesMoviesIds { result in
            var favoritesMoviesIds = try? result.get() ?? []
            if isFavorite {
                favoritesMoviesIds?.append(movie.id)
            }
            else {
                favoritesMoviesIds?.removeAll(where: { $0 == movie.id })
            }
            self.favoritesCache.saveFavoritesMoviesIds(favoritesMoviesIds)
            
            let modifiedMovie = Movie(from: movie, isFavorite: isFavorite)
            self.notify(using: { (delegate: MoviesRepositoryDelegate) in
                delegate.didUpdateMovies([modifiedMovie])
            })
        }
        return nil
    }
}

extension Movie {
    init(from movie: Movie, isFavorite: Bool) {
        self.init(
            id: movie.id,
            title: movie.title,
            genre: movie.genre,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            overview: movie.overview,
            releaseDate: movie.releaseDate,
            popularity: movie.popularity,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            isFavorite: isFavorite
        )
    }
}
