//
//  MoviesListTableViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

final class MoviesListTableViewController: UITableViewController {

    private(set) var items: [MoviesListItemState] = []
    var actionsHandler: Actionable?

    var posterImagesRepository: PosterImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func reload(withItems items: [MoviesListItemState]) {
        self.items = items
        tableView.reloadData()
    }

    func updateLoading(_ loading: MoviesListLoadingState?) {
        switch loading {
        case .nextPage:
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        case .fullScreen, .none:
            tableView.tableFooterView = nil
        }
    }

    // MARK: - Private

    private func setupViews() {
        tableView.estimatedRowHeight = MoviesListItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension MoviesListTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviesListItemCell.reuseIdentifier,
                                                       for: indexPath) as? MoviesListItemCell else {
            assertionFailure("Cannot dequeue reusable cell \(MoviesListItemCell.self) with reuseIdentifier: \(MoviesListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }
        cell.posterImagesRepository = posterImagesRepository
        cell.update(with: items[indexPath.row])

        if indexPath.row == items.count - 1 {
            actionsHandler?.dispatch(MoviesListAction.loadNextPage)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items.isEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actionsHandler?.dispatch(MoviesListAction.selectItem(index: indexPath.row))
    }
}
