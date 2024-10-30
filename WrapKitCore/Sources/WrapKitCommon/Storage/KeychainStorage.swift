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
        subject
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
        self.dispatchQueue = queue
        
        if let value = keychain.get(key) {
            subject = CurrentValueSubject<Model?, Never>(value)
        } else {
            subject = CurrentValueSubject<Model?, Never>(nil)
        }
    }
    
    public func get() -> Model? {
        subject.value
    }
    
    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { [weak self] promise in
            if Thread.isMainThread {
                self?.handleModelSetting(model: model, promise: promise)
            } else {
                self?.dispatchQueue.async {
                    self?.handleModelSetting(model: model, promise: promise)
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    @discardableResult
    public func clear() -> AnyPublisher<Bool, Never> {
        set(model: nil)
    }

    private func handleModelSetting(model: Model?, promise: @escaping (Result<Bool, Never>) -> Void) {
        let isSuccess: Bool
        
        if let model = model {
            isSuccess = self.keychain.set(model, forKey: self.key)
            if isSuccess {
                self.subject.send(model)
            }
        } else {
            isSuccess = self.keychain.delete(self.key)
            if isSuccess {
                self.subject.send(nil)
            }
        }
        
        promise(.success(isSuccess))
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
