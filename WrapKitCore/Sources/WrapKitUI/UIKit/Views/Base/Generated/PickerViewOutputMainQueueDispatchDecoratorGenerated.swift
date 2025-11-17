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
            return decoratee.componentsCount          
        }
        set {
            decoratee.componentsCount = newValue
        }
    }
    public var rowsCount: (() -> Int)? {
        get {
            return decoratee.rowsCount          
        }
        set {
            decoratee.rowsCount = newValue
        }
    }
    public var titleForRowAt: ((Int) -> String?)? {
        get {
            return decoratee.titleForRowAt          
        }
        set {
            decoratee.titleForRowAt = newValue
        }
    }
    public var didSelectAt: ((Int) -> Void)? {
        get {
            return decoratee.didSelectAt          
        }
        set {
            decoratee.didSelectAt = newValue
        }
    }
}
#endif
