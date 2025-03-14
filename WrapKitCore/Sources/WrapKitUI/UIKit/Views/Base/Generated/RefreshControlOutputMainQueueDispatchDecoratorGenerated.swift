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

extension RefreshControlOutput {
    public var mainQueueDispatched: any RefreshControlOutput {
        MainQueueDispatchDecorator(decoratee: self)
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
#endif
