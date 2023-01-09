//
//  ExampleMVVMScreenShotsTests.swift
//  ExampleMVVMScreenShotsTests
//
//  Created by Alexander Karimov on 09.01.2023.
//

import XCTest
import iOSSnapshotTestCase
import UIKit

final class ExampleMVVMScreenShotsTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testMovieDetailsScreen() {
        let state = MovieDetailsState(
            title: "test",
            posterImage: nil,
            overview: "Overview",
            rating: "8.9",
            isFavorite: true
        )
        let view = view(withState: state)
        FBSnapshotVerifyView(view)
    }
    
    private func view(withState state: MovieDetailsState) -> UIView {
        let controller = MovieDetailsViewController.instantiateViewController(Bundle(for: type(of: self)))
        controller.loadView()
        let view = controller.view!
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        controller.update(with: state)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        return view
    }
}
