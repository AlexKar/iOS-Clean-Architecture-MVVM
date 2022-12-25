//
//  FavoriteMoviesStorage.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 25.12.2022.
//

import Foundation

protocol FavoriteMoviesStorage {
    func fetchFavoritesMoviesIds(completion: @escaping (Result<[String]?, Error>) -> Void)
    func saveFavoritesMoviesIds(_ ids: [String]?)
}
