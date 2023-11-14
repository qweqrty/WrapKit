////
////  Textfield.swift
////  WrapKit
////
////  Created by Stas Lee on 6/8/23.
////
//
//#if canImport(UIKit)
//import UIKit
//
//open class Textfield: UITextField {
//    private var padding: UIEdgeInsets
//
//    public var idleColor: UIColor = .gray
//    public var editingColor: UIColor = .black
//    public var clearButtonEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
//    public var clearButtonTapped = false
//    private var regexRules = Set<String>()
//    
//    public var isRequired: Bool = false {
//        didSet {
//            handleRule(regex: String.nonEmptyRegex, apply: isRequired)
//        }
//    }
//    
//    public var onlyDigits: Bool = false {
//        didSet {
//            handleRule(regex: String.onlyDigitsRegex, apply: onlyDigits)
//        }
//    }
//    
//    private func handleRule(regex: String, apply: Bool) {
//        if apply {
//            regexRules.insert(regex)
//        } else {
//            regexRules.remove(regex)
//        }
//    }
//
//    public var isTextSelectionDisabled = false
//    public var isEditable = true
//    public var onPress: (() -> Void)?
//    public var didChangeText = [((String?) -> Void)]()
//
//    public var nextTextfield: UIResponder? = nil {
//        didSet {
//            returnKeyType = nextTextfield == nil ? .done : .next
//        }
//    }
//    
//    @discardableResult
//    func validate() -> Bool {
//        guard !regexRules.isEmpty else {
////            applyNormalState()
//            return true
//        }
//        let text = text ?? ""
//        let isValid = regexRules.reduce(true) { prev, regex in
//            return prev && text.range(of: regex, options: .regularExpression) != nil
//        }
////        isValid ? applyNormalState() : applyErrorState()
//        return isValid
//    }
//    
//    open override var placeholder: String? {
//        didSet {
//            attributedPlaceholder = NSAttributedString(
//                string: placeholder ?? "",
//                attributes:[
//                    NSAttributedString.Key.foregroundColor: UIColor.gray
//                ]
//            )
//        }
//    }
//    
//    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//        guard let view = rightView else { return super.rightViewRect(forBounds: bounds) }
//        var textRect = super.rightViewRect(forBounds: bounds)
//        textRect.origin.x -= view.frame.width / 2
//        return textRect
//    }
//    
//    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//        var textRect = super.leftViewRect(forBounds: bounds)
//        textRect.origin.x += padding.left
//        return textRect
//    }
//    
//    open override var rightView: UIView? {
//        didSet {
//            guard rightView != nil else { return }
//            rightViewMode = .always
//        }
//    }
//    
//    open override var leftView: UIView? {
//        didSet {
//            guard leftView != nil else { return }
//            leftViewMode = .always
//        }
//    }
//    
//    public init(
//        font: UIFont = .systemFont(ofSize: 16),
//        textColor: UIColor = .black,
//        backgroundColor: UIColor = .lightGray,
//        cornerRadius: CGFloat = 10,
//        borderWidth: CGFloat = 0.5,
//        borderColor: UIColor = .gray,
//        padding: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12),
//        nextTextfield: UIResponder? = nil,
//        leadingView: UIView? = nil,
//        trailingView: UIView? = nil
//    ) {
//        self.padding = padding
//        self.nextTextfield = nextTextfield
//        super.init(frame: .zero)
//
//        self.delegate = self
//        self.autocorrectionType = .no
//        self.font = font
//        self.textColor = textColor
//        self.backgroundColor = backgroundColor
//        self.layer.borderWidth = borderWidth
//        self.layer.cornerRadius = cornerRadius
//        self.layer.borderColor = borderColor.cgColor
//        self.autocapitalizationType = .none
//        returnKeyType = nextTextfield == nil ? .done : .next
//        
//        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//
//        if let leadingView = leadingView {
//            leftViewMode = .always
//            leftView = leadingView
//        } else if let trailingView = trailingView {
//            rightViewMode = .always
//            rightView = trailingView
//        }
//    }
//    
//    @objc private func textFieldDidChange(textField: UITextField) {
////        applyNormalState()
//        didChangeText.forEach { $0(textField.text) }
//    }
//    
//    override open func textRect(forBounds bounds: CGRect) -> CGRect {
//        var padding = padding
//        if let leftView = leftView {
//            padding.left += leftView.frame.width + 6.67
//        }
//        if let rightView = rightView {
//            padding.right += rightView.frame.width + 6.67
//        }
//        return bounds.inset(by: padding)
//    }
//    
//    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        var padding = padding
//        if let leftView = leftView {
//            padding.left += leftView.frame.width + 6.67
//        }
//        if let rightView = rightView {
//            padding.right += rightView.frame.width + 6.67
//        }
//        return bounds.inset(by: padding)
//    }
//    
//    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
//        var padding = padding
//        if let leftView = leftView {
//            padding.left += leftView.frame.width + 6.67
//        }
//        if let rightView = rightView {
//            padding.right += rightView.frame.width + 6.67
//        }
//        return bounds.inset(by: padding)
//    }
//    
//    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        onPress?()
//        return isEditable
//    }
//    
//    @discardableResult
//    override open func becomeFirstResponder() -> Bool {
//        if clearButtonTapped {
//            clearButtonTapped = false
//            return false
//        }
//        let success = super.becomeFirstResponder()
//        if isSecureTextEntry, let text = self.text {
//            self.text?.removeAll()
//            insertText(text)
//        }
//        return success
//    }
//    
//    override open var isSecureTextEntry: Bool {
//        didSet {
//            if isFirstResponder {
//                _ = becomeFirstResponder()
//            }
//        }
//    }
//    
//    open func setPadding(_ padding: UIEdgeInsets) {
//        self.padding = padding
//    }
//    
//    open func getPadding() -> UIEdgeInsets {
//        return self.padding
//    }
//    
//    override open func caretRect(for position: UITextPosition) -> CGRect {
//        return isTextSelectionDisabled ? .zero : super.caretRect(for: position)
//    }
//    
//    override open func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
//        return isTextSelectionDisabled ? [] : super.selectionRects(for: range)
//    }
//
//    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return isTextSelectionDisabled ? false : super.canPerformAction(action, withSender: sender)
//    }
//    
//    public required init?(coder aDecoder: NSCoder) {
//        padding = .zero
//        super.init(coder: aDecoder)
//    }
//    
//    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
//        let bounds = super.clearButtonRect(forBounds: bounds)
//        return bounds.inset(by: clearButtonEdgeInsets)
//    }
//}
//
//extension Textfield: UITextFieldDelegate {
//    open func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.layer.borderColor = editingColor.cgColor
//        textField.layer.borderWidth = 1.5
//    }
//    
//    open func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.layer.borderColor = idleColor.cgColor
//        textField.layer.borderWidth = 0.5
//    }
//    
//}
//#endif
