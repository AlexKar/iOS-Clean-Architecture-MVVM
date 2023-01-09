//
//  MoviesQueryListItemViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.08.19.
//

import Foundation

class MoviesQueryListItemState: State {
    let query: String
    
    init(query: String) {
        self.query = query
    }
}

extension MoviesQueryListItemState: Equatable {
    static func == (lhs: MoviesQueryListItemState, rhs: MoviesQueryListItemState) -> Bool {
        return lhs.query == rhs.query
    }
}
