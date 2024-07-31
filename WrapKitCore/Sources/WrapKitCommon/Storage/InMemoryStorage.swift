//
//  InMemoryStorage.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/23.
//

import Foundation
import Combine

public class InMemoryStorage<Model>: Storage & HashableWithReflection {
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

    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        subject.send(model)
        return Just(true).eraseToAnyPublisher()
    }

    public func clear() -> AnyPublisher<Bool, Never> {
        subject.send(nil)
        return Just(true).eraseToAnyPublisher()
    }
}
