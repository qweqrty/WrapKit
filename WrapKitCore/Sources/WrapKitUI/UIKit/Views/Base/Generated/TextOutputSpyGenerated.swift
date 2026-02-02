// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
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

public final class TextOutputSpy: TextOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayAccessibleModel(accessibleModel: AccessibleTextOutputPresentableModel?)
        case displayModel(model: TextOutputPresentableModel?)
        case displayText(text: String?)
        case displayAttributes(attributes: [TextAttributes])
        case displayHtmlString(htmlString: String?, font: Font, color: Color)
        case displayId(id: String?, from: Decimal, to: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayAccessibleModel: [AccessibleTextOutputPresentableModel?] = []
    public private(set) var capturedDisplayModel: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayText: [String?] = []
    public private(set) var capturedDisplayAttributes: [[TextAttributes]] = []
    public private(set) var capturedDisplayHtmlString: [(htmlString: String?, font: Font, color: Color)] = []
    public private(set) var capturedDisplayId: [(id: String?, from: Decimal, to: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?)] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - TextOutput methods
    public func display(accessibleModel: AccessibleTextOutputPresentableModel?) {
        capturedDisplayAccessibleModel.append(accessibleModel)
        messages.append(.displayAccessibleModel(accessibleModel: accessibleModel))
    }
    public func display(model: TextOutputPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(text: String?) {
        capturedDisplayText.append(text)
        messages.append(.displayText(text: text))
    }
    public func display(attributes: [TextAttributes]) {
        capturedDisplayAttributes.append(attributes)
        messages.append(.displayAttributes(attributes: attributes))
    }
    public func display(htmlString: String?, font: Font, color: Color) {
        capturedDisplayHtmlString.append((htmlString: htmlString, font: font, color: color))
        messages.append(.displayHtmlString(htmlString: htmlString, font: font, color: color))
    }
    public func display(id: String?, from startAmount: Decimal, to endAmount: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        capturedDisplayId.append((id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
        messages.append(.displayId(id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
