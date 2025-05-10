//
//  Storage+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 10/5/25.
//

import Foundation
import Combine

public extension Storage {
    func composed(primeStorage: any Storage<Model>) -> any Storage<Model> {
        return StorageComposition(primary: primeStorage, secondary: self)
    }
}

public class StorageComposition<Model>: Storage, Hashable {
    public typealias Model = Model
    
    private let subject: CurrentValueSubject<Model?, Never>
    public var publisher: AnyPublisher<Model?, Never> {
        subject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func get() -> Model? {
        return primary.get() ?? secondary.get()
    }
    
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        Publishers.Merge(primary.set(model: model), secondary.set(model: model))
            .eraseToAnyPublisher()
    }
    
    public func clear() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(primary.set(model: nil), secondary.set(model: nil))
            .eraseToAnyPublisher()
    }
    
    private let primary: any Storage<Model>
    private let secondary: any Storage<Model>
    
    public init(primary: any Storage<Model>, secondary: any Storage<Model>) {
        self.primary = primary
        self.secondary = secondary
        self.subject = CurrentValueSubject(nil)
    }
    
    // Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(primary)
        hasher.combine(secondary)
    }

    public static func == (lhs: StorageComposition<Model>, rhs: StorageComposition<Model>) -> Bool {
        return lhs == rhs
    }
}
