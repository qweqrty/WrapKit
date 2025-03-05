// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(UIKit)
import UIKit
#endif

extension AlertOutput {
    public var mainQueueDispatched: any AlertOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension AlertOutput {
    public var weakReferenced: any AlertOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: AlertOutput where T: AlertOutput {

    public func showAlert(model: AlertPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.showAlert(model: model)
        }
    }
    public func showActionSheet(model: AlertPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.showActionSheet(model: model)
        }
    }

}

extension WeakRefVirtualProxy: AlertOutput where T: AlertOutput {

    public func showAlert(model: AlertPresentableModel?) {
        object?.showAlert(model: model)
    }
    public func showActionSheet(model: AlertPresentableModel?) {
        object?.showActionSheet(model: model)
    }

}

#endif
