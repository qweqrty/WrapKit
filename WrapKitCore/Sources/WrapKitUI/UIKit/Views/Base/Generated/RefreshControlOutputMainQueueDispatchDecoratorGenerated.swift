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

extension RefreshControlOutput {
    public var mainQueueDispatched: any RefreshControlOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension RefreshControlOutput {
    public var weakReferenced: any RefreshControlOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: RefreshControlOutput where T: RefreshControlOutput {

    public func display(model: RefreshControlPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        dispatch { [weak self] in
            self?.decoratee.display(style: style)
        }
    }
    public func display(onRefresh: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onRefresh: onRefresh)
        }
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(appendingOnRefresh: appendingOnRefresh)
        }
    }
    public func display(isLoading: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isLoading: isLoading)
        }
    }

}

extension WeakRefVirtualProxy: RefreshControlOutput where T: RefreshControlOutput {

    public func display(model: RefreshControlPresentableModel?) {
        object?.display(model: model)
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        object?.display(style: style)
    }
    public func display(onRefresh: (() -> Void)?) {
        object?.display(onRefresh: onRefresh)
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        object?.display(appendingOnRefresh: appendingOnRefresh)
    }
    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }

}
#endif
