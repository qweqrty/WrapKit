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

extension ButtonOutput {
    public var mainQueueDispatched: any ButtonOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension ButtonOutput {
    public var weakReferenced: any ButtonOutput {
        return WeakRefVirtualProxy(self)
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

extension WeakRefVirtualProxy: ButtonOutput where T: ButtonOutput {

    public func display(model: ButtonPresentableModel?) {
        object?.display(model: model)
    }
    public func display(enabled: Bool) {
        object?.display(enabled: enabled)
    }
    public func display(image: Image?) {
        object?.display(image: image)
    }
    public func display(style: ButtonStyle?) {
        object?.display(style: style)
    }
    public func display(title: String?) {
        object?.display(title: title)
    }
    public func display(spacing: CGFloat) {
        object?.display(spacing: spacing)
    }
    public func display(onPress: (() -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(height: CGFloat) {
        object?.display(height: height)
    }

}
#endif
