//
//  RootRouter.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 10.01.2023.
//

import ModernRIBs

protocol RootInteractable: Interactable, MoviesListListener, MovieDetailsListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
    func showMovieList(_ viewController: ViewControllable)
    func showMovieDetails(_ viewController: ViewControllable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let moviesListBuilder: MoviesListBuildable
    private let movieDetailBuilder: MovieDetailsBuildable

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: RootInteractable,
        viewController: RootViewControllable,
        moviesListBuilder: MoviesListBuildable,
        movieDetailBuilder: MovieDetailsBuildable
    ) {
        self.moviesListBuilder = moviesListBuilder
        self.movieDetailBuilder = movieDetailBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()

        let moviesList = moviesListBuilder.build(withListener: interactor)
        attachChild(moviesList)

        viewController.showMovieList(moviesList.viewControllable)
    }

    func routeMovieDetails(_ movie: Movie) {
        let movieDetails = movieDetailBuilder.build(movie: movie, withListener: interactor)
        viewController.uiviewController.present(movieDetails.viewControllable.uiviewController, animated: true)
    }
}
