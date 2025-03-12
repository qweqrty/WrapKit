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
#if canImport(Combine)
import Combine
#endif

extension ExpandableCardViewOutput {
    public var mainQueueDispatched: any ExpandableCardViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension ExpandableCardViewOutput {
    public var weakReferenced: any ExpandableCardViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: ExpandableCardViewOutput where T: ExpandableCardViewOutput {

    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }

}

extension WeakRefVirtualProxy: ExpandableCardViewOutput where T: ExpandableCardViewOutput {

    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        object?.display(model: model)
    }

}
#endif
