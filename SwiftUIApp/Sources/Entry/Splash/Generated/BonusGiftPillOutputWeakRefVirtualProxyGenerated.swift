// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(WrapKit)
import WrapKit
#endif

extension BonusGiftPillOutput {
    public var weakReferenced: any BonusGiftPillOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: BonusGiftPillOutput where T: BonusGiftPillOutput {

    public func display(model: BonusGiftPillPresentableModel) {
        object?.display(model: model)
    }

}
#endif
