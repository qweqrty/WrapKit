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

extension SearchBarOutput {
    public var mainQueueDispatched: any SearchBarOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: SearchBarOutput where T: SearchBarOutput {

    public func display(model: SearchBarPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(textField: TextInputPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(textField: textField)
        }
    }
    public func display(leftView: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(leftView: leftView)
        }
    }
    public func display(rightView: ButtonPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(rightView: rightView)
        }
    }
    public func display(placeholder: String?) {
        dispatch { [weak self] in
            self?.decoratee.display(placeholder: placeholder)
        }
    }
    public func display(backgroundColor: Color?) {
        dispatch { [weak self] in
            self?.decoratee.display(backgroundColor: backgroundColor)
        }
    }
    public func display(spacing: CGFloat) {
        dispatch { [weak self] in
            self?.decoratee.display(spacing: spacing)
        }
    }

}
#endif
