// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class PickerViewOutputSpy: PickerViewOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(model: PickerViewPresentableModel?)
        case display(selectedRow: PickerViewPresentableModel.SelectedRow?)
        case setComponentsCount((() -> Int?)?)
        case setRowsCount((() -> Int)?)
        case setTitleForRowAt(((Int) -> String?)?)
        case setDidSelectAt(((Int) -> Void)?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayModel: [PickerViewPresentableModel?] = []
    private(set) var capturedDisplaySelectedRow: [PickerViewPresentableModel.SelectedRow?] = []

    private(set) var capturedComponentsCount: [(() -> Int?)?] = []
    private(set) var capturedRowsCount: [(() -> Int)?] = []
    private(set) var capturedTitleForRowAt: [((Int) -> String?)?] = []
    private(set) var capturedDidSelectAt: [((Int) -> Void)?] = []

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
    var componentsCount: (() -> Int?)? {
        didSet {
            capturedComponentsCount.append(componentsCount)
            messages.append(.setComponentsCount(componentsCount))
        }
    }
    var rowsCount: (() -> Int)? {
        didSet {
            capturedRowsCount.append(rowsCount)
            messages.append(.setRowsCount(rowsCount))
        }
    }
    var titleForRowAt: ((Int) -> String?)? {
        didSet {
            capturedTitleForRowAt.append(titleForRowAt)
            messages.append(.setTitleForRowAt(titleForRowAt))
        }
    }
    var didSelectAt: ((Int) -> Void)? {
        didSet {
            capturedDidSelectAt.append(didSelectAt)
            messages.append(.setDidSelectAt(didSelectAt))
        }
    }
}
