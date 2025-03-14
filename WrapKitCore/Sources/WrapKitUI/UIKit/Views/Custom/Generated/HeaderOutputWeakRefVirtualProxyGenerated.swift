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

extension HeaderOutput {
    public var weakReferenced: any HeaderOutput {
        return WeakRefVirtualProxy(self)
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
