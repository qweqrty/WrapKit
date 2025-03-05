// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

extension EntryFlow {
    public var mainQueueDispatched: any EntryFlow {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension EntryFlow {
    public var weakReferenced: any EntryFlow {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: EntryFlow where T: EntryFlow {

    public func showSplash() {
        dispatch { [weak self] in
            self?.decoratee.showSplash()
        }
    }

}

extension WeakRefVirtualProxy: EntryFlow where T: EntryFlow {

    public func showSplash() {
        object?.showSplash()
    }

}

#endif
