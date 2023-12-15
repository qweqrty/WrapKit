//
//  KeychainStorage.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation

public protocol Keychain {
    func get(_ key: String) -> String?
    func set(_ value: String, forKey key: String) -> Bool
    func delete(_ key: String) -> Bool
}

extension KeychainSwift: Keychain {
    public func set(_ value: String, forKey key: String) -> Bool {
        return set(value, forKey: key, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
    }
}

public class KeychainStorage: Storage {
    public typealias Model = String
    
    private let key: String
    private let keychain: Keychain
    private var observers = [ObserverWrapper]()
    private var model: Model? {
        didSet {
            notifyObservers()
        }
    }
    
    public init(key: String, keychain: Keychain) {
        self.key = key
        self.keychain = keychain
    }
    
    public func get() -> String? {
        return keychain.get(key)
    }
    
    public func set(model: String?, completion: ((Bool) -> Void)?) {
        let isSuccess = keychain.set(model ?? "", forKey: key)
        if isSuccess {
            self.model = model
        }
        completion?(isSuccess)
    }
    
    public func clear(completion: ((Bool) -> Void)?) {
        let isSuccess = keychain.delete(key)
        if isSuccess {
            model = nil
        }
        completion?(isSuccess)
    }

    
    class ObserverWrapper {
        weak var client: AnyObject?
        let observer: Observer
        
        init(client: AnyObject, observer: @escaping Observer) {
            self.client = client
            self.observer = observer
        }
    }
    
    public func addObserver(for client: AnyObject, observer: @escaping Observer) {
        let wrapper = ObserverWrapper(client: client, observer: observer)
        wrapper.observer(keychain.get(key))
        observers.append(wrapper)
    }
    
    private func notifyObservers() {
        observers = observers.filter { $0.client != nil }
        for observerWrapper in observers {
            observerWrapper.observer(keychain.get(key))
        }
    }
}
