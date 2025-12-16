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

public final class DatePickerViewOutputSpy: DatePickerViewOutput {
    enum Message: HashableWithReflection {
        case display(dateChanged: ((Date) -> Void)?)
        case display(date: Date)
        case display(setDate: Date, animated: Bool)
        case display(model: DatePickerPresentableModel)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayDateChanged: [((Date) -> Void)?] = []
    private(set) var capturedDisplayDate: [Date] = []
    private(set) var capturedDisplaySetDate: [Date] = []
    private(set) var capturedDisplayAnimated: [Bool] = []
    private(set) var capturedDisplayModel: [DatePickerPresentableModel] = []


    // MARK: - DatePickerViewOutput methods
    func display(dateChanged: ((Date) -> Void)?) {
        capturedDisplayDateChanged.append(dateChanged)
        messages.append(.display(dateChanged: dateChanged))
    }
    func display(date: Date) {
        capturedDisplayDate.append(date)
        messages.append(.display(date: date))
    }
    func display(setDate: Date, animated: Bool) {
        capturedDisplaySetDate.append(setDate)
        capturedDisplayAnimated.append(animated)
        messages.append(.display(setDate: setDate, animated: animated))
    }
    func display(model: DatePickerPresentableModel) {
        capturedDisplayModel.append(model)
        messages.append(.display(model: model))
    }

    // MARK: - Properties
}
