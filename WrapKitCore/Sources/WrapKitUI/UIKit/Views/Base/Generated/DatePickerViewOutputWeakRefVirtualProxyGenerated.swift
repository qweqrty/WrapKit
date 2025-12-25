// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
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
    public var weakReferenced: any DatePickerViewOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: DatePickerViewOutput where T: DatePickerViewOutput {

    public func display(dateChanged: ((Date) -> Void)?) {
        object?.display(dateChanged: dateChanged)
    }
    public func display(date: Date) {
        object?.display(date: date)
    }
    public func display(setDate: Date, animated: Bool) {
        object?.display(setDate: setDate, animated: animated)
    }
    public func display(model: DatePickerPresentableModel) {
        object?.display(model: model)
    }

}
#endif
