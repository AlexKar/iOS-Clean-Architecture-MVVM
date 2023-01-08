//
//  MoviesSceneDIContainer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit
import SwiftUI

final class MoviesSceneDIContainer {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataMoviesQueriesStorage(maxStorageLimit: 10)
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()
    
    lazy var moviesRepository: any MoviesRepository = DefaultMoviesRepository(
        dataTransferService: dependencies.apiDataTransferService,
        cache: moviesResponseCache,
        favoritesCache: makeFavoriteMoviesStorage())
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies        
    }
    
    // MARK: - Use Cases
    func makeSearchMoviesUseCase() -> any SearchMoviesUseCase {
        return DefaultSearchMoviesUseCase(moviesRepository: moviesRepository,
                                          moviesQueriesRepository: makeMoviesQueriesRepository())
    }
    
    func makeFetchRecentMovieQueriesUseCase(requestValue: FetchRecentMovieQueriesUseCase.RequestValue,
                                            completion: @escaping (FetchRecentMovieQueriesUseCase.ResultValue) -> Void) -> UseCase {
        return FetchRecentMovieQueriesUseCase(requestValue: requestValue,
                                              completion: completion,
                                              moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    
    func makeMovieDetailsUseCase() -> any MovieDetailsUseCase {
        return DefaultMovieDetailsUseCase(moviesRepository: moviesRepository)
    }
    
    // MARK: - Repositories

    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        return DefaultMoviesQueriesRepository(dataTransferService: dependencies.apiDataTransferService,
                                              moviesQueriesPersistentStorage: moviesQueriesStorage)
    }
    func makePosterImagesRepository() -> PosterImagesRepository {
        return DefaultPosterImagesRepository(dataTransferService: dependencies.imageDataTransferService)
    }
    
    func makeFavoriteMoviesStorage() -> FavoriteMoviesStorage {
        return UserDefaultsFavoriteMoviesStorage()
    }
    
    // MARK: - Movies List
    func makeMoviesListViewController(actions: MoviesListIntentActions) -> MoviesListViewController {
        let intent = makeMoviesListIntent(actions: actions)
        let controller = MoviesListViewController.create(with: intent, posterImagesRepository: makePosterImagesRepository())
        intent.connect(to: controller)
        return controller
    }
    
    func makeMoviesListIntent(actions: MoviesListIntentActions) -> MoviesListIntent {
        MoviesListIntent(
            searchMoviesUseCase: makeSearchMoviesUseCase(),
            actions: actions
        )
        
    }
    
    // MARK: - Movie Details
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController {
        let intent = makeMoviesDetailsIntent(movie: movie)
        let view = MovieDetailsViewController.create(with: intent)
        intent.connect(to: view)
        return view
    }
    
    func makeMoviesDetailsIntent(movie: Movie) -> MovieDetailsIntent {
        return MovieDetailsIntent(movie: movie,
                                  movieDetailsUseCase: makeMovieDetailsUseCase(),
                                  posterImagesRepository: makePosterImagesRepository())
    }
    
    // MARK: - Movies Queries Suggestions List
    func makeMoviesQueriesSuggestionsListViewController(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> UIViewController {
        if #available(iOS 13.0, *) { // SwiftUI
            let view = MoviesQueryListView(viewModelWrapper: makeMoviesQueryListViewModelWrapper(didSelect: didSelect))
            return UIHostingController(rootView: view)
        } else { // UIKit
            return MoviesQueriesTableViewController.create(with: makeMoviesQueryListViewModel(didSelect: didSelect))
        }
    }
    
    func makeMoviesQueryListViewModel(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> MoviesQueryListViewModel {
        return DefaultMoviesQueryListViewModel(numberOfQueriesToShow: 10,
                                               fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase,
                                               didSelect: didSelect)
    }

    @available(iOS 13.0, *)
    func makeMoviesQueryListViewModelWrapper(didSelect: @escaping MoviesQueryListViewModelDidSelectAction) -> MoviesQueryListViewModelWrapper {
        return MoviesQueryListViewModelWrapper(viewModel: makeMoviesQueryListViewModel(didSelect: didSelect))
    }

    // MARK: - Flow Coordinators
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        return MoviesSearchFlowCoordinator(navigationController: navigationController,
                                           dependencies: self)
    }
}

extension MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies {}
