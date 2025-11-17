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

extension DatePickerViewOutput {
    public var mainQueueDispatched: any DatePickerViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: DatePickerViewOutput where T: DatePickerViewOutput {

    public func display(dateChanged: ((Date) -> Void)?) {
        dispatch { [weak self] in
            self?.decoratee.display(dateChanged: dateChanged)
        }
    }
    public func display(date: Date) {
        dispatch { [weak self] in
            self?.decoratee.display(date: date)
        }
    }
    public func display(setDate: Date, animated: Bool) {
        dispatch { [weak self] in
            self?.decoratee.display(setDate: setDate, animated: animated)
        }
    }
    public func display(model: DatePickerPresentableModel) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }

}
#endif
