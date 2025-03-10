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

extension StackViewOutput {
    public var mainQueueDispatched: any StackViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension StackViewOutput {
    public var weakReferenced: any StackViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: StackViewOutput where T: StackViewOutput {

    public func display(model: StackViewPresentableModel) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(views: [UIView]) {
        dispatch { [weak self] in
            self?.decoratee.display(views: views)
        }
    }
    public func display(spacing: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(spacing: spacing)
        }
    }
    public func display(axis: StackViewAxis) {
        dispatch { [weak self] in
            self?.decoratee.display(axis: axis)
        }
    }
    public func display(distribution: StackViewDistribution) {
        dispatch { [weak self] in
            self?.decoratee.display(distribution: distribution)
        }
    }
    public func display(alignment: StackViewAlignment) {
        dispatch { [weak self] in
            self?.decoratee.display(alignment: alignment)
        }
    }
    public func display(layoutMargins: EdgeInsets) {
        dispatch { [weak self] in
            self?.decoratee.display(layoutMargins: layoutMargins)
        }
    }

}

extension WeakRefVirtualProxy: StackViewOutput where T: StackViewOutput {

    public func display(model: StackViewPresentableModel) {
        object?.display(model: model)
    }
    public func display(views: [UIView]) {
        object?.display(views: views)
    }
    public func display(spacing: CGFloat?) {
        object?.display(spacing: spacing)
    }
    public func display(axis: StackViewAxis) {
        object?.display(axis: axis)
    }
    public func display(distribution: StackViewDistribution) {
        object?.display(distribution: distribution)
    }
    public func display(alignment: StackViewAlignment) {
        object?.display(alignment: alignment)
    }
    public func display(layoutMargins: EdgeInsets) {
        object?.display(layoutMargins: layoutMargins)
    }

}

#endif
