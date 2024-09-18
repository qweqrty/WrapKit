//
//  Textview.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class Textview: UITextView, UITextViewDelegate {
    private var padding: UIEdgeInsets
    private var isValidState = true
    
    public lazy var placeholderLabel = Label(font: font!, textColor: .gray)
    public var textDidChange: (() -> Void)?
    public var shouldChangeText: ((NSRange, String) -> Bool)?
    public var appearance: TextfieldAppearance { didSet { updateAppearance() }}
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if textAlignment != .center {
                textAlignment = semanticContentAttribute == .forceRightToLeft ? .right : .left
            }
        }
    }
    
    public init(
        appearance: TextfieldAppearance,
        cornerRadius: CGFloat = 10,
        borderWidth: CGFloat = 1,
        contentInset: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
    ) {
        self.padding = contentInset
        self.appearance = appearance
        super.init(frame: .zero, textContainer: nil)
        self.font = appearance.font
        self.textColor = appearance.colors.textColor
        self.textContainerInset = padding
        self.backgroundColor = appearance.colors.deselectedBackgroundColor
        self.contentMode = contentMode
        self.layer.borderColor = appearance.colors.deselectedBorderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.textContainerInset = contentInset
        self.delegate = self
        self.placeholderLabel.textColor = appearance.placeholder?.color
        self.placeholderLabel.font = appearance.placeholder?.font
        setupSubviews()
        setupConstraints()
    }
        
    func setupSubviews() {
        addSubview(placeholderLabel)
    }
    
    func setupConstraints() {
        placeholderLabel.anchor(
            .top(topAnchor, constant: padding.top),
            .leading(leadingAnchor, constant: padding.left + 4)
        )
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.padding = .zero
        fatalError("init(coder:) has not been implemented")
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        textDidChange?()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return shouldChangeText?(range, text) ?? true
    }
    
    private func updatePlaceholder() {
        guard let customizedPlaceholder = appearance.placeholder else { return }
        attributedText = NSAttributedString(
            string: customizedPlaceholder.text ?? placeholderLabel.text ?? "",
            attributes: [
                NSAttributedString.Key.foregroundColor: isUserInteractionEnabled ? customizedPlaceholder.color : (customizedPlaceholder.disabledColor ?? customizedPlaceholder.color),
                NSAttributedString.Key.font: customizedPlaceholder.font
            ]
        )
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }
}

public extension Textview {
    func updateAppearance(isValid: Bool) {
        self.isValidState = isValid
        font = appearance.font
        let isFirstResponder = isFirstResponder
        let appearance = appearance
        UIView.animate(withDuration: 0.1, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
            if isValid {
                self.backgroundColor = isFirstResponder ? appearance.colors.selectedBackgroundColor : appearance.colors.deselectedBackgroundColor
                self.layer.borderColor = isFirstResponder ? appearance.colors.selectedBorderColor.cgColor : appearance.colors.deselectedBorderColor.cgColor
            } else {
                self.backgroundColor = appearance.colors.errorBackgroundColor
                self.layer.borderColor = appearance.colors.errorBorderColor.cgColor
            }
            self.layer.borderWidth = (isFirstResponder ? appearance.border?.selectedBorderWidth : appearance.border?.idleBorderWidth) ?? 0
        }
    }
    
    private func updateAppearance() {
        updatePlaceholder()
        font = appearance.font
        let text = (delegate as? MaskedTextfieldDelegate)?.fullText ?? text
        let isValid = isValidState
        let isFirstResponder = isFirstResponder
        let appearance = appearance
        UIView.animate(withDuration: 0.1, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
            if isValid {
                self.backgroundColor = isFirstResponder ? appearance.colors.selectedBackgroundColor : appearance.colors.deselectedBackgroundColor
                self.layer.borderColor = isFirstResponder ? appearance.colors.selectedBorderColor.cgColor : appearance.colors.deselectedBorderColor.cgColor
            } else {
                self.backgroundColor = appearance.colors.errorBackgroundColor
                self.layer.borderColor = appearance.colors.errorBorderColor.cgColor
            }
            self.layer.borderWidth = (isFirstResponder ? appearance.border?.selectedBorderWidth : appearance.border?.idleBorderWidth) ?? 0
        }
    }
}
#endif
