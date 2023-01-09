//
//  MVI.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 07.01.2023.
//

import Foundation
import SwiftUI
import Combine

public protocol State: Equatable {}

public protocol Action {}

public protocol Viewable: AnyObject {
    associatedtype AssociatedState: State
    func update(with state: AssociatedState)
}

public protocol Actionable {
    func load()
    func dispatch(_ action: Action)
}

open class Intent<S: State, A: Action> {
    
    private let initialState: S
    private let stateHandler: StateHandler<S> = StateHandler()
    
    private var isLoaded = false
    
    public init(state: S) {
        initialState = state
    }
    
    public func connect<V: Viewable>(to view: V) where S == V.AssociatedState {
        stateHandler.bind(to: view)
    }
    
    public func update(state: S) {
        guard isLoaded else {
            return
        }
        stateHandler.accept(state)
    }
    
    open func dispatch(_ action: A) { }
}

extension Intent: Actionable {
    
    public func load() {
        guard isLoaded == false else {
            return
        }
        isLoaded = true
        update(state: initialState)
    }
    
    public func dispatch(_ action: Action) {
        guard isLoaded else {
            return
        }
        guard let action = action as? A else {
            return
        }
        dispatch(action)
    }
}

private final class StateHandler<S: State> {
    
    private var storage = Set<AnyCancellable>()
    private let subject = PassthroughSubject<S, Never>()


    func accept(_ state: S) {
        subject.send(state)
    }

    func bind<V: Viewable>(to view: V) where V.AssociatedState == S {
        subject.removeDuplicates().sink { [weak view] state in
            view?.update(with: state)
        }.store(in: &storage)
    }
}

/* --------- SwiftUI ------------ */

public protocol SUViewable: View {
    associatedtype AssotiatedIntent: Intentable
    var intent: AssotiatedIntent { get set }
}

public protocol Intentable: Actionable, ObservableObject {
    associatedtype AssociatedState: State
    var state: AssociatedState { get set  }
}

open class SUIntent<S: State, A: Action>: Intentable {
    
    @Published public var state: S
    
    public init(state: S) {
        self.state = state
    }
    
    open func dispatch(_ action: A) { }
    
    open func load() { }
    
    public func dispatch(_ action: Action) {
        guard let action = action as? A else {
            return
        }
        dispatch(action)
    }
}
