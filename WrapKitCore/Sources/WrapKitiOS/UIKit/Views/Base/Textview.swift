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
    public lazy var placeholderLabel = Label(font: font!, textColor: .gray)
    public var textDidChange: (() -> Void)?
    public var shouldChangeText: ((NSRange, String) -> Bool)?
    
    public init(
        font: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        backgroundColor: UIColor = .clear,
        cornerRadius: CGFloat = 10,
        placeholder: String = "",
        placeholderTextColor: UIColor = .gray,
        borderWidth: CGFloat = 1,
        borderColor: UIColor = .darkGray,
        contentInset: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12)
    ) {
        self.padding = contentInset
        super.init(frame: .zero, textContainer: nil)
        self.font = font
        self.textColor = textColor
        self.textContainerInset = padding
        self.backgroundColor = backgroundColor
        self.contentMode = contentMode
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.textContainerInset = contentInset
        self.delegate = self
        self.placeholderLabel.textColor = placeholderTextColor
        self.placeholderLabel.font = font
        self.placeholderLabel.text = placeholder
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
    
    public required init?(coder aDecoder: NSCoder) {
        self.padding = .zero
        super.init(coder: aDecoder)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        textDidChange?()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return shouldChangeText?(range, text) ?? true
    }
}

public extension Textview {
    func with(font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    func with(textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }
    
    func with(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    func with(cornerRadius: CGFloat) ->  Self {
        self.layer.cornerRadius = cornerRadius
        return self
    }
    
    func with(borderWidth: CGFloat) -> Self {
        self.layer.borderWidth = borderWidth
        return self
    }
    
    func with(contentInset: UIEdgeInsets) -> Self {
        self.padding = contentInset
        return self
    }
    
    func with(placeholder: String) -> Self {
        self.placeholderLabel.text = placeholder
        return self
    }
    
    func with(placeholderTextColor: UIColor) -> Self {
        self.placeholderLabel.textColor = placeholderTextColor
        return self
    }
    
    func with(borderColor: UIColor) -> Self {
        self.layer.borderColor = borderColor.cgColor
        return self
    }
}
#endif
