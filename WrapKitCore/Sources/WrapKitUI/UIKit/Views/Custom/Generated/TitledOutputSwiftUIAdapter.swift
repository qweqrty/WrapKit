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
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
public class TitledOutputSwiftUIAdapter: ObservableObject, TitledOutput {


    private var nextOutputSequence: UInt64 = 0



    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let outputSequence: UInt64
        public let model: TitledViewPresentableModel?
    }
    public func display(model: TitledViewPresentableModel?) {
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displayTitlesState: DisplayTitlesState? = nil
    public struct DisplayTitlesState {
        public let outputSequence: UInt64
        public let titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        nextOutputSequence &+= 1
        displayTitlesState = .init(
            outputSequence: nextOutputSequence,
            titles: titles
        )
    }
    @Published public var displayBottomTitlesState: DisplayBottomTitlesState? = nil
    public struct DisplayBottomTitlesState {
        public let outputSequence: UInt64
        public let bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>
    }
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        nextOutputSequence &+= 1
        displayBottomTitlesState = .init(
            outputSequence: nextOutputSequence,
            bottomTitles: bottomTitles
        )
    }
    @Published public var displayLeadingBottomTitleState: DisplayLeadingBottomTitleState? = nil
    public struct DisplayLeadingBottomTitleState {
        public let outputSequence: UInt64
        public let leadingBottomTitle: TextOutputPresentableModel?
    }
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        nextOutputSequence &+= 1
        displayLeadingBottomTitleState = .init(
            outputSequence: nextOutputSequence,
            leadingBottomTitle: leadingBottomTitle
        )
    }
    @Published public var displayTrailingBottomTitleState: DisplayTrailingBottomTitleState? = nil
    public struct DisplayTrailingBottomTitleState {
        public let outputSequence: UInt64
        public let trailingBottomTitle: TextOutputPresentableModel?
    }
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        nextOutputSequence &+= 1
        displayTrailingBottomTitleState = .init(
            outputSequence: nextOutputSequence,
            trailingBottomTitle: trailingBottomTitle
        )
    }
    @Published public var displayIsUserInteractionEnabledState: DisplayIsUserInteractionEnabledState? = nil
    public struct DisplayIsUserInteractionEnabledState {
        public let outputSequence: UInt64
        public let isUserInteractionEnabled: Bool
    }
    public func display(isUserInteractionEnabled: Bool) {
        nextOutputSequence &+= 1
        displayIsUserInteractionEnabledState = .init(
            outputSequence: nextOutputSequence,
            isUserInteractionEnabled: isUserInteractionEnabled
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil
    public struct DisplayIsHiddenState {
        public let outputSequence: UInt64
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        nextOutputSequence &+= 1
        displayIsHiddenState = .init(
            outputSequence: nextOutputSequence,
            isHidden: isHidden
        )
    }
}
