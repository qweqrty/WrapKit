// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

extension SwitchCotrolOutput {
    public var weakReferenced: any SwitchCotrolOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: SwitchCotrolOutput where T: SwitchCotrolOutput {

    public func display(model: SwitchControlPresentableModel?) {
        object?.display(model: model)
    }
    public func display(onPress: ((SwitchCotrolOutput) -> Void)?) {
        object?.display(onPress: onPress)
    }
    public func display(isOn: Bool) {
        object?.display(isOn: isOn)
    }
    public func display(style: SwitchControlPresentableModel.Style) {
        object?.display(style: style)
    }
    public func display(isEnabled: Bool) {
        object?.display(isEnabled: isEnabled)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
