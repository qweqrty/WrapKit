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

public final class DatePickerViewOutputSpy: DatePickerViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayDateChanged(dateChanged: ((Date) -> Void)?)
        case displayDate(date: Date)
        case displaySetDate(setDate: Date, animated: Bool)
        case displayModel(model: DatePickerPresentableModel)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayDateChangedDateChanged: [((Date) -> Void)?] = []
    public private(set) var capturedDisplayDateDate: [Date] = []
    public private(set) var capturedDisplaySetDateSetDate: [Date] = []
    public private(set) var capturedDisplaySetDateAnimated: [Bool] = []
    public private(set) var capturedDisplayModelModel: [DatePickerPresentableModel] = []


    // MARK: - DatePickerViewOutput methods
    public func display(dateChanged: ((Date) -> Void)?) {
        capturedDisplayDateChangedDateChanged.append(dateChanged)
        messages.append(.displayDateChanged(dateChanged: dateChanged))
    }
    public func display(date: Date) {
        capturedDisplayDateDate.append(date)
        messages.append(.displayDate(date: date))
    }
    public func display(setDate: Date, animated: Bool) {
        capturedDisplaySetDateSetDate.append(setDate)
        capturedDisplaySetDateAnimated.append(animated)
        messages.append(.displaySetDate(setDate: setDate, animated: animated))
    }
    public func display(model: DatePickerPresentableModel) {
        capturedDisplayModelModel.append(model)
        messages.append(.displayModel(model: model))
    }

    // MARK: - Properties
}
