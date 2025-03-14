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

extension TextOutput {
    public var mainQueueDispatched: any TextOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: TextOutput where T: TextOutput {

    public func display(model: TextOutputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(text: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(text: text)
        }
    }
    public func display(attributes: [TextAttributes]) {
        dispatch { [weak self] in
            self?.decoratee.display(attributes: attributes)
        }
    }

}
#endif
