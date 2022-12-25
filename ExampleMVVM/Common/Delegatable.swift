//
//  Delegatable.swift
//  ExampleMVVM
//
//  Created by Alexander Karimov on 25.12.2022.
//

import Foundation

protocol Delegatable {
    
    associatedtype T
    
    func addDelegate(_ delegate: T)
    func removeDelegate(_ delegate: T)
    
    func notify(using block:@escaping (T)->Void)
}

class DelegatesStorage<T> {
    
    fileprivate class Wrapper {
        weak var delegate: AnyObject?
            
        init(_ delegate: AnyObject) {
            self.delegate = delegate
        }
    }
    
    fileprivate var wrappers: [Wrapper] = []
}


extension DelegatesStorage: Delegatable {
    
    func addDelegate(_ delegate: T) {
        let wrapper = Wrapper(delegate as AnyObject)
        wrappers.append(wrapper)
    }
    
    func removeDelegate(_ delegate: T) {
        guard let index = wrappers.firstIndex(where: { $0.delegate === (delegate as AnyObject) }) else { return }
        wrappers.remove(at: index)
    }
    
    func notify(using block: (T)->Void) {
        wrappers.forEach { wrapper in
            if let delegate = wrapper.delegate as? T {
                block(delegate)
            }
        }
    }
}
