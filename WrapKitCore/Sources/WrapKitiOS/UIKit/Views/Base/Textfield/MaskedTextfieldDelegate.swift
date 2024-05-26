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

        let maskLength = format.mask.format.count
        let userInputLength = format.mask.extractUserInput(from: fullText).count
        
        let caretPosition = min(textField.text?.count ?? 0, userInputLength)

        if fullText.count < maskLength {
            if let newPosition = findNextValidPosition(textField: textField, from: caretPosition) {
                if textField.offset(from: textField.beginningOfDocument, to: selectedRange.start) > caretPosition {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        }
    }

    private func findNextValidPosition(textField: Textfield, from position: Int) -> UITextPosition? {
        let text = textField.text ?? ""
        var currentPosition = position

        while currentPosition < text.count {
            let characterIndex = text.index(text.startIndex, offsetBy: currentPosition)
            if format.mask.isLiteralCharacter(at: currentPosition) {
                currentPosition += 1
            } else {
                return textField.position(from: textField.beginningOfDocument, offset: currentPosition)
            }
        }

        return textField.position(from: textField.beginningOfDocument, offset: position)
    }

}
#endif
