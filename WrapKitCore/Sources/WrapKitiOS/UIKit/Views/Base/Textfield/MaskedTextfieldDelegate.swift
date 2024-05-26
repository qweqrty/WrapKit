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
        guard let textField = textField as? Textfield else { return }
        guard let selectedRange = textField.selectedTextRange else { return }

        // Calculate the total length of the mask including literals and specifiers
        let maskLength = format.mask.format.count
        // Get the length of the text that represents the user's direct input, without mask characters
        let userInputLength = format.mask.extractUserInput(from: fullText).count
        
        // Calculate the correct position for the caret: it should not exceed the length of the user input or the total mask length
        let caretPosition = min(textField.text?.count ?? 0, userInputLength)
        
        if fullText.count < maskLength {
            // If the full text is shorter than the mask length, restrict caret positioning within the user input length
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: caretPosition) {
                if textField.offset(from: textField.beginningOfDocument, to: selectedRange.start) > caretPosition {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        } else {
            // If the full text meets or exceeds the mask length, allow normal behavior
            // This will handle cases where text editing and selection beyond the initial mask are required
            return
        }
    }

}
#endif
