//
//  MovieDetailsBuilder.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 10.01.2023.
//

import ModernRIBs

protocol MovieDetailsDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var posterImagesRepository: DefaultPosterImagesRepository { get }
}

final class MovieDetailsComponent: Component<MovieDetailsDependency> {
    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var posterImagesRepository: DefaultPosterImagesRepository {
        dependency.posterImagesRepository
    }
}

// MARK: - Builder

protocol MovieDetailsBuildable: Buildable {
    func build(movie: Movie, withListener listener: MovieDetailsListener) -> MovieDetailsRouting
}

final class MovieDetailsBuilder: Builder<MovieDetailsDependency>, MovieDetailsBuildable {

    override init(dependency: MovieDetailsDependency) {
        super.init(dependency: dependency)
    }

    func build(movie: Movie, withListener listener: MovieDetailsListener) -> MovieDetailsRouting {
        let component = MovieDetailsComponent(dependency: dependency)
        let viewController = MovieDetailsViewController()

        let viewModel = DefaultMovieDetailsViewModel(
            movie: movie,
            posterImagesRepository: component.posterImagesRepository
        )
        viewModel.listener = listener
        return MovieDetailsRouter(interactor: viewModel, viewController: viewController)
    }
}
