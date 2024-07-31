//
//  InMemoryStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation
import Combine

public class InMemoryStorage<Model: Hashable>: Storage {
    public static func == (lhs: InMemoryStorage<Model>, rhs: InMemoryStorage<Model>) -> Bool {
        return lhs.subject.value == rhs.subject.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subject.value)
    }
    
    private let subject: CurrentValueSubject<Model?, Never>
    
    public var publisher: AnyPublisher<Model?, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(model: Model? = nil) {
        subject = CurrentValueSubject<Model?, Never>(model)
    }
    
    public func get() -> Model? {
        return subject.value
    }
    
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        subject.send(model)
        return Just(true).eraseToAnyPublisher()
    }
}
