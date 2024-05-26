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
            guard oldValue != fullText else { return }
            setupMask(mask: format.mask.applied(to: fullText))
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
        guard let textfield = textfield else { return }
        self.fullText = mask.input
        
        if mask.input.isEmpty && !(textfield.placeholder?.isEmpty ?? true) && !textfield.isFirstResponder {
            textfield.attributedText = nil
        } else {
            textfield.attributedText = .combined(
                .init(mask.input, font: textfield.font ?? .systemFont(ofSize: 17), color: textfield.appearence.colors.textColor, textAlignment: textfield.textAlignment),
                .init(mask.maskToInput, font: textfield.font ?? .systemFont(ofSize: 17), color: format.maskedTextColor, textAlignment: textfield.textAlignment)
            )
        }
        
        textfield.sendActions(for: .editingChanged)
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textField = textField as? Textfield, let selectedRange = textField.selectedTextRange else { return }

        let currentPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        
        let validLength = min(fullText.count, format.mask.format.count)

        if currentPosition > validLength || (currentPosition < validLength && format.mask.isLiteralCharacter(at: currentPosition)) {
            // Adjust the caret to the nearest valid position that is not a literal.
            if let newPosition = adjustPositionAvoidingLiterals(textField: textField, from: currentPosition, direction: currentPosition > validLength ? -1 : 1) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    private func adjustPositionAvoidingLiterals(textField: Textfield, from position: Int, direction: Int) -> UITextPosition? {
        var newPosition = position
        let step = direction > 0 ? 1 : -1

        while newPosition >= 0 && newPosition < format.mask.format.count {
            if !format.mask.isLiteralCharacter(at: newPosition) {
                break
            }
            newPosition += step
        }

        // Check if we have moved out of bounds, if so adjust back to a valid position
        if newPosition < 0 || newPosition >= format.mask.format.count {
            newPosition = max(0, min(newPosition, format.mask.format.count - 1))
        }

        return textField.position(from: textField.beginningOfDocument, offset: newPosition)
    }


}
#endif
