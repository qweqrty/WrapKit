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
    public private(set) var capturedDisplayModelModel: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayEnabledEnabled: [Bool] = []
    public private(set) var capturedDisplayImageImage: [Image?] = []
    public private(set) var capturedDisplayStyleStyle: [ButtonStyle?] = []
    public private(set) var capturedDisplayTitleTitle: [String?] = []
    public private(set) var capturedDisplaySpacingSpacing: [CGFloat] = []
    public private(set) var capturedDisplayOnPressOnPress: [(() -> Void)?] = []
    public private(set) var capturedDisplayHeightHeight: [CGFloat] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - ButtonOutput methods
    public func display(model: ButtonPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(enabled: Bool) {
        capturedDisplayEnabledEnabled.append(enabled)
        messages.append(.displayEnabled(enabled: enabled))
    }
    public func display(image: Image?) {
        capturedDisplayImageImage.append(image)
        messages.append(.displayImage(image: image))
    }
    public func display(style: ButtonStyle?) {
        capturedDisplayStyleStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(title: String?) {
        capturedDisplayTitleTitle.append(title)
        messages.append(.displayTitle(title: title))
    }
    public func display(spacing: CGFloat) {
        capturedDisplaySpacingSpacing.append(spacing)
        messages.append(.displaySpacing(spacing: spacing))
    }
    public func display(onPress: (() -> Void)?) {
        capturedDisplayOnPressOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(height: CGFloat) {
        capturedDisplayHeightHeight.append(height)
        messages.append(.displayHeight(height: height))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
