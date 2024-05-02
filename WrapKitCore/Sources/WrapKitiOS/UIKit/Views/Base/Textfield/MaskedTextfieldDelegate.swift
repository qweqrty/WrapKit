//
//  MaskedTextfieldDelegate.swift
//  WrapKit
//
//  Created by Stas Lee on 28/8/23.
//

#if canImport(UIKit)
import UIKit

public class MaskedTextFieldDelegate: NSObject, UITextFieldDelegate {
    private let mask: Masking
    private let maskTextColor: UIColor
    private let wrappedLabel = WrapperView(contentView: Label(), isUserInteractionEnabled: false)
    
    public lazy var inputText: String = mask.apply(to: "").input

    public init(
        mask: Masking,
        maskTextColor: UIColor,
        textfieldPadding: UIEdgeInsets
    ) {
        self.mask = mask
        self.maskTextColor = maskTextColor
        self.wrappedLabel.padding = textfieldPadding
    }
    
    public func configureMaskViewIfNeeded(in textfield: UITextField) {
        if wrappedLabel.superview != textfield {
            wrappedLabel.removeFromSuperview()
            textfield.addSubview(wrappedLabel)
            wrappedLabel.anchor(
                .top(textfield.topAnchor),
                .leading(textfield.leadingAnchor),
                .trailing(textfield.trailingAnchor),
                .bottom(textfield.bottomAnchor)
            )
        }
        let maskedText = mask.apply(to: inputText)
        self.inputText = maskedText.input
        textfield.text = maskedText.input
        if textfield.semanticContentAttribute == .forceRightToLeft {
            wrappedLabel.contentView.attributedText = .combined(
                .init(maskedText.maskToInput, font: textfield.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .natural),
                .init(maskedText.input, font: textfield.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .natural)
            )
        } else {
            wrappedLabel.contentView.attributedText = .combined(
                .init(maskedText.input, font: textfield.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .natural),
                .init(maskedText.maskToInput, font: textfield.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .natural)
            )
        }
        
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        configureMaskViewIfNeeded(in: textField)
        let (input, mask) = string.isEmpty ? mask.removeCharacters(from: inputText, in: range) : mask.apply(to: inputText + string)

        inputText = input
        textField.text = input
        
        if textField.semanticContentAttribute == .forceRightToLeft {
            wrappedLabel.contentView.attributedText = .combined(
                .init(mask, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .natural),
                .init(input, font: textField.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .natural)
            )
        } else {
            wrappedLabel.contentView.attributedText = .combined(
                .init(input, font: textField.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .natural),
                .init(mask, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .natural)
            )
        }
        textField.sendActions(for: .editingChanged)

        return false
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        configureMaskViewIfNeeded(in: textField)
        let maskedText = mask.apply(to: inputText)
        self.inputText = maskedText.input
        textField.text = maskedText.input

        if textField.semanticContentAttribute == .forceRightToLeft {
            wrappedLabel.contentView.attributedText = .combined(
                .init(maskedText.maskToInput, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .natural),
                .init(maskedText.input, font: textField.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .natural)
            )
        } else {
            wrappedLabel.contentView.attributedText = .combined(
                .init(maskedText.input, font: textField.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .natural),
                .init(maskedText.maskToInput, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .natural)
            )
        }
        textField.sendActions(for: .editingChanged)
    }
}
#endif
