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
        case display(model: TextOutputPresentableModel?)
        case display(text: String?)
        case display(attributes: [TextAttributes])
        case display(id: String?, from: Double, to: Double, mapToString: ((Double) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?)
        case display(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [TextOutputPresentableModel?] = []
    public private(set) var capturedDisplayText: [String?] = []
    public private(set) var capturedDisplayAttributes: [[TextAttributes]] = []
    public private(set) var capturedDisplayId: [String?] = []
    public private(set) var capturedDisplayStartAmount: [Double] = []
    public private(set) var capturedDisplayEndAmount: [Double] = []
    public private(set) var capturedDisplayMapToString: [((Double) -> TextOutputPresentableModel)?] = []
    public private(set) var capturedDisplayAnimationStyle: [LabelAnimationStyle] = []
    public private(set) var capturedDisplayDuration: [TimeInterval] = []
    public private(set) var capturedDisplayCompletion: [(() -> Void)?] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - TextOutput methods
    public func display(model: TextOutputPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(text: String?) {
        capturedDisplayText.append(text)
        messages.append(.display(text: text))
    }
    public func display(attributes: [TextAttributes]) {
        capturedDisplayAttributes.append(attributes)
        messages.append(.display(attributes: attributes))
    }
    public func display(id: String?, from startAmount: Double, to endAmount: Double, mapToString: ((Double) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        capturedDisplayId.append(id)
        capturedDisplayStartAmount.append(startAmount)
        capturedDisplayEndAmount.append(endAmount)
        capturedDisplayMapToString.append(mapToString)
        capturedDisplayAnimationStyle.append(animationStyle)
        capturedDisplayDuration.append(duration)
        capturedDisplayCompletion.append(completion)
        messages.append(.display(id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
