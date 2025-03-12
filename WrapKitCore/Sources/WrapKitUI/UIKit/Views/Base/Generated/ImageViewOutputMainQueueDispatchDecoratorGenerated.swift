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

extension ImageViewOutput {
    public var mainQueueDispatched: any ImageViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension ImageViewOutput {
    public var weakReferenced: any ImageViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: ImageViewOutput where T: ImageViewOutput {

    public func display(model: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(image: ImageEnum?) {
        dispatch { [weak self] in
            self?.decoratee.display(image: image)
        }
    }
    public func display(size: CGSize?) {
        dispatch { [weak self] in
            self?.decoratee.display(size: size)
        }
    }
    public func display(onPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onPress: onPress)
        }
    }
    public func display(onLongPress: (() -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onLongPress: onLongPress)
        }
    }
    public func display(contentModeIsFit: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(contentModeIsFit: contentModeIsFit)
        }
    }
    public func display(borderWidth: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(borderWidth: borderWidth)
        }
    }
    public func display(borderColor: Color?) {
        dispatch { [weak self] in
            self?.decoratee.display(borderColor: borderColor)
        }
    }
    public func display(cornerRadius: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(cornerRadius: cornerRadius)
        }
    }
    public func display(alpha: CGFloat?) {
        dispatch { [weak self] in
            self?.decoratee.display(alpha: alpha)
        }
    }

}

extension WeakRefVirtualProxy: ImageViewOutput where T: ImageViewOutput {

    public func display(model: ImageViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(image: ImageEnum?) {
        object?.display(image: image)
    }
    public func display(size: CGSize?) {
        object?.display(size: size)
    }
    public func display(onPress: (() -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(onLongPress: (() -> Void)?) {
        object?.display(onLongPress: onLongPress)
    }
    public func display(contentModeIsFit: Bool) {
        object?.display(contentModeIsFit: contentModeIsFit)
    }
    public func display(borderWidth: CGFloat?) {
        object?.display(borderWidth: borderWidth)
    }
    public func display(borderColor: Color?) {
        object?.display(borderColor: borderColor)
    }
    public func display(cornerRadius: CGFloat?) {
        object?.display(cornerRadius: cornerRadius)
    }
    public func display(alpha: CGFloat?) {
        object?.display(alpha: alpha)
    }

}
#endif
