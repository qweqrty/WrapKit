// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(UIKit)
import UIKit
#endif

extension AlertOutput {
    public var mainQueueDispatched: any AlertOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: AlertOutput where T: AlertOutput {

    public func showAlert(model: AlertPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.showAlert(model: model)
        }
    }
    public func showActionSheet(model: AlertPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.showActionSheet(model: model)
        }
    }
    public func showTextFieldAlert(model: AlertPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.showTextFieldAlert(model: model)
        }
    }

}
#endif
