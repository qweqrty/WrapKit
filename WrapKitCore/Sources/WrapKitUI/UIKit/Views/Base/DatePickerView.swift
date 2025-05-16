//
//  DatePickerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/5/24.
//

import Foundation

public protocol DatePickerViewOutput: AnyObject {
    func display(dateChanged: ((Date) -> Void)?)
    func display(date: Date)
    func display(setDate: Date, animated: Bool)
}

public enum DatePickerMode: HashableWithReflection {
    case time
    case date
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
}

public extension DatePickerView {
    func mapMode(_ mode: DatePickerMode) -> UIDatePicker.Mode {
        switch mode {
        case .time:
            return .time
        case .date:
            return .date
        }
    }
}
#endif
