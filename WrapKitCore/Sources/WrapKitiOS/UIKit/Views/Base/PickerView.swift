//
//  PickerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/5/24.
//

public protocol PickerViewOutput: AnyObject {
    var componentsCount: (() -> Int?)? { get set }
    var rowsCount: (() -> Int)? { get set }
    var titleForRowAt: ((Int) -> String?)? { get set }
    var didSelectAt: ((Int) -> Void)? { get set }
}

#if canImport(UIKit)
import Foundation
import UIKit

open class PickerView: UIPickerView {
    open var componentsCount: (() -> Int?)?
    open var rowsCount: (() -> Int)?
    open var titleForRowAt: ((Int) -> String?)?
    open var didSelectAt: ((Int) -> Void)?
    
    public init() {
        super.init(frame: .zero)
        tintColor = .clear
        dataSource = self
        delegate = self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = .clear
        dataSource = self
        delegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        componentsCount?() ?? 0
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        rowsCount?() ?? 0
    }
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        titleForRowAt?(row)
    }
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectAt?(row)
    }
}

extension PickerView: PickerViewOutput { }
#endif
