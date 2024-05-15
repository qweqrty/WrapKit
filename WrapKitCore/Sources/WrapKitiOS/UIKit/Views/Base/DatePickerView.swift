//
//  DatePickerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/5/24.
//

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
#endif
