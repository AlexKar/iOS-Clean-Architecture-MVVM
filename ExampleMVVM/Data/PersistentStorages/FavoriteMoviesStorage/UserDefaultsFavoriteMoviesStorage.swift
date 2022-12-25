//
//  UserDefaultsFavoriteMoviesStorage.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 25.12.2022.
//

import Foundation

final class UserDefaultsFavoriteMoviesStorage {
    
    private enum Constants {
        static let UserDefaultsKey = "favoriteMoviesStorage"
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsFavoriteMoviesStorage: FavoriteMoviesStorage {
    
    func fetchFavoritesMoviesIds(completion: @escaping (Result<[String]?, Error>) -> Void) {
        completion(.success(userDefaults.object(forKey: Constants.UserDefaultsKey) as? [String]))
    }
    
    func saveFavoritesMoviesIds(_ ids: [String]?) {
        userDefaults.set(ids, forKey: Constants.UserDefaultsKey)
    }
    
    
}
