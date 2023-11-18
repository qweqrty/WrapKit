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

    public init(key: String, keychain: Keychain) {
        self.key = key
        self.keychain = keychain
    }
    
    public func get() -> Model? {
        let value = keychain.get(key)
        guard let value = value else { return nil }
        return value.isEmpty ? nil : value
    }
    
    @discardableResult
    public func set(_ model: Model?) -> Bool {
        let isSuccess = keychain.set(model ?? "", forKey: key)
        if isSuccess {
            notifyObservers()
        }
        return isSuccess
    }

    @discardableResult
    public func clear() -> Bool {
        let isSuccess = keychain.delete(key)
        if isSuccess {
            notifyObservers()
        }
        return isSuccess
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
