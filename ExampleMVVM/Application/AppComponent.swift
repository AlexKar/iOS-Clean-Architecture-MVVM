//
//  AppComponent.swift
//  ExampleMVVM
//
//  Created by Sergey Ilyushin on 10.01.2023.
//

import ModernRIBs

class AppComponent: Component<EmptyDependency>, RootDependency {
    lazy var appConfiguration = AppConfiguration()
    
    init() {
        super.init(dependency: EmptyComponent())
    }
}
