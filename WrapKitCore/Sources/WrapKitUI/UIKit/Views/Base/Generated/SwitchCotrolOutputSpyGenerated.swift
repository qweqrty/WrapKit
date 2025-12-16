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

public final class SwitchCotrolOutputSpy: SwitchCotrolOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(model: SwitchControlPresentableModel?)
        case display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?)
        case display(isOn: Bool)
        case display(style: SwitchControlPresentableModel.Style?)
        case display(isEnabled: Bool)
        case display(isHidden: Bool)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [SwitchControlPresentableModel?] = []
    private(set) var capturedDisplayOnPress: [((SwitchCotrolOutput & LoadingOutput) -> Void)?] = []
    private(set) var capturedDisplayIsOn: [Bool] = []
    private(set) var capturedDisplayStyle: [SwitchControlPresentableModel.Style?] = []
    private(set) var capturedDisplayIsEnabled: [Bool] = []
    private(set) var capturedDisplayIsHidden: [Bool] = []


    // MARK: - SwitchCotrolOutput methods
    public func display(model: SwitchControlPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?) {
        capturedDisplayOnPress.append(onPress)
        messages.append(.display(onPress: onPress))
    }
    public func display(isOn: Bool) {
        capturedDisplayIsOn.append(isOn)
        messages.append(.display(isOn: isOn))
    }
    public func display(style: SwitchControlPresentableModel.Style?) {
        capturedDisplayStyle.append(style)
        messages.append(.display(style: style))
    }
    public func display(isEnabled: Bool) {
        capturedDisplayIsEnabled.append(isEnabled)
        messages.append(.display(isEnabled: isEnabled))
    }
    public func display(isHidden: Bool) {
        capturedDisplayIsHidden.append(isHidden)
        messages.append(.display(isHidden: isHidden))
    }

    // MARK: - Properties
}
