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
    
    public private(set) lazy var inputText: String = mask.apply(to: "").input

    public init(
        mask: Masking,
        maskTextColor: UIColor,
        textfieldPadding: UIEdgeInsets
    ) {
        self.mask = mask
        self.maskTextColor = maskTextColor
        self.wrappedLabel.padding = textfieldPadding
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard text.isEmpty else { return }
        inputText = mask.apply(to: "").input
        textFieldDidBeginEditing(textField)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if wrappedLabel.superview != textField {
            wrappedLabel.removeFromSuperview()
            textField.addSubview(wrappedLabel)
            wrappedLabel.anchor(
                .top(textField.topAnchor),
                .leading(textField.leadingAnchor),
                .trailing(textField.trailingAnchor),
                .bottom(textField.bottomAnchor)
            )
        }
        let (input, mask) = string.isEmpty ? mask.removeCharacters(from: inputText, in: range) : mask.apply(to: inputText + string)

        inputText = input
        textField.text = input
        wrappedLabel.contentView.attributedText = .combined(
            .init(input, font: textField.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .left),
            .init(mask, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .left)
        )
        textField.sendActions(for: .editingChanged)

        return false
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if wrappedLabel.superview != textField {
            wrappedLabel.removeFromSuperview()
            textField.addSubview(wrappedLabel)
            wrappedLabel.anchor(
                .top(textField.topAnchor),
                .leading(textField.leadingAnchor),
                .trailing(textField.trailingAnchor),
                .bottom(textField.bottomAnchor)
            )
        }
        let maskedText = mask.apply(to: inputText)
        self.inputText = maskedText.input
        textField.text = maskedText.input
        wrappedLabel.contentView.attributedText = .combined(
            .init(maskedText.input, font: textField.font ?? .systemFont(ofSize: 17), color: .clear, textAlignment: .left),
            .init(maskedText.maskToInput, font: textField.font ?? .systemFont(ofSize: 17), color: maskTextColor, textAlignment: .left)
        )
        textField.sendActions(for: .editingChanged)
    }
}
#endif
