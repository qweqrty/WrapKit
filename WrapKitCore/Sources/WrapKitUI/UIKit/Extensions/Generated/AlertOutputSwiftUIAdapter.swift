// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif
public class AlertOutputSwiftUIAdapter: ObservableObject, AlertOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var showAlertModelState: ShowAlertModelState? = nil
    public struct ShowAlertModelState {
        public let model: AlertPresentableModel?
    }
    public func showAlert(model: AlertPresentableModel?) {
        showAlertModelState = .init(
            model: model
        )
    }
    @Published public var showActionSheetModelState: ShowActionSheetModelState? = nil
    public struct ShowActionSheetModelState {
        public let model: AlertPresentableModel?
    }
    public func showActionSheet(model: AlertPresentableModel?) {
        showActionSheetModelState = .init(
            model: model
        )
    }
}
