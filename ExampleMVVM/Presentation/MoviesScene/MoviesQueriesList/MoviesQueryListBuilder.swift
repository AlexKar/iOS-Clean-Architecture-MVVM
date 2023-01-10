//
//  MoviesQueryListBuilder.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 09.01.2023.
//

import ModernRIBs
import UIKit
import SwiftUI

protocol MoviesQueryListDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var moviesQueriesRepository: MoviesQueriesRepository { get }
}

final class MoviesQueryListComponent: Component<MoviesQueryListDependency> {
    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var moviesQueriesRepository: MoviesQueriesRepository {
        dependency.moviesQueriesRepository
    }
}

// MARK: - Builder

protocol MoviesQueryListBuildable: Buildable {
    func build(withListener listener: MoviesQueryListListener) -> MoviesQueryListRouting
}

final class MoviesQueryListBuilder: Builder<MoviesQueryListDependency>, MoviesQueryListBuildable {

    override init(dependency: MoviesQueryListDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MoviesQueryListListener) -> MoviesQueryListRouting {
        let component = MoviesQueryListComponent(dependency: dependency)

        let useCase = FetchRecentMovieQueriesUseCase(
            moviesQueriesRepository: component.moviesQueriesRepository
        )
        let viewModel = DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: 10,
            fetchRecentMovieQueriesUseCase: useCase
        )
        viewModel.listener = listener
        let viewController = makeMoviesViewController(viewModel: viewModel)

        return MoviesQueryListRouter(interactor: viewModel, viewController: viewController)
    }

    private func makeMoviesViewController(viewModel: MoviesQueryListViewModel) -> MoviesQueryListViewControllable {
        if #available(iOS 13.0, *) { // SwiftUI
            let viewModelWrapper = MoviesQueryListViewModelWrapper(viewModel: viewModel)
            let view = MoviesQueryListView(viewModelWrapper: viewModelWrapper)
            return MoviesQueriesHostingController(rootView: view)
        } else { // UIKit
            return MoviesQueriesTableViewController.create(with: viewModel)
        }
    }
    
}

class MoviesQueriesHostingController: UIHostingController<MoviesQueryListView>, MoviesQueryListViewControllable {

}
