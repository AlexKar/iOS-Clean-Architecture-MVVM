//
//  MoviesListViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

final class MoviesListViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var moviesListContainer: UIView!
    @IBOutlet private(set) var suggestionsListContainer: UIView!
    @IBOutlet private var searchBarContainer: UIView!
    @IBOutlet private var emptyDataLabel: UILabel!
    
    private var actionsHandler: Actionable?
    private var posterImagesRepository: PosterImagesRepository?

    private var moviesTableViewController: MoviesListTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    static func create(with actionsHandler: Actionable,
                       posterImagesRepository: PosterImagesRepository?) -> MoviesListViewController {
        let view = MoviesListViewController.instantiateViewController()
        view.actionsHandler = actionsHandler
        view.posterImagesRepository = posterImagesRepository
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBehaviours()
        
        actionsHandler?.load()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: MoviesListTableViewController.self),
            let destinationVC = segue.destination as? MoviesListTableViewController {
            moviesTableViewController = destinationVC
            moviesTableViewController?.actionsHandler = actionsHandler
            moviesTableViewController?.posterImagesRepository = posterImagesRepository
        }
    }

    // MARK: - Private

    private func setupViews() {
        setupSearchController()
    }

    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }

    private func updateItems(_ items: [MoviesListItemState]) {
        guard self.moviesTableViewController?.items != items else { return }
        moviesTableViewController?.reload(withItems: items)
    }

    private func updateLoading(_ loading: MoviesListLoadingState?, isEmpty: Bool) {
        emptyDataLabel.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        LoadingView.hide()

        switch loading {
        case .fullScreen: LoadingView.show()
        case .nextPage: moviesListContainer.isHidden = false
        case .none:
            moviesListContainer.isHidden = isEmpty
            emptyDataLabel.isHidden = !isEmpty
        }

        moviesTableViewController?.updateLoading(loading)
        updateQueriesSuggestions()
    }

    private func updateQueriesSuggestions() {
        guard searchController.searchBar.isFirstResponder else {
            actionsHandler?.dispatch(MoviesListAction.closeQueriesSuggestions)
            return
        }
        actionsHandler?.dispatch(MoviesListAction.showQueriesSuggestions)
    }

    private func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    private func updateTitles(_ titles: MoviesListTitlesState) {
        title = titles.screenTitle
        emptyDataLabel.text = titles.emptyDataTitle
        searchController.searchBar.placeholder = titles.searchBarPlaceholder
    }

    private func showError(_ error: MoviesListErrorState?) {
        guard let error = error else { return }
        showAlert(title: error.errorTitle, message: error.error)
    }
}

extension MoviesListViewController: Viewable {
    
    func update(with state: MoviesListState) {
        updateTitles(state.titles)
        updateLoading(state.loading, isEmpty: state.items.isEmpty)
        showError(state.error)
        updateSearchQuery(state.query)
        updateItems(state.items)
    }
    
}

// MARK: - Search Controller

extension MoviesListViewController {
    
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth]
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
        }
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        actionsHandler?.dispatch(MoviesListAction.search(query: searchText))
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        actionsHandler?.dispatch(MoviesListAction.cancelSearch)
    }
}

extension MoviesListViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
}
