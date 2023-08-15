//
//  Textview.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

import UIKit

open class Textview: UITextView, UITextViewDelegate {
    private var padding: UIEdgeInsets
    public lazy var placeholderLabel = Label(font: font!, textColor: .gray)
    var textDidChange: (() -> Void)?
    var shouldChangeText: ((NSRange, String) -> Bool)?
    
    public init(
        font: UIFont = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        backgroundColor: UIColor = .lightGray,
        cornerRadius: CGFloat = 10,
        placeholder: String = "",
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
