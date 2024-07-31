//
//  File.swift
//  
//
//  Created by Stanislav Li on 1/8/24.
//

import Foundation

public extension Storage where Model: Hashable {
    func distinctUntilChanged() -> any Storage<Model> {
        return DistinctUntilChangedStorageDecorator(decoratee: self)
    }
}

public class DistinctUntilChangedStorageDecorator<Model: Hashable>: Storage {
    private let decoratee: any Storage<Model>
    private var observers = [UUID: Observer]()

    init(decoratee: any Storage<Model>) {
        self.decoratee = decoratee
        setupObserver()
    }

    private func setupObserver() {
        decoratee.addObserver(for: self) { [weak self] newValue in
            guard let self = self else { return }
            self.notifyObservers(with: newValue)
        }
    }

    private func notifyObservers(with value: Model?) {
        for observer in observers.values {
            observer(value)
        }
    }

    public func addObserver(for client: AnyObject, observer: @escaping ((Model?) -> Void)) {
        let id = UUID()
        observers[id] = observer
        observer(decoratee.get())
    }

    public func get() -> Model? {
        return decoratee.get()
    }

    public func set(model: Model?, completion: ((Bool) -> Void)?) {
        guard decoratee.get() != model else { return }
        decoratee.set(model: model, completion: completion)
    }

    public func clear(completion: ((Bool) -> Void)?) {
        decoratee.clear(completion: completion)
    }

    public func hash(into hasher: inout Hasher) {
        decoratee.hash(into: &hasher)
    }

    public static func == (lhs: DistinctUntilChangedStorageDecorator<Model>, rhs: DistinctUntilChangedStorageDecorator<Model>) -> Bool {
        return lhs.decoratee.get() == rhs.decoratee.get()
    }
}
