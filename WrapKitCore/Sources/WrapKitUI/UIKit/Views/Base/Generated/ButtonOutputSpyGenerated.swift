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

public final class ButtonOutputSpy: ButtonOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: ButtonPresentableModel?)
        case displayEnabled(enabled: Bool)
        case displayImage(image: Image?)
        case displayStyle(style: ButtonStyle?)
        case displayTitle(title: String?)
        case displaySpacing(spacing: CGFloat)
        case displayOnPress(onPress: (() -> Void)?)
        case displayHeight(height: CGFloat)
        case displayIsHidden(isHidden: Bool)
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
        messages.append(.displayModel(model: model))
    }
    public func display(enabled: Bool) {
        capturedDisplayEnabled.append(enabled)
        messages.append(.displayEnabled(enabled: enabled))
    }
    public func display(image: Image?) {
        capturedDisplayImage.append(image)
        messages.append(.displayImage(image: image))
    }
    public func display(style: ButtonStyle?) {
        capturedDisplayStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(title: String?) {
        capturedDisplayTitle.append(title)
        messages.append(.displayTitle(title: title))
    }
    public func display(spacing: CGFloat) {
        capturedDisplaySpacing.append(spacing)
        messages.append(.displaySpacing(spacing: spacing))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(height: CGFloat) {
        capturedDisplayHeight.append(height)
        messages.append(.displayHeight(height: height))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
