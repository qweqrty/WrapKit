// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

public final class PickerViewOutputSpy: PickerViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: PickerViewPresentableModel?)
        case displaySelectedRow(selectedRow: PickerViewPresentableModel.SelectedRow?)
        case setComponentsCount((() -> Int?)?)
        case setRowsCount((() -> Int)?)
        case setTitleForRowAt(((Int) -> String?)?)
        case setDidSelectAt(((Int) -> Void)?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [(PickerViewPresentableModel?)] = []
    public private(set) var capturedDisplaySelectedRow: [(PickerViewPresentableModel.SelectedRow?)] = []
    public private(set) var capturedSetComponentsCount: [(() -> Int?)?] = []
    public private(set) var capturedSetRowsCount: [(() -> Int)?] = []
    public private(set) var capturedSetTitleForRowAt: [((Int) -> String?)?] = []
    public private(set) var capturedSetDidSelectAt: [((Int) -> Void)?] = []

    // MARK: - PickerViewOutput methods
    public func display(model: PickerViewPresentableModel?) {
        capturedDisplayModel.append((model))
        messages.append(.displayModel(model: model))
    }
    public func display(selectedRow: PickerViewPresentableModel.SelectedRow?) {
        capturedDisplaySelectedRow.append((selectedRow))
        messages.append(.displaySelectedRow(selectedRow: selectedRow))
    }

    // MARK: - Properties
    public var componentsCount: (() -> Int?)? {
        didSet {
            capturedSetComponentsCount.append(componentsCount)
            messages.append(.setComponentsCount(componentsCount))
        }
    }
    public var rowsCount: (() -> Int)? {
        didSet {
            capturedSetRowsCount.append(rowsCount)
            messages.append(.setRowsCount(rowsCount))
        }
    }
    public var titleForRowAt: ((Int) -> String?)? {
        didSet {
            capturedSetTitleForRowAt.append(titleForRowAt)
            messages.append(.setTitleForRowAt(titleForRowAt))
        }
    }
    public var didSelectAt: ((Int) -> Void)? {
        didSet {
            capturedSetDidSelectAt.append(didSelectAt)
            messages.append(.setDidSelectAt(didSelectAt))
        }
    }
}
