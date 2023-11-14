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
    
    @discardableResult
    public func set(_ model: Model?) -> Bool {
        self.model = model
        return true
    }
    
    @discardableResult
    public func clear() -> Bool {
        model = nil
        return true
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
