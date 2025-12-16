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

final class ButtonOutputSpy: ButtonOutput {
    enum Message: HashableWithReflection {
        case display(model: ButtonPresentableModel?)
        case display(enabled: Bool)
        case display(image: Image?)
        case display(style: ButtonStyle?)
        case display(title: String?)
        case display(spacing: CGFloat)
        case display(onPress: (() -> Void)?)
        case display(height: CGFloat)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [ButtonPresentableModel?] = []
    private(set) var capturedDisplayEnabled: [Bool] = []
    private(set) var capturedDisplayImage: [Image?] = []
    private(set) var capturedDisplayStyle: [ButtonStyle?] = []
    private(set) var capturedDisplayTitle: [String?] = []
    private(set) var capturedDisplaySpacing: [CGFloat] = []
    private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    private(set) var capturedDisplayHeight: [CGFloat] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ButtonOutput methods
    func display(model: ButtonPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    func display(enabled: Bool) {
        capturedDisplayEnabled.append(enabled)
        messages.append(.display(enabled: enabled))
    }
    func display(image: Image?) {
        capturedDisplayImage.append(image)
        messages.append(.display(image: image))
    }
    func display(style: ButtonStyle?) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    func display(title: String?) {
        capturedDisplayTitle.append(title)
        messages.append(.display(title: title))
    }
    func display(spacing: CGFloat) {
        capturedDisplaySpacing.append(spacing)
        messages.append(.display(spacing: spacing))
    }
    func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    func display(height: CGFloat) {
        capturedDisplayHeight.append(height)
        messages.append(.display(height: height))
    }
    func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
