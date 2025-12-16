// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class PickerViewOutputSpy: PickerViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case display(model: PickerViewPresentableModel?)
        case display(selectedRow: PickerViewPresentableModel.SelectedRow?)
        case setComponentsCount((() -> Int?)?)
        case setRowsCount((() -> Int)?)
        case setTitleForRowAt(((Int) -> String?)?)
        case setDidSelectAt(((Int) -> Void)?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [PickerViewPresentableModel?] = []
    public private(set) var capturedDisplaySelectedRow: [PickerViewPresentableModel.SelectedRow?] = []

    public private(set) var capturedComponentsCount: [(() -> Int?)?] = []
    public private(set) var capturedRowsCount: [(() -> Int)?] = []
    public private(set) var capturedTitleForRowAt: [((Int) -> String?)?] = []
    public private(set) var capturedDidSelectAt: [((Int) -> Void)?] = []

    // MARK: - PickerViewOutput methods
    public func display(model: PickerViewPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }
    public func display(selectedRow: PickerViewPresentableModel.SelectedRow?) {
        capturedDisplaySelectedRow.append(selectedRow)
        messages.append(.display(selectedRow: selectedRow))
    }

    // MARK: - Properties
    public var componentsCount: (() -> Int?)? {
        didSet {
            capturedComponentsCount.append(componentsCount)
            messages.append(.setComponentsCount(componentsCount))
        }
    }
    public var rowsCount: (() -> Int)? {
        didSet {
            capturedRowsCount.append(rowsCount)
            messages.append(.setRowsCount(rowsCount))
        }
    }
    public var titleForRowAt: ((Int) -> String?)? {
        didSet {
            capturedTitleForRowAt.append(titleForRowAt)
            messages.append(.setTitleForRowAt(titleForRowAt))
        }
    }
    public var didSelectAt: ((Int) -> Void)? {
        didSet {
            capturedDidSelectAt.append(didSelectAt)
            messages.append(.setDidSelectAt(didSelectAt))
        }
    }
}
