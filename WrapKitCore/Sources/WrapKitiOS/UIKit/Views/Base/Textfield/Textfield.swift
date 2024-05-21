//
//  Textfield.swift
//  WrapKit
//
//  Created by Stanislav Li on 8/12/23.
//

#if canImport(UIKit)
import UIKit

open class Textfield: UITextField {
    public var padding: UIEdgeInsets = .zero
    public var clearButtonEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
    
    public var clearButtonTapped = false
    public var isTextSelectionDisabled = false
    public var isEditable = true
    
    public var onPress: (() -> Void)?
    public var validationRule: ((String?) -> Bool)?
    public var nextTextfield: UIResponder? = nil { didSet { returnKeyType = nextTextfield == nil ? .done : .next } }
    public var onBecomeFirstResponder: (() -> Void)?
    public var onResignFirstResponder: (() -> Void)?

    public var didChangeText = [((String?) -> Void)]()
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.3
    
    @discardableResult
    func validate() -> Bool {
        guard let validationRule = validationRule else {
            return true
        }
        let isValid = validationRule(text)
        if isValid {
            UIView.animate(withDuration: 0.3, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
                self.backgroundColor = self.selectedBackgroundColor
                self.layer.borderColor = self.selectedBorderColor.cgColor
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
                self.layer.borderColor = self.errorBorderColor.cgColor
                self.backgroundColor = self.errorBackgroundColor
            }
        }
        return isValid
    }
    
    open override var placeholder: String? {
        didSet {
            attributedPlaceholder = NSAttributedString(
                string: placeholder ?? "",
                attributes:[
                    NSAttributedString.Key.foregroundColor: placeholderColor
                ]
            )
        }
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let view = rightView else { return super.rightViewRect(forBounds: bounds) }
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= view.frame.width / 2
        return textRect
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += padding.left
        return textRect
    }
    
    open override var rightView: UIView? {
        didSet {
            guard rightView != nil else { return }
            rightViewMode = .always
        }
    }
    
    open override var leftView: UIView? {
        didSet {
            guard leftView != nil else { return }
            leftViewMode = .always
        }
    }
    
    public var selectedBorderColor = UIColor.gray { didSet { updateTextFieldAppearance() } }
    public var selectedBackgroundColor = UIColor.lightGray { didSet { updateTextFieldAppearance() } }
    public var errorBorderColor = UIColor.red { didSet { updateTextFieldAppearance() } }
    public var errorBackgroundColor = UIColor.red.withAlphaComponent(0.4) { didSet { updateTextFieldAppearance() } }
    public var placeholderColor = UIColor.lightGray { didSet { updatePlaceholder() } }

    public var deselectedBorderColor: UIColor
    public var deselectedBackgroundColor: UIColor
    public var idleBorderWidth: CGFloat
    public var selectedBorderWidth: CGFloat
    
    public init(
        font: UIFont? = .systemFont(ofSize: 16),
        textColor: UIColor = .black,
        backgroundColor: UIColor = .clear,
        cornerRadius: CGFloat = 10,
        borderWidth: CGFloat = 0.5,
        selectedBorderWidth: CGFloat = 1.5,
        borderColor: UIColor = .clear,
        padding: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12),
        nextTextfield: UIResponder? = nil,
        leadingView: UIView? = nil,
        trailingView: UIView? = nil,
        autocapitalizationType: UITextAutocapitalizationType = .none
    ) {
        self.padding = padding
        self.nextTextfield = nextTextfield
        self.idleBorderWidth = borderWidth
        self.selectedBorderWidth = selectedBorderWidth
        self.deselectedBackgroundColor = backgroundColor
        self.deselectedBorderColor = borderColor
        super.init(frame: .zero)

        self.autocorrectionType = .no
        if let font = font { self.font = font }
        self.textColor = textColor
        self.backgroundColor = deselectedBackgroundColor
        self.layer.borderWidth = idleBorderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = deselectedBorderColor.cgColor
        self.autocapitalizationType = .none
        returnKeyType = nextTextfield == nil ? .done : .next
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextfield))
        addGestureRecognizer(tapGesture)
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if let leadingView = leadingView {
            leftViewMode = .always
            leftView = leadingView
        } else if let trailingView = trailingView {
            rightViewMode = .always
            rightView = trailingView
        }
        didChangeText.append { [weak self] _ in self?.validate() }
    }
    
    @objc private func didTapTextfield() {
        onPress?()
        if canBecomeFirstResponder {
            becomeFirstResponder()
        }
    }
    
    @objc private func textFieldDidChange() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.didChangeText.forEach { $0(self.text) }
        })
    }
    
    private func updateTextFieldAppearance() {
        if isFirstResponder || validationRule != nil {
            layer.borderColor = selectedBorderColor.cgColor
            backgroundColor = selectedBackgroundColor
        } else {
            layer.borderColor = deselectedBorderColor.cgColor
            backgroundColor = deselectedBackgroundColor
        }
    }

    private func updatePlaceholder() {
        guard let placeholder = placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var padding = padding
        if let leftView = leftView {
            padding.left += leftView.frame.width + 6.67
        }
        if let rightView = rightView {
            padding.right += rightView.frame.width + 6.67
        }
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var padding = padding
        if let leftView = leftView {
            padding.left += leftView.frame.width + 6.67
        }
        if let rightView = rightView {
            padding.right += rightView.frame.width + 6.67
        }
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var padding = padding
        if let leftView = leftView {
            padding.left += leftView.frame.width + 6.67
        }
        if let rightView = rightView {
            padding.right += rightView.frame.width + 6.67
        }
        return bounds.inset(by: padding)
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        if validationRule == nil {
            UIView.animate(withDuration: 0.3, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
                self.layer.borderColor = self.selectedBorderColor.cgColor
                self.layer.borderWidth = self.selectedBorderWidth
                self.backgroundColor = self.selectedBackgroundColor
            }
        }
        
        if clearButtonTapped {
            clearButtonTapped = false
            return false
        }
        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
        if success {
            onBecomeFirstResponder?()
        }
        return success
    }
    
    open override func resignFirstResponder() -> Bool {
        if validationRule == nil {
            UIView.animate(withDuration: 0.3, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
                self.layer.borderColor = self.deselectedBorderColor.cgColor
                self.layer.borderWidth = self.idleBorderWidth
                self.backgroundColor = self.deselectedBackgroundColor
            }
        }
        let success = super.resignFirstResponder()
        if success {
            onResignFirstResponder?()
        }
        return success
    }
    
    override open var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }
    
    override open func caretRect(for position: UITextPosition) -> CGRect {
        return isTextSelectionDisabled ? .zero : super.caretRect(for: position)
    }
    
    override open func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return isTextSelectionDisabled ? [] : super.selectionRects(for: range)
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return isTextSelectionDisabled ? false : super.canPerformAction(action, withSender: sender)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        padding = .zero
        idleBorderWidth = 0.5
        selectedBorderWidth = 1.5
        deselectedBorderColor = .clear
        deselectedBackgroundColor = .clear
        super.init(coder: aDecoder)
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = super.clearButtonRect(forBounds: bounds)
        return bounds.inset(by: clearButtonEdgeInsets)
    }
}
#endif
