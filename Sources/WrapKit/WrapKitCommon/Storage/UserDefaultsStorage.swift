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
        subject.eraseToAnyPublisher()
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
        return subject.value
    }
    
    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { [weak self] promise in
            self?.dispatchQueue.async {
                guard let self = self else {
                    promise(.success(false))
                    return
                }
                self.setLogic(self.userDefaults, model)
                self.userDefaults.synchronize()
                self.subject.send(model)
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
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
