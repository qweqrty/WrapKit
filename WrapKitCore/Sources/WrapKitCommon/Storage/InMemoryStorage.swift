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

    private let lock = NSLock()
    private var model: Model?
    private let changes = CurrentValueSubject<Void, Never>(())

    public var publisher: AnyPublisher<Model?, Never> {
        changes
            .map { [self] in get() }
            .eraseToAnyPublisher()
    }

    public init(model: Model? = nil) {
        self.model = model
    }

    public func get() -> Model? {
        lock.lock()
        defer { lock.unlock() }
        return model
    }

    @discardableResult
    public func set(model: Model?) -> AnyPublisher<Bool, Never> {
        lock.lock()
        self.model = model
        lock.unlock()

        // Commit before returning success; only observer delivery is deferred.
        // Read current state when delivering so queued writes cannot replay an
        // older value after a later main-thread write or clear.
        if Thread.isMainThread {
            changes.send(())
        } else {
            DispatchQueue.main.async { [changes] in
                changes.send(())
            }
        }
        return Just(true).eraseToAnyPublisher()
    }
    
    @discardableResult
    public func clear() -> AnyPublisher<Bool, Never> {
        set(model: nil)
    }
    
    // Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(get())
    }

    public static func == (lhs: InMemoryStorage<Model>, rhs: InMemoryStorage<Model>) -> Bool {
        return lhs.get() == rhs.get()
    }
}
