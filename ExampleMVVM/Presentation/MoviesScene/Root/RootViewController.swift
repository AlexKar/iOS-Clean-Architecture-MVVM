//
//  RootViewController.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 10.01.2023.
//

import ModernRIBs
import UIKit
import SnapKit

protocol RootPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class RootViewController: UIViewController, RootPresentable, RootViewControllable {
    weak var listener: RootPresentableListener?


    func showMovieList(_ viewController: ViewControllable) {
        let movieList = viewController.uiviewController
        addChild(movieList)

        view.addSubview(movieList.view)
        movieList.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func showMovieDetails(_ viewController: ViewControllable) {
        present(viewController.uiviewController, animated: true)
    }
}
