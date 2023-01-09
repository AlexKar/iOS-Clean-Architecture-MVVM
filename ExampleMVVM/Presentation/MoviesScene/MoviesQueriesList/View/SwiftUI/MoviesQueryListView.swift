//
//  MoviesQueryListView.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import SwiftUI

extension MoviesQueryListItemState: Identifiable { }

struct MoviesQueryListView: SUViewable {

    @ObservedObject var intent: SUIntent<MoviesQueryListState, MoviesQueryListAction>
    
    var body: some View {
        List(intent.state.items) { item in
            Button(action: {
                self.intent.dispatch(.select(item: item))
            }) {
                Text(item.query)
            }
        }
        .onAppear {
            self.intent.load()
        }
    }
}

#if DEBUG
struct MoviesQueryListView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesQueryListView(intent: intent)
    }
    
    static var intent: SUIntent<MoviesQueryListState, MoviesQueryListAction> = {
        let items = [
            MoviesQueryListItemState(query: "item 1"),
            MoviesQueryListItemState(query: "item 2")
        ]
        return SUIntent<MoviesQueryListState, MoviesQueryListAction>(state: MoviesQueryListState(items: items))
    }()
}
#endif
