//
//  Movie.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct Movie: Equatable, Identifiable {
    typealias Identifier = String
    enum Genre {
        case adventure
        case scienceFiction
    }
    let id: Identifier
    let title: String?
    let genre: Genre?
    let posterPath: String?
    let backdropPath: String?
    let overview: String?
    let releaseDate: Date?
    let popularity: Float?
    let voteAverage: Float?
    let voteCount: Int?
}

struct MoviesPage: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}
