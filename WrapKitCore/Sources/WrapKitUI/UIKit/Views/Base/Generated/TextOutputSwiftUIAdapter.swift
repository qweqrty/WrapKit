// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
public class TextOutputSwiftUIAdapter: ObservableObject, TextOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: TextOutputPresentableModel?
    }
    public func display(model: TextOutputPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayTextState: DisplayTextState? = nil
    public struct DisplayTextState {
        public let text: String?
    }
    public func display(text: String?) {
        displayTextState = .init(
            text: text
        )
    }
    @Published public var displayAttributesState: DisplayAttributesState? = nil
    public struct DisplayAttributesState {
        public let attributes: [TextAttributes]
    }
    public func display(attributes: [TextAttributes]) {
        displayAttributesState = .init(
            attributes: attributes
        )
    }
    @Published public var displayStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState: DisplayStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState? = nil
    public struct DisplayStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState {
        public let startAmount: Float
        public let endAmount: Float
        public let mapToString: ((Float) -> TextOutputPresentableModel)?
        public let animationStyle: LabelAnimationStyle
        public let duration: TimeInterval
        public let completion: (() -> Void)?
    }
    public func display(from startAmount: Float, to endAmount: Float, mapToString: ((Float) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        displayStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState = .init(
            startAmount: startAmount, 
            endAmount: endAmount, 
            mapToString: mapToString, 
            animationStyle: animationStyle, 
            duration: duration, 
            completion: completion
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
