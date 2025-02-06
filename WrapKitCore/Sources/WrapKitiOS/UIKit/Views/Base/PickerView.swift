//
//  PickerView.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/5/24.
//

public protocol PickerViewOutput: AnyObject {
    func display(model: PickerViewPresentableModel?)
    func display(selectedRow: PickerViewPresentableModel.SelectedRow?)
    var componentsCount: (() -> Int?)? { get set }
    var rowsCount: (() -> Int)? { get set }
    var titleForRowAt: ((Int) -> String?)? { get set }
    var didSelectAt: ((Int) -> Void)? { get set }
}

public struct PickerViewPresentableModel {
    public struct SelectedRow {
        public let row: Int
        public let component: Int
        public let animated: Bool
        public let selectedRowCompletion: ((Int) -> Void)?
        
        public init(
            row: Int,
            component: Int = 0,
            animated: Bool = false,
            selectedRowCompletion: ((Int) -> Void)? = nil
        ) {
            self.row = row
            self.component = component
            self.animated = animated
            self.selectedRowCompletion = selectedRowCompletion
        }
    }
    
    public let componentsCount: (() -> Int?)?
    public let rowsCount: (() -> Int)?
    public let titleForRowAt: ((Int) -> String?)?
    public let didSelectAt: ((Int) -> Void)?
    public let selectedRow: SelectedRow?
    
    public init(
        componentsCount: (() -> Int?)? = nil,
        rowsCount: (() -> Int)? = nil,
        titleForRowAt: ((Int) -> String?)? = nil,
        didSelectAt: ((Int) -> Void)? = nil,
        selectedRow: SelectedRow? = nil
    ) {
        self.componentsCount = componentsCount
        self.rowsCount = rowsCount
        self.titleForRowAt = titleForRowAt
        self.didSelectAt = didSelectAt
        self.selectedRow = selectedRow
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
        display(selectedRow: model?.selectedRow)
    }
    
    public func display(selectedRow: PickerViewPresentableModel.SelectedRow?) {
        guard let selectedRow,
              let componentsCount = componentsCount?(),
              let rowsCount = rowsCount?(),
              selectedRow.component <= rowsCount,
              selectedRow.row <= rowsCount else { return }
        reloadAllComponents()
        selectRow(selectedRow.row, inComponent: selectedRow.component, animated: selectedRow.animated)
        selectedRow.selectedRowCompletion?(self.selectedRow(inComponent: selectedRow.component))
    }
}
#endif
