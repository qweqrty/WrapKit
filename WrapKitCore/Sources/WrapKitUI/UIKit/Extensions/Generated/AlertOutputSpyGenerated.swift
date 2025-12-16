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
#if canImport(UIKit)
import UIKit
#endif

public final class AlertOutputSpy: AlertOutput {
    enum Message: HashableWithReflection {
        case showAlert(model: AlertPresentableModel?)
        case showActionSheet(model: AlertPresentableModel?)
        case showTextFieldAlert(model: AlertPresentableModel?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedShowAlertModel: [AlertPresentableModel?] = []
    private(set) var capturedShowActionSheetModel: [AlertPresentableModel?] = []
    private(set) var capturedShowTextFieldAlertModel: [AlertPresentableModel?] = []


    // MARK: - AlertOutput methods
    func showAlert(model: AlertPresentableModel?) {
        capturedShowAlertModel.append(model)
        messages.append(.showAlert(model: model))
    }
    func showActionSheet(model: AlertPresentableModel?) {
        capturedShowActionSheetModel.append(model)
        messages.append(.showActionSheet(model: model))
    }
    func showTextFieldAlert(model: AlertPresentableModel?) {
        capturedShowTextFieldAlertModel.append(model)
        messages.append(.showTextFieldAlert(model: model))
    }

    // MARK: - Properties
}
