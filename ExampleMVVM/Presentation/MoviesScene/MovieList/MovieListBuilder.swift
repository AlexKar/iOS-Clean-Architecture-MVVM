//
//  MoviesListBuilder.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 09.01.2023.
//

import ModernRIBs

protocol MoviesListDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var moviesRepository: MoviesRepository { get }
    var moviesQueriesRepository: MoviesQueriesRepository { get }
    var posterImagesRepository: DefaultPosterImagesRepository { get }
}

final class MoviesListComponent: Component<MoviesListDependency> {
    var moviesRepository: MoviesRepository {
        dependency.moviesRepository
    }

    var moviesQueriesRepository: MoviesQueriesRepository {
        dependency.moviesQueriesRepository
    }
}

extension MoviesListComponent: MoviesQueryListDependency, MovieDetailsDependency {
    var posterImagesRepository: DefaultPosterImagesRepository {
        dependency.posterImagesRepository
    }
}

// MARK: - Builder

protocol MoviesListBuildable: Buildable {
    func build(withListener listener: MoviesListListener) -> MoviesListRouting
}

final class MoviesListBuilder: Builder<MoviesListDependency>, MoviesListBuildable {

    override init(dependency: MoviesListDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: MoviesListListener) -> MoviesListRouting {
        let component = MoviesListComponent(dependency: dependency)

        let searchMoviesUseCase = DefaultSearchMoviesUseCase(
            moviesRepository: dependency.moviesRepository,
            moviesQueriesRepository: dependency.moviesQueriesRepository
        )
        let viewModel = DefaultMoviesListViewModel(
            searchMoviesUseCase: searchMoviesUseCase
        )
        let viewController = MoviesListViewController.create(
            with: viewModel, posterImagesRepository: component.posterImagesRepository
        )
        let movieQueryListBuilder = MoviesQueryListBuilder(dependency: component)
        let movieDetailsBuilder = MovieDetailsBuilder(dependency: component)
        return MoviesListRouter(
            interactor: viewModel,
            viewController: viewController,
            movieQueryBuilder: movieQueryListBuilder,
            movieDetailsBuilder: movieDetailsBuilder
        )
    }
}
