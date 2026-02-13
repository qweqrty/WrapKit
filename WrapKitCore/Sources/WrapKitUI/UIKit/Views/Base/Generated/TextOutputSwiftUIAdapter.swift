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
#if canImport(SwiftUI)
import SwiftUI
#endif
public class TextOutputSwiftUIAdapter: ObservableObject, TextOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: TextOutputPresentableModel
    }
    public func display(model: TextOutputPresentableModel?) {
        guard let model else {
            display(isHidden: true)
            return
        }
        display(isHidden: false)
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayTextModelState: DisplayTextModelState? = nil
    public struct DisplayTextModelState {
        public let textModel: TextOutputPresentableModel.TextModel?
    }
    public func display(textModel: TextOutputPresentableModel.TextModel?) {
        displayTextModelState = .init(
            textModel: textModel
        )
    }
    @Published public var displayTextState: DisplayTextState? = nil
    public struct DisplayTextState {
        public let text: String
    }
    public func display(text: String?) {
        guard let text else {
            display(isHidden: true)
            return
        }
        display(isHidden: false)
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
    @Published public var displayHtmlStringFontColorState: DisplayHtmlStringFontColorState? = nil
    public struct DisplayHtmlStringFontColorState {
        public let htmlString: String?
        public let font: Font
        public let color: Color
    }
    public func display(htmlString: String?, font: Font, color: Color) {
        displayHtmlStringFontColorState = .init(
            htmlString: htmlString, 
            font: font, 
            color: color
        )
    }
    @Published public var displayIdStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState: DisplayIdStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState? = nil
    public struct DisplayIdStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState {
        public let id: String?
        public let startAmount: Decimal
        public let endAmount: Decimal
        public let mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?
        public let animationStyle: LabelAnimationStyle
        public let duration: TimeInterval
        public let completion: (() -> Void)?
    }
    public func display(id: String?, from startAmount: Decimal, to endAmount: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        displayIdStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState = .init(
            id: id, 
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
