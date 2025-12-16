// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

final class TextOutputSpy: TextOutput {
    enum Message: HashableWithReflection {
        case display(model: TextOutputPresentableModel?)
        case display(text: String?)
        case display(attributes: [TextAttributes])
        case display(id: String?, from: Double, to: Double, mapToString: ((Double) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [TextOutputPresentableModel?] = []
    private(set) var capturedDisplayText: [String?] = []
    private(set) var capturedDisplayAttributes: [[TextAttributes]] = []
    private(set) var capturedDisplayId: [String?] = []
    private(set) var capturedDisplayStartAmount: [Double] = []
    private(set) var capturedDisplayEndAmount: [Double] = []
    private(set) var capturedDisplayMapToString: [((Double) -> TextOutputPresentableModel)?] = []
    private(set) var capturedDisplayAnimationStyle: [LabelAnimationStyle] = []
    private(set) var capturedDisplayDuration: [TimeInterval] = []
    private(set) var capturedDisplayCompletion: [(() -> Void)?] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - TextOutput methods
    func display(model: TextOutputPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(text: String?) {
        capturedDisplayText.append(text)
        messages.append(.display(text: text))
    }
    func display(attributes: [TextAttributes]) {
        capturedDisplayAttributes.append(attributes)
        messages.append(.display(attributes: attributes))
    }
    func display(id: String?, from startAmount: Double, to endAmount: Double, mapToString: ((Double) -> TextOutputPresentableModel)?, animationStyle: LabelAnimationStyle, duration: TimeInterval, completion: (() -> Void)?) {
        capturedDisplayId.append(id)
        capturedDisplayStartAmount.append(startAmount)
        capturedDisplayEndAmount.append(endAmount)
        capturedDisplayMapToString.append(mapToString)
        capturedDisplayAnimationStyle.append(animationStyle)
        capturedDisplayDuration.append(duration)
        capturedDisplayCompletion.append(completion)
        messages.append(.display(id: id, from: startAmount, to: endAmount, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
