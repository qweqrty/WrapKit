// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

extension SwitchCotrolOutput {
    public var weakReferenced: any SwitchCotrolOutput {
        return WeakRefVirtualProxy(self)
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

}

#endif
