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

extension TextOutput {
    public var mainQueueDispatched: any TextOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension TextOutput {
    public var weakReferenced: any TextOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: TextOutput where T: TextOutput {

    public func display(model: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(text: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(text: text)
        }
    }
    public func display(attributes: [TextAttributes]) {
        dispatch { [weak self] in
            self?.decoratee.display(attributes: attributes)
        }
    }

}

extension WeakRefVirtualProxy: TextOutput where T: TextOutput {

    public func display(model: TextOutputPresentableModel?) {
        object?.display(model: model)
    }
    public func display(text: String?) {
        object?.display(text: text)
    }
    public func display(attributes: [TextAttributes]) {
        object?.display(attributes: attributes)
    }

}

#endif
