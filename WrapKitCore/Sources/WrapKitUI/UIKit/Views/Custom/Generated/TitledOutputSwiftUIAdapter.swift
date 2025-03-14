// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
public class TitledOutputSwiftUIAdapter: ObservableObject, TitledOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: TitledViewPresentableModel?
    }
    public func display(model: TitledViewPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayTitlesState: DisplayTitlesState? = nil
    public struct DisplayTitlesState {
        public let titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        displayTitlesState = .init(
            titles: titles
        )
    }
    @Published public var displayBottomTitlesState: DisplayBottomTitlesState? = nil
    public struct DisplayBottomTitlesState {
        public let bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        displayBottomTitlesState = .init(
            bottomTitles: bottomTitles
        )
    }
    @Published public var displayIsUserInteractionEnabledState: DisplayIsUserInteractionEnabledState? = nil
    public struct DisplayIsUserInteractionEnabledState {
        public let isUserInteractionEnabled: Bool
    }
    public func display(isUserInteractionEnabled: Bool) {
        displayIsUserInteractionEnabledState = .init(
            isUserInteractionEnabled: isUserInteractionEnabled
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
