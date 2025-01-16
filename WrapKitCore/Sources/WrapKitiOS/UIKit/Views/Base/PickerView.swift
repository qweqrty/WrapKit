//
//  PickerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/5/24.
//

public protocol PickerViewOutput: AnyObject {
    func display(model: PickerViewPresentableModel?)
    var componentsCount: (() -> Int?)? { get set }
    var rowsCount: (() -> Int)? { get set }
    var titleForRowAt: ((Int) -> String?)? { get set }
    var didSelectAt: ((Int) -> Void)? { get set }
}

public struct PickerViewPresentableModel {
    public let componentsCount: (() -> Int?)?
    public let rowsCount: (() -> Int)?
    public let titleForRowAt: ((Int) -> String?)?
    public let didSelectAt: ((Int) -> Void)?
    
    public init(
        componentsCount: (() -> Int?)? = nil,
        rowsCount: (() -> Int)? = nil,
        titleForRowAt: ((Int) -> String?)? = nil,
        didSelectAt: ((Int) -> Void)? = nil
    ) {
        self.componentsCount = componentsCount
        self.rowsCount = rowsCount
        self.titleForRowAt = titleForRowAt
        self.didSelectAt = didSelectAt
    }
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

extension PickerView: PickerViewOutput {
    public func display(model: PickerViewPresentableModel?) {
        isHidden = model == nil
        componentsCount = model?.componentsCount
        rowsCount = model?.rowsCount
        titleForRowAt = model?.titleForRowAt
        didSelectAt = model?.didSelectAt
    }
}
#endif
