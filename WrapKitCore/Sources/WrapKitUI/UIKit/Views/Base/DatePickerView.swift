//
//  DatePickerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/5/24.
//

import Foundation

public struct DatePickerPresentableModel {
    public let value: Date
    public let minimumDate: Date?
    public let maximumDate: Date?
    public let mode: DatePickerMode
    public let dateChanged: ((Date) -> Void)?
    
    public init(
        value: Date,
        minimumDate: Date?,
        maximumDate: Date?,
        mode: DatePickerMode,
        dateChanged: ((Date) -> Void)?
    ) {
        self.value = value
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.mode = mode
        self.dateChanged = dateChanged
    }
}

public protocol DatePickerViewOutput: AnyObject {
    func display(dateChanged: ((Date) -> Void)?)
    func display(date: Date)
    func display(setDate: Date, animated: Bool)
    func display(model: DatePickerPresentableModel)
}

public enum DatePickerMode: HashableWithReflection {
    case time
    case date
    case dateAndTime
    case countDownTimer
}

#if canImport(UIKit)
import Foundation
import UIKit

open class DatePickerView: UIDatePicker {
    open var dateChanged: ((Date) -> Void)?
    
    public init() {
        super.init(frame: .zero)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        if #available(iOS 13.4, *) {
            preferredDatePickerStyle = .wheels
        }
        datePickerMode = .date
        addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
    }
    
    @objc private func dateDidChange() {
        dateChanged?(date)
    }
}

extension DatePickerView: DatePickerViewOutput {
    public func display(date: Date) {
        self.date = date
    }
    
    public func display(setDate: Date, animated: Bool) {
        self.setDate(date, animated: animated)
    }
    
    public func display(dateChanged: ((Date) -> Void)?) {
        self.dateChanged = dateChanged
    }
    
    public func display(model: DatePickerPresentableModel) {
        display(dateChanged: model.dateChanged)
        display(date: model.value)
        minimumDate = model.minimumDate
        maximumDate = model.maximumDate
        datePickerMode = mapMode(model.mode)
    }
}

public extension DatePickerView {
    
    func mapMode(_ mode: DatePickerMode) -> UIDatePicker.Mode {
        switch mode {
        case .time:
                .time
        case .date:
                .date
        case .dateAndTime:
                .dateAndTime
        case .countDownTimer:
                .countDownTimer
        }
    }
}
#endif
