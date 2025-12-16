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

public final class ButtonOutputSpy: ButtonOutput {

    public init() {}

    public enum Message: HashableWithReflection {
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

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayEnabled: [Bool] = []
    public private(set) var capturedDisplayImage: [Image?] = []
    public private(set) var capturedDisplayStyle: [ButtonStyle?] = []
    public private(set) var capturedDisplayTitle: [String?] = []
    public private(set) var capturedDisplaySpacing: [CGFloat] = []
    public private(set) var capturedDisplayOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayHeight: [CGFloat] = []
    public private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - ButtonOutput methods
    public func display(model: ButtonPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(enabled: Bool) {
        capturedDisplayEnabled.append(enabled)
        messages.append(.display(enabled: enabled))
    }
    public func display(image: Image?) {
        capturedDisplayImage.append(image)
        messages.append(.display(image: image))
    }
    public func display(style: ButtonStyle?) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    public func display(title: String?) {
        capturedDisplayTitle.append(title)
        messages.append(.display(title: title))
    }
    public func display(spacing: CGFloat) {
        capturedDisplaySpacing.append(spacing)
        messages.append(.display(spacing: spacing))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    public func display(height: CGFloat) {
        capturedDisplayHeight.append(height)
        messages.append(.display(height: height))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
