// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class TextOutputSpy: TextOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: TextOutputPresentableModel?)
        case displayText(text: String?)
        case displayAttributes(attributes: [TextAttributes])
        case displayId(id: String?, from: Decimal, to: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayTextText: [String?] = []
    public private(set) var capturedDisplayAttributesAttributes: [[TextAttributes]] = []
    public private(set) var capturedDisplayIdId: [String?] = []
    public private(set) var capturedDisplayIdStartAmount: [Decimal] = []
    public private(set) var capturedDisplayIdEndAmount: [Decimal] = []
    public private(set) var capturedDisplayIdMapToString: [((Decimal) -> TextOutputPresentableModel)?] = []
    public private(set) var capturedDisplayIdAnimationStyle: [LabelAnimationStyle] = []
    public private(set) var capturedDisplayIdDuration: [TimeInterval] = []
    public private(set) var capturedDisplayIdCompletion: [(() -> Void)?] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - TextOutput methods
    public func display(model: TextOutputPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(text: String?) {
        capturedDisplayTextText.append(text)
        messages.append(.displayText(text: text))
    }
    public func display(attributes: [TextAttributes]) {
        capturedDisplayAttributesAttributes.append(attributes)
        messages.append(.displayAttributes(attributes: attributes))
    }
    public func display(id: String?, from startAmount: Decimal, to endAmount: Decimal, mapToString: ((Decimal) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        capturedDisplayIdId.append(id)
        capturedDisplayIdStartAmount.append(startAmount)
        capturedDisplayIdEndAmount.append(endAmount)
        capturedDisplayIdMapToString.append(mapToString)
        capturedDisplayIdAnimationStyle.append(animationStyle)
        capturedDisplayIdDuration.append(duration)
        capturedDisplayIdCompletion.append(completion)
        messages.append(.displayId(id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
