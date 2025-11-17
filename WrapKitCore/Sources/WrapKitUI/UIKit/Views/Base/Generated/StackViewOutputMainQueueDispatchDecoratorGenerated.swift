// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

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

extension MainQueueDispatchDecorator: StackViewOutput where T: StackViewOutput {

    public func display(model: StackViewPresentableModel) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
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
    public func display(isHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isHidden: isHidden)
        }
    }

}
#endif
