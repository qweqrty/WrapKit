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
    private let subject: CurrentValueSubject<Model?, Never>
    private let dispatchQueue: DispatchQueue

    public var publisher: AnyPublisher<Model?, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(
        key: String,
        keychain: Keychain,
        queue: DispatchQueue = DispatchQueue(label: "com.keychain.storage.notificationQueue")
    ) {
        self.key = key
        self.keychain = keychain
        self.dispatchQueue = queue
        
        if let value = keychain.get(key) {
            subject = CurrentValueSubject<Model?, Never>(value)
        } else {
            subject = CurrentValueSubject<Model?, Never>(nil)
        }
    }
    
    public func get() -> Model? {
        return subject.value
    }
    
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { [weak self] promise in
            let currentQueue = OperationQueue.current?.underlyingQueue ?? DispatchQueue.main
            self?.dispatchQueue.async {
                guard let self = self else {
                    currentQueue.async {
                        promise(.success(false))
                    }
                    return
                }
                if let model = model {
                    let isSuccess = self.keychain.set(model, forKey: self.key)
                    if isSuccess {
                        self.subject.send(model)
                    }
                    currentQueue.async {
                        promise(.success(isSuccess))
                    }
                } else {
                    let isSuccess = self.keychain.delete(self.key)
                    if isSuccess {
                        self.subject.send(nil)
                    }
                    currentQueue.async {
                        promise(.success(isSuccess))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
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
