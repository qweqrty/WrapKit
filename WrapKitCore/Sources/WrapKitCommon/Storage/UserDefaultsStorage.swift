//
//  UserDefaultsStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/12/23.
//

import Foundation

public class UserDefaultsStorage<Model: Codable>: Storage {
    private let notificationQueue = DispatchQueue(label: "com.userdefaults.storage.notificationQueue")
    private var observers = [ObserverWrapper]()
    private let key: String

    private var model: Model? {
        didSet {
            DispatchQueue.main.async {
                self.notifyObservers()
            }
        }
    }
    
    public init(key: String) {
        self.key = key
        if let data = UserDefaults.standard.data(forKey: key) {
            self.model = try? JSONDecoder().decode(Model.self, from: data)
        }
    }
    
    public func addObserver(for client: AnyObject, observer: @escaping Observer) {
        notificationQueue.async {
            let wrapper = ObserverWrapper(client: client, observer: observer)
            self.observers.append(wrapper)
            observer(self.model)
        }
    }
    
    public func get() -> Model? {
        return model
    }
    
    public func set(model: Model?, completion: ((Bool) -> Void)?) {
        notificationQueue.async {
            if let model = model {
                UserDefaults.standard.set(model, forKey: self.key)
            } else {
                UserDefaults.standard.removeObject(forKey: self.key)
            }
            DispatchQueue.main.async {
                self.model = model
                completion?(true)
            }
        }
    }

    public func clear(completion: ((Bool) -> Void)?) {
        set(model: nil, completion: completion)
    }
    
    private func notifyObservers() {
        notificationQueue.async {
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
