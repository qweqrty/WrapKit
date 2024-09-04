//
//  InMemoryStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation
import Combine

public class InMemoryStorage<Model: Hashable>: Storage, Hashable {
    public typealias Model = Model

    private let subject: CurrentValueSubject<Model?, Never>
    public var publisher: AnyPublisher<Model?, Never> {
        subject.eraseToAnyPublisher()
    }

    public init(model: Model? = nil) {
        self.subject = CurrentValueSubject(model)
    }

    public func get() -> Model? {
        return subject.value
    }

    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        subject.send(model)
        return Just(true).eraseToAnyPublisher()
    }
    
    // Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subject.value)
    }

    public static func == (lhs: InMemoryStorage<Model>, rhs: InMemoryStorage<Model>) -> Bool {
        return lhs.subject.value == rhs.subject.value
    }
}
