// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension DiffableDataSourceOutput {
    public var mainQueueDispatched: any DiffableDataSourceOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension DiffableDataSourceOutput {
    public var weakReferenced: any DiffableDataSourceOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: DiffableDataSourceOutput where T: DiffableDataSourceOutput {
    public typealias Model = T.Model
    public typealias SectionItem = T.SectionItem

    public func display(model: [DiffableTableViewDataSourcePresentableModel<Model>]) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(onRetry: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onRetry: onRetry)
        }
    }
    public func display(showLoader: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(showLoader: showLoader)
        }
    }
    public func display(loadNextPage: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(loadNextPage: loadNextPage)
        }
    }

}

extension WeakRefVirtualProxy: DiffableDataSourceOutput where T: DiffableDataSourceOutput {
    public typealias Model = T.Model
    public typealias SectionItem = T.SectionItem

    public func display(model: [DiffableTableViewDataSourcePresentableModel<Model>]) {
        object?.display(model: model)
    }
    public func display(onRetry: (() -> Void)?) {
        object?.display(onRetry: onRetry)
    }
    public func display(showLoader: Bool) {
        object?.display(showLoader: showLoader)
    }
    public func display(loadNextPage: (() -> Void)?) {
        object?.display(loadNextPage: loadNextPage)
    }

}

#endif
