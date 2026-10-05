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

extension PickerViewOutput {
    public var mainQueueDispatched: any PickerViewOutput {
        MainQueueDispatchDecorator(decoratee: self)
    }
}

extension MainQueueDispatchDecorator: PickerViewOutput where T: PickerViewOutput {

    public func display(model: PickerViewPresentableModel?) {
        dispatch { [weak self] in
            self?.decoratee.display(model: model)
        }
    }
    public func display(selectedRow: PickerViewPresentableModel.SelectedRow?) {
        dispatch { [weak self] in
            self?.decoratee.display(selectedRow: selectedRow)
        }
    }

    public var componentsCount: (() -> Int?)? {
        get {
            return dispatchSync { decoratee.componentsCount }
        }
        set {
            dispatch { [weak self] in
                self?.decoratee.componentsCount = newValue
            }
        }
    }
    public var rowsCount: (() -> Int)? {
        get {
            return dispatchSync { decoratee.rowsCount }
        }
        set {
            dispatch { [weak self] in
                self?.decoratee.rowsCount = newValue
            }
        }
    }
    public var titleForRowAt: ((Int) -> String?)? {
        get {
            return dispatchSync { decoratee.titleForRowAt }
        }
        set {
            dispatch { [weak self] in
                self?.decoratee.titleForRowAt = newValue
            }
        }
    }
    public var didSelectAt: ((Int) -> Void)? {
        get {
            return dispatchSync { decoratee.didSelectAt }
        }
        set {
            dispatch { [weak self] in
                self?.decoratee.didSelectAt = newValue
            }
        }
    }
}
#endif
