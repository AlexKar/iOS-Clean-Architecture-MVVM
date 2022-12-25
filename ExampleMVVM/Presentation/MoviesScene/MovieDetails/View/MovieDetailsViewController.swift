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

    private var viewModel: MovieDetailsViewModel!
    
    static func create(with viewModel: MovieDetailsViewModel) -> MovieDetailsViewController {
        let view = MovieDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
    }

    private func bind(to viewModel: MovieDetailsViewModel) {
        viewModel.posterImage.observe(on: self) { [weak self] in self?.posterImageView.image = $0.flatMap(UIImage.init) }
        viewModel.isFavoriteIconHidden.observe(on: self) { [weak self] in self?.updateIsFavoriteState($0) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }
    
    @IBAction func didPressFavoritesButton(_ sender: AnyObject) {
        viewModel.favoriteAction()
    }

    // MARK: - Private

    private func setupViews() {
        title = viewModel.title
        
        ratingLabel.clipsToBounds = true
        ratingLabel.layer.cornerRadius = 5.0
        ratingLabel.isHidden = viewModel.isRatingHidden
        ratingLabel.text = viewModel.rating
        
        overviewTextView.text = viewModel.overview
        posterImageView.isHidden = viewModel.isPosterImageHidden
        
        view.accessibilityIdentifier = AccessibilityIdentifier.movieDetailsView
    
    }
    
    private func updateIsFavoriteState(_ isHidden: Bool) {
        favoritesLabel.isHidden = isHidden
        
        let buttonTitle = !isHidden ? "Remove from favorites" : "Add to favorites"
        favoritesButton.setTitle(buttonTitle, for: .normal)
    }
}
