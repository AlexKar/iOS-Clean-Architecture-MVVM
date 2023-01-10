//
//  AppDelegate.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit
import ModernRIBs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var launchRouter: LaunchRouting?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppAppearance.setupAppearance()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        launchRouter = RootBuilder(dependency: AppComponent()).build()
        launchRouter?.launch(from: window)

        self.window = window
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStorage.shared.saveContext()
    }
}
