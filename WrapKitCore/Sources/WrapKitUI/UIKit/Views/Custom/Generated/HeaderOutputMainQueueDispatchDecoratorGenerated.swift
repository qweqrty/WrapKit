// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

extension HeaderOutput {
    public var mainQueueDispatched: any HeaderOutput {
        MainQueueDispatchDecorator(decoratee: self)
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
    public func display(isHidden: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isHidden: isHidden)
        }
    }

}
#endif
