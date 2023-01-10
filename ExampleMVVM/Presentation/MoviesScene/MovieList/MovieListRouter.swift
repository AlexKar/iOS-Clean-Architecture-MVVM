//
//  MoviesListRouter.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 09.01.2023.
//

import ModernRIBs

protocol MoviesListInteractable: Interactable, MoviesQueryListListener, MovieDetailsListener {
    var router: MoviesListRouting? { get set }
    var listener: MoviesListListener? { get set }
}

protocol MoviesListViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
    func presentMoviesQueriesSuggests(_ suggests: ViewControllable)
    func dismissMoviesQueriesSuggests(_ suggests: ViewControllable)
}

final class MoviesListRouter: ViewableRouter<MoviesListInteractable, MoviesListViewControllable>, MoviesListRouting {
    private let movieQueryBuilder: MoviesQueryListBuildable
    private let movieDetailsBuilder: MovieDetailsBuildable

    private weak var movieQuery: MoviesQueryListRouting?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: MoviesListInteractable,
        viewController: MoviesListViewControllable,
        movieQueryBuilder: MoviesQueryListBuildable,
        movieDetailsBuilder: MovieDetailsBuildable
    ) {
        self.movieQueryBuilder = movieQueryBuilder
        self.movieDetailsBuilder = movieDetailsBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - MoviesListRouting

    func showMovieQueriesSuggestions() {
//        guard let moviesListViewController = moviesListVC, moviesQueriesSuggestionsVC == nil,
//              let container = moviesListViewController.suggestionsListContainer else { return }
//
//        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(didSelect: didSelect)
//
//        moviesListViewController.add(child: vc, container: container)
//        moviesQueriesSuggestionsVC = vc
//        container.isHidden = false

        let movieQuery = movieQueryBuilder.build(withListener: interactor)
        attachChild(movieQuery)

        viewController.presentMoviesQueriesSuggests(movieQuery.viewControllable)
    }

    func closeMovieQueriesSuggestions() {
//        moviesQueriesSuggestionsVC?.remove()
//        moviesQueriesSuggestionsVC = nil
//        moviesListVC?.suggestionsListContainer.isHidden = true
        guard let movieQuery = movieQuery else {
            return
        }
        detachChild(movieQuery)
        viewController.dismissMoviesQueriesSuggests(movieQuery.viewControllable)

        self.movieQuery = nil
    }
}
