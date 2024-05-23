//
//  MaskedTextfieldDelegate.swift
//  WrapKit
//
//  Created by Stas Lee on 28/8/23.
//

#if canImport(UIKit)
import UIKit

public class MaskedTextfieldDelegate: NSObject, UITextFieldDelegate {
    public struct Format {
        let mask: Masking
        let maskedTextColor: UIColor
    }
    private let textfield: Textfield
    private var format: Format {
        didSet {
            setupMask(mask: format.mask.applied(to: fullText))
        }
    }
    
    public var onlySpecifiersIfMaskedText: String { format.mask.extractUserInput(from: fullText) }
    public lazy var fullText: String = format.mask.applied(to: "").input {
        didSet {
            setupMask(mask: format.mask.applied(to: fullText))
        }
    }
    
    public init(
        textfield: Textfield,
        format: Format
    ) {
        self.textfield = textfield
        self.format = format
    }
    
    @discardableResult
    public func applied() -> Self {
        self.textfield.delegate = self
        textfield.keyboardType = format.mask.keyboardType()
        let mask = format.mask.applied(to: fullText)
        let updateTextIfMasked: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            let mask = self.format.mask
            self.setupMask(mask: mask.applied(to: self.fullText))
        }
        textfield.onBecomeFirstResponder = updateTextIfMasked
        textfield.onResignFirstResponder = updateTextIfMasked
        
        setupMask(mask: mask)
        return self
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setupMask(mask: string.isEmpty ? format.mask.removeCharacters(from: fullText, in: range) : format.mask.applied(to: fullText + string))
        return false
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        setupMask(mask: format.mask.applied(to: fullText))
    }
    
    private func setupMask(mask: (input: String, maskToInput: String)) {
        self.fullText = mask.input
        self.textfield.text = mask.maskToInput
        
        if mask.input.isEmpty && !(textfield.placeholder?.isEmpty ?? true) && !textfield.isFirstResponder {
            textfield.attributedText = nil
        } else {
            textfield.attributedText = .combined(
                .init(mask.input, font: textfield.font ?? .systemFont(ofSize: 17), color: textfield.textColor ?? .clear, textAlignment: textfield.textAlignment),
                .init(mask.maskToInput, font: textfield.font ?? .systemFont(ofSize: 17), color: format.maskedTextColor, textAlignment: textfield.textAlignment)
            )
        }
        
        textfield.sendActions(for: .editingChanged)
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let selectedRange = textField.selectedTextRange else { return }
        
        let endOfInputIndex = min(fullText.count, textField.text?.count ?? 0)
        if let endOfInputPosition = textField.position(from: textField.beginningOfDocument, offset: endOfInputIndex) {
            if textField.offset(from: textField.beginningOfDocument, to: selectedRange.start) > endOfInputIndex {
                textField.selectedTextRange = textField.textRange(from: endOfInputPosition, to: endOfInputPosition)
            }
        }
    }
}
#endif
