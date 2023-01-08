//
//  MovieDetailsViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 04.08.19.
//  Copyright (c) 2019 All rights reserved.
//

import UIKit

final class MovieDetailsViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var ratingLabel: UILabel!
    @IBOutlet private var favoritesLabel: UILabel!
    @IBOutlet private var overviewTextView: UITextView!
    @IBOutlet private var favoritesButton: UIButton!

    // MARK: - Lifecycle

    private var actionsHandler: Actionable?
    
    static func create(with actionsHandler: Actionable) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.actionsHandler = actionsHandler
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        actionsHandler?.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionsHandler?.dispatch(MovieDetailsAction.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width)))
    }
    
    @IBAction func didPressFavoritesButton(_ sender: AnyObject) {
        actionsHandler?.dispatch(MovieDetailsAction.favoriteButtonPressed)
    }

    // MARK: - Private

    private func setupViews() {
        
        ratingLabel.clipsToBounds = true
        ratingLabel.layer.cornerRadius = 5.0
        
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    
    }
    
    private func updateIsFavoriteState(_ isHidden: Bool) {
        favoritesLabel.isHidden = isHidden
        
        let buttonTitle = !isHidden ? "Remove from favorites" : "Add to favorites"
        favoritesButton.setTitle(buttonTitle, for: .normal)
    }
}

extension MovieDetailsViewController: Viewable {
    
    func update(with state: MovieDetailsState) {
        
        title = state.title
        
        ratingLabel.isHidden = state.rating == nil
        ratingLabel.text = state.rating
        
        overviewTextView.text = state.overview
        
        if let data = state.posterImage {
            posterImageView.image = UIImage(data: data)
        }
        posterImageView.isHidden = state.posterImage == nil
        
        updateIsFavoriteState(!state.isFavorite)
    }
}
