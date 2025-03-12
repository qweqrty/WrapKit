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

extension LoadingOutput {
    public var mainQueueDispatched: any LoadingOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension LoadingOutput {
    public var weakReferenced: any LoadingOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: LoadingOutput where T: LoadingOutput {

    public func display(isLoading: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isLoading: isLoading)
        }
    }
    // Static methods cannot be generated for generic T. Implement this in specific types.

    public var isLoading: Bool? {
        get {
            return decoratee.isLoading          
        }
        set {
            decoratee.isLoading = newValue
        }
    }
}

extension WeakRefVirtualProxy: LoadingOutput where T: LoadingOutput {

    public func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
    // Static methods cannot be generated for generic T. Implement this in specific types.

    public var isLoading: Bool? {
        get { return object?.isLoading }
        set { object?.isLoading = newValue }
    }
}
#endif
