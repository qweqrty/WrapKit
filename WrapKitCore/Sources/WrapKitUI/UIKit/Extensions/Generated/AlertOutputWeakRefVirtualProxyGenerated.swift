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
    public var weakReferenced: any AlertOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: AlertOutput where T: AlertOutput {

    public func showAlert(model: AlertPresentableModel?) {
        object?.showAlert(model: model)
    }
    public func showActionSheet(model: AlertPresentableModel?) {
        object?.showActionSheet(model: model)
    }
    public func showTextFieldAlert(model: AlertPresentableModel?) {
        object?.showTextFieldAlert(model: model)
    }

}
#endif
