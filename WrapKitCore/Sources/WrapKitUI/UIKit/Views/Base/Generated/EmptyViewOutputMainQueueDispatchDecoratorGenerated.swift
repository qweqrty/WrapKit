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

extension EmptyViewOutput {
    public var mainQueueDispatched: any EmptyViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension EmptyViewOutput {
    public var weakReferenced: any EmptyViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: EmptyViewOutput where T: EmptyViewOutput {

    public func display(model: EmptyViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(title: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(title: title)
        }
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(subtitle: subtitle)
        }
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(buttonModel: buttonModel)
        }
    }
    public func display(image: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(image: image)
        }
    }

}

extension WeakRefVirtualProxy: EmptyViewOutput where T: EmptyViewOutput {

    public func display(model: EmptyViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(title: TextOutputPresentableModel?) {
        object?.display(title: title)
    }
    public func display(subtitle: TextOutputPresentableModel?) {
        object?.display(subtitle: subtitle)
    }
    public func display(buttonModel: ButtonPresentableModel?) {
        object?.display(buttonModel: buttonModel)
    }
    public func display(image: ImageViewPresentableModel?) {
        object?.display(image: image)
    }

}

#endif
