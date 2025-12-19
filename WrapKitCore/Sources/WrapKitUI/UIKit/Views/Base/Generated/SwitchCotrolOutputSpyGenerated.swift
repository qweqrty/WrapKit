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

public final class SwitchCotrolOutputSpy: SwitchCotrolOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: SwitchControlPresentableModel?)
        case displayOnPress(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?)
        case displayIsOn(isOn: Bool)
        case displayStyle(style: SwitchControlPresentableModel.Style?)
        case displayIsEnabled(isEnabled: Bool)
        case displayIsHidden(isHidden: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModelModel: [SwitchControlPresentableModel?] = []
    public private(set) var capturedDisplayOnPressOnPress: [((SwitchCotrolOutput & LoadingOutput) -> Void)?] = []
    public private(set) var capturedDisplayIsOnIsOn: [Bool] = []
    public private(set) var capturedDisplayStyleStyle: [SwitchControlPresentableModel.Style?] = []
    public private(set) var capturedDisplayIsEnabledIsEnabled: [Bool] = []
    public private(set) var capturedDisplayIsHiddenIsHidden: [Bool] = []


    // MARK: - SwitchCotrolOutput methods
    public func display(model: SwitchControlPresentableModel?) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?) {
        capturedDisplayOnPressOnPress.append(onPress)
        messages.append(.displayOnPress(onPress: onPress))
    }
    public func display(isOn: Bool) {
        capturedDisplayIsOnIsOn.append(isOn)
        messages.append(.displayIsOn(isOn: isOn))
    }
    public func display(style: SwitchControlPresentableModel.Style?) {
        capturedDisplayStyleStyle.append(style)
        messages.append(.displayStyle(style: style))
    }
    public func display(isEnabled: Bool) {
        capturedDisplayIsEnabledIsEnabled.append(isEnabled)
        messages.append(.displayIsEnabled(isEnabled: isEnabled))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHiddenIsHidden.append(isHidden)
        messages.append(.displayIsHidden(isHidden: isHidden))
    }

    // MARK: - Properties
}
