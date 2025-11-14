// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Combine)
import Combine
#endif
public class ExpandableCardViewOutputSwiftUIAdapter: ObservableObject, ExpandableCardViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: Pair<CardViewPresentableModel, CardViewPresentableModel?>
    }
    public func display(model: Pair<CardViewPresentableModel, CardViewPresentableModel?>) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil
    public struct DisplayIsHiddenState {
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        displayIsHiddenState = .init(
            isHidden: isHidden
        )
    }
}
