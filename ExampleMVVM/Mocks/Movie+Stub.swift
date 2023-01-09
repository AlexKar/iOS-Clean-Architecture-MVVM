//
//  Movie+Stub.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 17/03/2020.
//

import Foundation

extension Movie {
    static func stub(
        id: Movie.Identifier = "id1",
        title: String = "title1" ,
        genre: Movie.Genre = .adventure,
        posterPath: String? = "/1",
        backdropPath: String? = "/1",
        overview: String = "overview1",
        releaseDate: Date? = nil,
        popularity: Float? = 8.0,
        voteAverage: Float? = 3.0,
        voteCount: Int? = 10,
        isFavorite: Bool = false) -> Self {
        Movie(
            id: id,
            title: title,
            genre: genre,
            posterPath: posterPath,
            backdropPath: backdropPath,
            overview: overview,
            releaseDate: releaseDate,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount,
            isFavorite: isFavorite
        )
    }
}
