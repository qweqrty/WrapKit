//
//  MainQueueDispatchDecorator.swift
//  WrapKitTests
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public final class MainQueueDispatchDecorator<T> {
    public private(set) var decoratee: T
    
    public init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    public func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: SelectionFlow where T == SelectionFlow {
    public func showSelection(model: SelectionPresenterModel) {
        dispatch { [weak self] in
            self?.decoratee.showSelection(model: model)
        }
    }
    
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        dispatch { [weak self] in
            self?.decoratee.showSelection(model: model)
        }
    }
    
    public func close(with result: SelectionType?) {
        dispatch { [weak self, result] in
            self?.decoratee.close(with: result)
        }
    }
}

extension SelectionFlow {
    public var mainQueueDispatched: SelectionFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}
