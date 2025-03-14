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
    public var mainQueueDispatched: any SwitchCotrolOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: SwitchCotrolOutput where T: SwitchCotrolOutput {

    public func display(model: SwitchControlPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(onPress: ((SwitchCotrolOutput) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(onPress: onPress)
        }
    }
    public func display(isOn: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isOn: isOn)
        }
    }
    public func display(style: SwitchControlPresentableModel.Style) {
        dispatch { [weak self] in
            self?.decoratee.display(style: style)
        }
    }
    public func display(isEnabled: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(isEnabled: isEnabled)
        }
    }

}
#endif
