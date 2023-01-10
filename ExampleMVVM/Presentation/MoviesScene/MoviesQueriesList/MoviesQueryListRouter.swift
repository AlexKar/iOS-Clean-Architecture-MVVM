//
//  MoviesQueryListRouter.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 09.01.2023.
//

import ModernRIBs

protocol MoviesQueryListInteractable: Interactable {
    var router: MoviesQueryListRouting? { get set }
    var listener: MoviesQueryListListener? { get set }
}

protocol MoviesQueryListViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MoviesQueryListRouter: ViewableRouter<MoviesQueryListInteractable, MoviesQueryListViewControllable>, MoviesQueryListRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: MoviesQueryListInteractable, viewController: MoviesQueryListViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
