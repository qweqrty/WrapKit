//
//  InMemoryStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation

public class InMemoryStorage<Model>: Storage {
    public typealias Observer = ((Model?) -> Void)
    
    private var model: Model? {
        didSet {
            notifyObservers()
        }
    }
    
    public func get() -> Model? {
        return model
    }
    
    public func set(model: Model?, completion: ((Bool) -> Void)?) {
        self.model = model
        completion?(true)
    }
    
    public func clear(completion: ((Bool) -> Void)?) {
        model = nil
        completion?(true)
    }
    
    class ObserverWrapper {
        weak var client: AnyObject?
        let observer: Observer
        
        init(client: AnyObject, observer: @escaping Observer) {
            self.client = client
            self.observer = observer
        }
    }
    
    private var observers = [ObserverWrapper]()
    
    public init(model: Model? = nil) {
        self.model = model
    }
    
    public func addObserver(for client: AnyObject, observer: @escaping Observer) {
        let wrapper = ObserverWrapper(client: client, observer: observer)
        wrapper.observer(model)
        observers.append(wrapper)
    }
    
    private func notifyObservers() {
        observers = observers.filter { $0.client != nil }
        for observerWrapper in observers {
            observerWrapper.observer(model)
        }
    }
}

