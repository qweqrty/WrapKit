//
//  InMemoryStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation
import Combine

public class InMemoryStorage<Model: Hashable>: Storage, Hashable {
    private let subject = CurrentValueSubject<Model?, Never>(nil)
    
    public var publisher: AnyPublisher<Model?, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    public typealias Observer = ((Model?) -> Void)
    
    private var model: Model? {
        didSet {
            notifyObservers()
        }
    }
    
    public func get() -> Model? {
        return model
    }
    
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
         self.model = model
         return Just(true).eraseToAnyPublisher()
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
    
    // Conformance to Equatable
    public static func == (lhs: InMemoryStorage<Model>, rhs: InMemoryStorage<Model>) -> Bool {
        return lhs.model == rhs.model
    }
    
    // Conformance to Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(model)
    }
}
