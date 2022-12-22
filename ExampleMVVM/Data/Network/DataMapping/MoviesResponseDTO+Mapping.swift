//
//  MoviesResponseDTO+Mapping.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

// MARK: - Data Transfer Object

struct MoviesResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case movies = "results"
    }
    let page: Int
    let totalPages: Int
    let movies: [MovieDTO]
}

extension MoviesResponseDTO {
    struct MovieDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case genre
            case posterPath = "poster_path"
            case backdropPath = "backdrop_path"
            case overview
            case releaseDate = "release_date"
            case popularity
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
            case isFavorite = "is_favorite"
        }
        enum GenreDTO: String, Decodable {
            case adventure
            case scienceFiction = "science_fiction"
        }
        let id: Int
        let title: String?
        let genre: GenreDTO?
        let posterPath: String?
        let backdropPath: String?
        let overview: String?
        let releaseDate: String?
        let popularity: Float?
        let voteAverage: Float?
        let voteCount: Int?
        let isFavorite: Bool?
    }
}

// MARK: - Mappings to Domain

extension MoviesResponseDTO.MovieDTO {
    static func fromDomain(movie: Movie) -> Self? {
        guard let id = Int(movie.id) else {
            return nil
        }
        return MoviesResponseDTO.MovieDTO(
            id: id,
            title: movie.title,
            genre: .fromDomain(genre: movie.genre),
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            overview: movie.overview,
            releaseDate: movie.releaseDate != nil ? dateFormatter.string(from: movie.releaseDate!) : nil,
            popularity: movie.popularity,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            isFavorite: movie.isFavorite)
    }
}

extension MoviesResponseDTO.MovieDTO.GenreDTO {
    static func fromDomain(genre: Movie.Genre?) -> Self? {
        guard let genre = genre else { return nil }
        switch genre {
        case .adventure: return .adventure
        case .scienceFiction: return .scienceFiction
        }
    }
}

// MARK: - Mappings to Domain

extension MoviesResponseDTO {
    func toDomain() -> MoviesPage {
        return .init(page: page,
                     totalPages: totalPages,
                     movies: movies.map { $0.toDomain() })
    }
}

extension MoviesResponseDTO.MovieDTO {
    func toDomain() -> Movie {
        return .init(id: Movie.Identifier(id),
                     title: title,
                     genre: genre?.toDomain(),
                     posterPath: posterPath,
                     backdropPath: backdropPath,
                     overview: overview,
                     releaseDate: dateFormatter.date(from: releaseDate ?? ""),
                     popularity: popularity,
                     voteAverage: voteAverage,
                     voteCount: voteCount,
                     isFavorite: isFavorite ?? false)
    }
}

extension MoviesResponseDTO.MovieDTO.GenreDTO {
    func toDomain() -> Movie.Genre {
        switch self {
        case .adventure: return .adventure
        case .scienceFiction: return .scienceFiction
        }
    }
}

// MARK: - Private

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()
