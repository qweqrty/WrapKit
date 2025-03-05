// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif

extension SelectionFlow {
    public var mainQueueDispatched: any SelectionFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension SelectionFlow {
    public var weakReferenced: any SelectionFlow {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: SelectionFlow where T: SelectionFlow {

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
        dispatch { [weak self] in
            self?.decoratee.close(with: result)
        }
    }

}

extension WeakRefVirtualProxy: SelectionFlow where T: SelectionFlow {

    public func showSelection(model: SelectionPresenterModel) {
        object?.showSelection(model: model)
    }
    public func showSelection<Request, Response>(model: ServicedSelectionModel<Request, Response>) {
        object?.showSelection(model: model)
    }
    public func close(with result: SelectionType?) {
        object?.close(with: result)
    }

}

#endif
