//
//  RootBuilder.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 10.01.2023.
//

import Foundation
import ModernRIBs

protocol RootDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var appConfiguration: AppConfiguration { get }
}

final class RootComponent: Component<RootDependency> {
    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var appConfiguration: AppConfiguration {
        dependency.appConfiguration
    }

    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: appConfiguration.apiBaseURL)!,
            queryParameters: ["api_key": appConfiguration.apiKey,
            "language": NSLocale.preferredLanguages.first ?? "en"]
        )
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()

    lazy var imageDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.imagesBaseURL)!)
        let imagesDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: imagesDataNetwork)
    }()

    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataMoviesQueriesStorage(maxStorageLimit: 10)
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()

    lazy var moviesRepository: MoviesRepository = {
        DefaultMoviesRepository(dataTransferService: apiDataTransferService, cache: moviesResponseCache)
    }()

    lazy var moviesQueriesRepository: MoviesQueriesRepository = {
        DefaultMoviesQueriesRepository(dataTransferService: apiDataTransferService,
                                       moviesQueriesPersistentStorage: moviesQueriesStorage)
    }()

    lazy var posterImagesRepository: DefaultPosterImagesRepository = {
        DefaultPosterImagesRepository(dataTransferService: imageDataTransferService)
    }()
}

extension RootComponent: MoviesListDependency, MovieDetailsDependency {
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {

    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let component = RootComponent(dependency: dependency)
        let viewController = RootViewController()
        let interactor = RootInteractor(presenter: viewController)

        let moviesListBuilder = MoviesListBuilder(dependency: component)
        let movieDetailsBuilder = MovieDetailsBuilder(dependency: component)

        return RootRouter(
            interactor: interactor,
            viewController: viewController,
            moviesListBuilder: moviesListBuilder,
            movieDetailBuilder: movieDetailsBuilder
        )
    }
}
