// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

extension KeyValueFieldViewOutput {
    public var mainQueueDispatched: any KeyValueFieldViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension KeyValueFieldViewOutput {
    public var weakReferenced: any KeyValueFieldViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: KeyValueFieldViewOutput where T: KeyValueFieldViewOutput {

    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(keyTitle: keyTitle)
        }
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(valueTitle: valueTitle)
        }
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(bottomImage: bottomImage)
        }
    }

}

extension WeakRefVirtualProxy: KeyValueFieldViewOutput where T: KeyValueFieldViewOutput {

    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        object?.display(model: model)
    }
    public func display(keyTitle: TextOutputPresentableModel?) {
        object?.display(keyTitle: keyTitle)
    }
    public func display(valueTitle: TextOutputPresentableModel?) {
        object?.display(valueTitle: valueTitle)
    }
    public func display(bottomImage: ImageViewPresentableModel?) {
        object?.display(bottomImage: bottomImage)
    }

}

#endif
