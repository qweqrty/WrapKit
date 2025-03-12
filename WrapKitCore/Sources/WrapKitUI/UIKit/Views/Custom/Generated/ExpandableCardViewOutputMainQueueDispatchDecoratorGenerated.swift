// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
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
#if canImport(Combine)
import Combine
#endif

extension ExpandableCardViewOutput {
    public var mainQueueDispatched: any ExpandableCardViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: ExpandableCardViewOutput where T: ExpandableCardViewOutput {

    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }

}
#endif
