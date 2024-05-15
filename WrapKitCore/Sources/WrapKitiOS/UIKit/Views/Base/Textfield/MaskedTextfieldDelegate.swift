//
//  MaskedTextfieldDelegate.swift
//  WrapKit
//
//  Created by Stas Lee on 28/8/23.
//

#if canImport(UIKit)
import UIKit

public class MaskedTextFieldDelegate: NSObject, UITextFieldDelegate {
    public let mask: Masking
    private let textColor: UIColor
    private let maskTextColor: UIColor
    
    public var userInputText: String { mask.extractUserInput(from: inputText) }
    public lazy var inputText: String = mask.apply(to: "").input
    
    public init(
        mask: Masking,
        textColor: UIColor,
        maskTextColor: UIColor
    ) {
        self.mask = mask
        self.textColor = textColor
        self.maskTextColor = maskTextColor
    }
    
    public func applyTo(_ textField: UITextField) {
        textField.delegate = self
        let mask = mask.apply(to: inputText)
        
        self.inputText = mask.input
        textField.text = mask.maskToInput
        
        textField.attributedText = .combined(
            .init(mask.input, font: textField.font ?? .systemFont(ofSize: 17), color: textColor, textAlignment: textField.textAlignment),
            .init(mask.maskToInput, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: textField.textAlignment)
        )
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setupMask(
            in: textField,
            mask: string.isEmpty ? mask.removeCharacters(from: inputText, in: range) : mask.apply(to: inputText + string)
        )
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        setupMask(in: textField, mask: mask.apply(to: inputText))
    }
    
    private func setupMask(
        in textField: UITextField,
        mask: (input: String, maskToInput: String)
    ) {
        self.inputText = mask.input
        textField.text = mask.maskToInput
        
        textField.attributedText = .combined(
            .init(mask.input, font: textField.font ?? .systemFont(ofSize: 17), color: textColor, textAlignment: textField.textAlignment),
            .init(mask.maskToInput, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: textField.textAlignment)
        )
        
        textField.sendActions(for: .editingChanged)
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let selectedRange = textField.selectedTextRange else { return }
        
        let endOfInputIndex = min(inputText.count, textField.text?.count ?? 0)
        if let endOfInputPosition = textField.position(from: textField.beginningOfDocument, offset: endOfInputIndex) {
            if textField.offset(from: textField.beginningOfDocument, to: selectedRange.start) > endOfInputIndex {
                textField.selectedTextRange = textField.textRange(from: endOfInputPosition, to: endOfInputPosition)
            }
        }
    }
}#endif
