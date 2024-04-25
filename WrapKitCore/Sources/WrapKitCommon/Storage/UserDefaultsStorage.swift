//
//  UserDefaultsStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/12/23.
//

import Foundation

public class UserDefaultsStorage<Model: Codable>: Storage {
    private let dispatchQueue: DispatchQueue
    private var observers = [ObserverWrapper]()
    private let key: String
    private let setLogic: ((UserDefaults, Model?) -> Void)
    private let getLogic: ((UserDefaults) -> Model?)

    private var model: Model? {
        didSet {
            DispatchQueue.main.async {
                self.notifyObservers()
            }
        }
    }
    
    private let userDefaults: UserDefaults

    public init(
        queue: DispatchQueue = DispatchQueue(label: "com.userdefaults.storage.notificationQueue"),
        userDefaults: UserDefaults = .standard,
        key: String,
        getLogic: @escaping ((UserDefaults) -> Model?),
        setLogic: @escaping ((UserDefaults, Model?) -> Void)
    ) {
        self.key = key
        self.userDefaults = userDefaults
        self.getLogic = getLogic
        self.setLogic = setLogic
        self.model = getLogic(userDefaults)
        self.dispatchQueue = queue
    }
    public func addObserver(for client: AnyObject, observer: @escaping UserDefaultsStorage.Observer) {
        dispatchQueue.async {
            let wrapper = ObserverWrapper(client: client, observer: observer)
            self.observers.append(wrapper)
            observer(self.model)
        }
    }
    
    public func get() -> Model? {
        return model
    }
    
    public func set(model: Model?, completion: ((Bool) -> Void)?) {
        dispatchQueue.async {
            do {
                if let model = model {
                    self.setLogic(self.userDefaults, model)
                } else {
                    self.userDefaults.removeObject(forKey: self.key)
                }
                self.userDefaults.synchronize()
                self.model = model
                completion?(true)
            }
        }
    }

    public func clear(completion: ((Bool) -> Void)?) {
        set(model: nil, completion: completion)
    }
    
    private func notifyObservers() {
        dispatchQueue.async {
            self.observers = self.observers.filter { $0.client != nil }
            let model = self.get()
            for observerWrapper in self.observers {
                observerWrapper.observer(model)
            }
        }
    }
    
    class ObserverWrapper {
        weak var client: AnyObject?
        let observer: Observer
        
        init(client: AnyObject, observer: @escaping Observer) {
            self.client = client
            self.observer = observer
        }
    }
}
