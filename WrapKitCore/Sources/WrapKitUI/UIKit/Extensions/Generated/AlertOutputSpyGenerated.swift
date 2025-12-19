// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif

public final class AlertOutputSpy: AlertOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case showAlertModel(model: AlertPresentableModel?)
        case showActionSheetModel(model: AlertPresentableModel?)
        case showTextFieldAlertModel(model: AlertPresentableModel?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedShowAlertModelModel: [AlertPresentableModel?] = []
    public private(set) var capturedShowActionSheetModelModel: [AlertPresentableModel?] = []
    public private(set) var capturedShowTextFieldAlertModelModel: [AlertPresentableModel?] = []


    // MARK: - AlertOutput methods
    public func showAlert(model: AlertPresentableModel?) {
        capturedShowAlertModelModel.append(model)
        messages.append(.showAlertModel(model: model))
    }
    public func showActionSheet(model: AlertPresentableModel?) {
        capturedShowActionSheetModelModel.append(model)
        messages.append(.showActionSheetModel(model: model))
    }
    public func showTextFieldAlert(model: AlertPresentableModel?) {
        capturedShowTextFieldAlertModelModel.append(model)
        messages.append(.showTextFieldAlertModel(model: model))
    }

    // MARK: - Properties
}
