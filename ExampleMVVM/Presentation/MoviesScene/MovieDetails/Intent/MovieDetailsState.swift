//
//  MovieDetailsState.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 09.01.2023.
//

import Foundation

struct MovieDetailsState: State {
    let title: String
    let posterImage: Data?
    let overview: String
    let rating: String?
    var isFavorite: Bool
}

enum MovieDetailsAction: Action {
    case updatePosterImage(width: Int)
    case favoriteButtonPressed
}
