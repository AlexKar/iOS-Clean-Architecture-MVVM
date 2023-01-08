//
//  MoviesListItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

final class MoviesListItemCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)
    
    public var posterImagesRepository: PosterImagesRepository?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var overviewLabel: UILabel!
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var isFavoriteLabel: UILabel!

    private var posterImagePath: String?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isFavoriteLabel.layer.cornerRadius = 8.0
        isFavoriteLabel.clipsToBounds = true
    }

    private func updatePosterImage(width: Int) {
        posterImageView.image = nil
        guard let posterImagePath = posterImagePath else { return }

        imageLoadTask = posterImagesRepository?.fetchImage(with: posterImagePath, width: width) { [weak self] result in
            guard let self = self else { return }
            guard self.posterImagePath == posterImagePath else { return }
            if case let .success(data) = result {
                self.posterImageView.image = UIImage(data: data)
            }
            self.imageLoadTask = nil
        }
    }
}

extension MoviesListItemCell: Viewable {
    func update(with state: MoviesListItemState) {
        titleLabel.text = state.title
        dateLabel.text = state.releaseDate
        overviewLabel.text = state.overview
        isFavoriteLabel.isHidden = !state.isFavorite
        
        posterImagePath = state.posterImagePath
        updatePosterImage(width: Int(posterImageView.imageSizeAfterAspectFit.scaledSize.width))
    }
}

