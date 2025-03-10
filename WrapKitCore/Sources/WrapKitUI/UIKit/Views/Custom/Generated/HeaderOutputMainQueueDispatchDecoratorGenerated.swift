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

extension HeaderOutput {
    public var mainQueueDispatched: any HeaderOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension HeaderOutput {
    public var weakReferenced: any HeaderOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension MainQueueDispatchDecorator: HeaderOutput where T: HeaderOutput {

    public func display(model: HeaderPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(style: HeaderPresentableModel.Style?) {
        dispatch { [weak self] in
            self?.decoratee.display(style: style)
        }
    }
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        dispatch { [weak self] in
            self?.decoratee.display(centerView: centerView)
        }
    }
    public func display(leadingCard: CardViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(leadingCard: leadingCard)
        }
    }
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(primeTrailingImage: primeTrailingImage)
        }
    }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(secondaryTrailingImage: secondaryTrailingImage)
        }
    }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(tertiaryTrailingImage: tertiaryTrailingImage)
        }
    }

}

extension WeakRefVirtualProxy: HeaderOutput where T: HeaderOutput {

    public func display(model: HeaderPresentableModel?) {
        object?.display(model: model)
    }
    public func display(style: HeaderPresentableModel.Style?) {
        object?.display(style: style)
    }
    public func display(centerView: HeaderPresentableModel.CenterView?) {
        object?.display(centerView: centerView)
    }
    public func display(leadingCard: CardViewPresentableModel?) {
        object?.display(leadingCard: leadingCard)
    }
    public func display(primeTrailingImage: ButtonPresentableModel?) {
        object?.display(primeTrailingImage: primeTrailingImage)
    }
    public func display(secondaryTrailingImage: ButtonPresentableModel?) {
        object?.display(secondaryTrailingImage: secondaryTrailingImage)
    }
    public func display(tertiaryTrailingImage: ButtonPresentableModel?) {
        object?.display(tertiaryTrailingImage: tertiaryTrailingImage)
    }

}

#endif
