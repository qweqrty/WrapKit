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

extension TitledOutput {
    public var mainQueueDispatched: any TitledOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension TitledOutput {
    public var weakReferenced: any TitledOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: TitledOutput where T: TitledOutput {

    public func display(model: TitledViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        dispatch { [weak self] in
            self?.decoratee.display(titles: titles)
        }
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        dispatch { [weak self] in
            self?.decoratee.display(bottomTitles: bottomTitles)
        }
    }
    public func display(isUserInteractionEnabled: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isUserInteractionEnabled: isUserInteractionEnabled)
        }
    }

}

extension WeakRefVirtualProxy: TitledOutput where T: TitledOutput {

    public func display(model: TitledViewPresentableModel?) {
        object?.display(model: model)
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        object?.display(titles: titles)
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        object?.display(bottomTitles: bottomTitles)
    }
    public func display(isUserInteractionEnabled: Bool) {
        object?.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

}

#endif
