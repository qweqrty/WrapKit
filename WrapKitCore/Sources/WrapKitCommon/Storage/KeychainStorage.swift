//
//  KeychainStorage.swift
//  WrapKitAuth
//
//  Created by Stas Lee on 25/7/23.
//

import Foundation
import Combine

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
    private static let lock = NSLock()
    private static let changes = CurrentValueSubject<Void, Never>(())

    public var publisher: AnyPublisher<Model?, Never> {
        // Read persisted state on subscription and after successful writes by
        // any wrapper. An instance-local token would become stale after logout.
        Self.changes
            .map { [key, keychain] in Self.read(key: key, keychain: keychain) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public init(
        key: String,
        keychain: Keychain,
        queue: DispatchQueue = DispatchQueue(label: "com.keychain.storage.serialQueue")
    ) {
        self.key = key
        self.keychain = keychain
    }
    
    public func get() -> Model? {
        Self.read(key: key, keychain: keychain)
    }
    
    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        Self.lock.lock()
        let isSuccess = model.map { keychain.set($0, forKey: key) } ?? keychain.delete(key)
        Self.lock.unlock()

        // A subscriber can read or write storage. Never call it under the lock.
        if isSuccess {
            Self.changes.send(())
        }
        return Just(isSuccess).eraseToAnyPublisher()
    }
    
    @discardableResult
    public func clear() -> AnyPublisher<Bool, Never> {
        set(model: nil)
    }

    private static func read(key: String, keychain: Keychain) -> Model? {
        lock.lock()
        defer { lock.unlock() }
        return keychain.get(key)
    }
    
    // Conformance to Equatable
    public static func == (lhs: KeychainStorage, rhs: KeychainStorage) -> Bool {
        return lhs.key == rhs.key && lhs.get() == rhs.get()
    }
    
    // Conformance to Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(get())
    }
}
