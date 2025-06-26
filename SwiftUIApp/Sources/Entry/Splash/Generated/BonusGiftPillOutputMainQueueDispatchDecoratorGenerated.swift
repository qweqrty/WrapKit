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
    public var mainQueueDispatched: any BonusGiftPillOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: BonusGiftPillOutput where T: BonusGiftPillOutput {

    public func display(model: BonusGiftPillPresentableModel) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }

}
#endif
