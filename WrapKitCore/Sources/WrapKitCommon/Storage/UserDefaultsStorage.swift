//
//  UserDefaultsStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/12/23.
//

import Combine
import Foundation

public class UserDefaultsStorage<Model: Codable & Hashable>: Storage {
    private let key: String
    private let userDefaults: UserDefaults
    private let getLogic: (UserDefaults) -> Model?
    private let setLogic: (UserDefaults, Model?) -> Void
    private let subject: CurrentValueSubject<Model?, Never>
    private let dispatchQueue: DispatchQueue
    
    public var publisher: AnyPublisher<Model?, Never> {
        subject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public init(
        key: String,
        userDefaults: UserDefaults = .standard,
        getLogic: @escaping (UserDefaults) -> Model?,
        setLogic: @escaping (UserDefaults, Model?) -> Void,
        queue: DispatchQueue = DispatchQueue(label: "com.userdefaults.storage.notificationQueue")
    ) {
        self.key = key
        self.userDefaults = userDefaults
        self.getLogic = getLogic
        self.setLogic = setLogic
        self.dispatchQueue = queue
        
        if let model = getLogic(userDefaults) {
            subject = CurrentValueSubject<Model?, Never>(model)
        } else {
            subject = CurrentValueSubject<Model?, Never>(nil)
        }
    }
    
    public func get() -> Model? {
        return getLogic(userDefaults)
    }
    
    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { [weak self] promise in
            if Thread.isMainThread {
                self?.handleSet(model: model, promise: promise)
            } else {
                self?.dispatchQueue.async {
                    self?.handleSet(model: model, promise: promise)
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    @discardableResult
    public func clear() -> AnyPublisher<Bool, Never> {
        set(model: nil)
    }

    private func handleSet(model: Model?, promise: @escaping (Result<Bool, Never>) -> Void) {
        setLogic(userDefaults, model)
        userDefaults.synchronize()
        
        subject.send(model)
        promise(.success(true))
    }
    
    // Conformance to Equatable
    public static func == (lhs: UserDefaultsStorage, rhs: UserDefaultsStorage) -> Bool {
        return lhs.key == rhs.key && lhs.get() == rhs.get()
    }
    
    // Conformance to Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(get())
    }
}
