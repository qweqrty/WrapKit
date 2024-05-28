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
        
        public init(mask: Masking, maskedTextColor: UIColor) {
            self.mask = mask
            self.maskedTextColor = maskedTextColor
        }
    }
    private var format: Format {
        didSet {
            setupMask(mask: format.mask.applied(to: fullText))
        }
    }
    
    private var textfield: Textfield?
    
    public var onlySpecifiersIfMaskedText: String { format.mask.extractUserInput(from: fullText) }
    public lazy var fullText: String = format.mask.applied(to: "").input {
        didSet {
            guard let textfield = textfield else { return }
            let mask = format.mask.applied(to: fullText)
            if mask.input.isEmpty && !(textfield.placeholder?.isEmpty ?? true) && !textfield.isFirstResponder {
                textfield.attributedText = nil
            } else {
                textfield.attributedText = .combined(
                    .init(mask.input, font: textfield.font ?? .systemFont(ofSize: 17), color: textfield.appearence.colors.textColor, textAlignment: textfield.textAlignment),
                    .init(mask.maskToInput, font: textfield.font ?? .systemFont(ofSize: 17), color: format.maskedTextColor, textAlignment: textfield.textAlignment)
                )
            }
            let newPosition = textfield.position(from: textfield.beginningOfDocument, offset: mask.input.count) ?? textfield.beginningOfDocument
            textfield.selectedTextRange = textfield.textRange(from: newPosition, to: newPosition)
            textfield.sendActions(for: .editingChanged)
        }
    }
    
    public init(format: Format) {
        self.format = format
    }
    
    @discardableResult
    public func applyTo(textfield: Textfield) -> Self {
        self.textfield = textfield
        textfield.delegate = self
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
    }
}

#endif
