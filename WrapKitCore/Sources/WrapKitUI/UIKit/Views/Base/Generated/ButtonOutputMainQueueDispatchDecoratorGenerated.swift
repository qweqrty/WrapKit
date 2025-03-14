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

extension ButtonOutput {
    public var mainQueueDispatched: any ButtonOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: ButtonOutput where T: ButtonOutput {

    public func display(model: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(enabled: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(enabled: enabled)
        }
    }
    public func display(image: Image?) {
        dispatch { [weak self] in
            self?.decoratee.display(image: image)
        }
    }
    public func display(style: ButtonStyle?) {
        dispatch { [weak self] in
            self?.decoratee.display(style: style)
        }
    }
    public func display(title: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(title: title)
        }
    }
    public func display(spacing: CGFloat) {
        dispatch { [weak self] in
            self?.decoratee.display(spacing: spacing)
        }
    }
    public func display(onPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onPress: onPress)
        }
    }
    public func display(height: CGFloat) {
        dispatch { [weak self] in
            self?.decoratee.display(height: height)
        }
    }

}
#endif
