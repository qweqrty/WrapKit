//
//  Textfield.swift
//  WrapKit
//
//  Created by Stanislav Li on 8/12/23.
//

#if canImport(UIKit)
import UIKit

open class Textfield: UITextField {
    public enum TrailingViewStyle {
        case clear(trailingView: View)
        case custom(trailingView: UIView)
    }
    
    public struct Placeholder {
        public init(color: UIColor, font: UIFont, text: String? = nil) {
            self.color = color
            self.font = font
            self.text = text
        }
        
        public var color: UIColor
        public var font: UIFont
        public var text: String?
    }
    
    public struct Appearance {
        public init(colors: Textfield.Appearance.Colors, font: UIFont, border: Textfield.Appearance.Border? = nil) {
            self.colors = colors
            self.font = font
            self.border = border
        }
        
        public struct Colors {
            public init(textColor: UIColor, selectedBorderColor: UIColor, selectedBackgroundColor: UIColor, errorBorderColor: UIColor, errorBackgroundColor: UIColor, deselectedBorderColor: UIColor, deselectedBackgroundColor: UIColor) {
                self.textColor = textColor
                self.selectedBorderColor = selectedBorderColor
                self.selectedBackgroundColor = selectedBackgroundColor
                self.errorBorderColor = errorBorderColor
                self.errorBackgroundColor = errorBackgroundColor
                self.deselectedBorderColor = deselectedBorderColor
                self.deselectedBackgroundColor = deselectedBackgroundColor
            }
            
            public var textColor: UIColor
            public var selectedBorderColor: UIColor
            public var selectedBackgroundColor: UIColor
            public var errorBorderColor: UIColor
            public var errorBackgroundColor: UIColor
            public var deselectedBorderColor: UIColor
            public var deselectedBackgroundColor: UIColor
        }
        public struct Border {
            public init(idleBorderWidth: CGFloat, selectedBorderWidth: CGFloat) {
                self.idleBorderWidth = idleBorderWidth
                self.selectedBorderWidth = selectedBorderWidth
            }
            
            public var idleBorderWidth: CGFloat
            public var selectedBorderWidth: CGFloat
        }
        
        public var colors: Colors
        public var font: UIFont
        public var border: Border?
    }
    
    private var leadingStackView = StackView()
    private var trailingStackView = StackView()
    
    public var leadingView: UIView? {
        didSet {
            leadingStackView.removeAllArrangedSubviews()
            setupLeadingView()
        }
    }
    public var trailingView: UIView? {
        didSet {
            trailingStackView.removeAllArrangedSubviews()
            setupTrailingView()
        }
    }
    
    public var padding: UIEdgeInsets = .zero
    public var clearButtonEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
    
    public var isTextSelectionDisabled = false
    public var isEditable = true
    
    public var onPress: (() -> Void)?
    public var validationRule: ((String?) -> Bool)?
    public var nextTextfield: UIResponder? = nil { didSet { returnKeyType = nextTextfield == nil ? .done : .next } }
    public var onBecomeFirstResponder: (() -> Void)?
    public var onResignFirstResponder: (() -> Void)?
    
    public var didChangeText = [((String?) -> Void)]()
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.2
    
    @discardableResult
    public func validate() -> Bool {
        let text = (delegate as? MaskedTextfieldDelegate)?.fullText ?? text
        updateAppearence()
        return validationRule?(text) ?? true
    }
    
    open override var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    open override var text: String? {
        didSet {
            if let delegate = delegate as? MaskedTextfieldDelegate {
                delegate.fullText = text ?? ""
            }
        }
    }
    
    public var maskedTextfieldDelegate: MaskedTextfieldDelegate? {
        didSet {
            maskedTextfieldDelegate?.applyTo(textfield: self)
        }
    }
    
    public var appearence: Appearance { didSet { updateAppearence() }}
    public var customizedPlaceholder: Placeholder? { didSet { updatePlaceholder() }}
    
    public init(
        cornerRadius: CGFloat = 10,
        textAlignment: NSTextAlignment = .natural,
        appearence: Appearance,
        placeholder: Placeholder?,
        padding: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12),
        nextTextfield: UIResponder? = nil,
        leadingView: UIView? = nil,
        trailingView: TrailingViewStyle? = nil,
        inputView: UIView? = nil,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        delegate: MaskedTextfieldDelegate? = nil
    ) {
        self.padding = padding
        self.nextTextfield = nextTextfield
        self.appearence = appearence
        self.customizedPlaceholder = placeholder
        super.init(frame: .zero)

        self.textAlignment = textAlignment
        self.cornerRadius = cornerRadius
        self.autocorrectionType = .no
        self.textColor = appearence.colors.textColor
        self.autocapitalizationType = .none
        self.inputView = inputView
        maskedTextfieldDelegate = delegate
        delegate?.applyTo(textfield: self)
        returnKeyType = nextTextfield == nil ? .done : .next
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextfield))
        addGestureRecognizer(tapGesture)
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        self.leadingView = leadingView
        didChangeText.append { [weak self] _ in self?.validate() }
        
        addSubviews(leadingStackView, trailingStackView)
        leadingStackView.anchor(
            .top(topAnchor, constant: padding.top),
            .leading(leadingAnchor, constant: padding.left),
            .bottom(bottomAnchor, constant: padding.bottom)
        )
        
        trailingStackView.anchor(
            .top(topAnchor, constant: padding.top),
            .trailing(trailingAnchor, constant: padding.right),
            .bottom(bottomAnchor, constant: padding.bottom)
        )
        updateAppearence()
        
        switch trailingView {
        case .custom(let trailingView):
            self.trailingView = trailingView
        case .clear(let trailingView):
            self.onPress = { [weak self] in self?.text = "" }
            self.didChangeText.append { [weak self] text in
                let text = self?.maskedTextfieldDelegate?.onlySpecifiersIfMaskedText ?? text ?? ""
                self?.trailingView?.isHidden = text.isEmpty
            }
            self.trailingView = trailingView
            trailingView.isHidden = text?.isEmpty ?? true
        default:
            break
        }
        setupLeadingView()
        setupTrailingView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            self.didChangeText.forEach {
                if let delegate = self.delegate as? MaskedTextfieldDelegate {
                    $0(delegate.fullText)
                } else {
                    $0(self.text)
                }
            }
        })
    }
    
    private func updatePlaceholder() {
        guard let customizedPlaceholder = customizedPlaceholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: customizedPlaceholder.text ?? placeholder ?? "",
            attributes: [
                NSAttributedString.Key.foregroundColor: customizedPlaceholder.color,
                NSAttributedString.Key.font: customizedPlaceholder.font
            ]
        )
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return textArea(for: bounds)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textArea(for: bounds)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textArea(for: bounds)
    }
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
        updateAppearence()
        return success
    }
    
    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateAppearence()
        return result
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
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = super.clearButtonRect(forBounds: bounds)
        return bounds.inset(by: clearButtonEdgeInsets)
    }
    
    private func textArea(for bounds: CGRect) -> CGRect {
        var padding = padding
        if let leftView = leadingView, !leftView.isHidden {
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                padding.right += leftView.intrinsicContentSize.width + 6.67
            } else {
                padding.left += leftView.intrinsicContentSize.width + 6.67
            }
        }
        if let rightView = trailingView, !rightView.isHidden {
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                padding.left += rightView.intrinsicContentSize.width + 6.67
            } else {
                padding.right += rightView.intrinsicContentSize.width + 6.67
            }
        }
        return bounds.inset(by: padding)
    }
    
    func setupTrailingView() {
        guard let trailingView = trailingView else { return }
        trailingStackView.addArrangedSubview(trailingView)
    }
    
    func setupLeadingView() {
        guard let leadingView = leadingView else { return }
        leadingStackView.addArrangedSubview(leadingView)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateAppearence()
    }
}

public extension Textfield {
    func applyNormalState() {
        backgroundColor = isFirstResponder ? appearence.colors.selectedBackgroundColor : appearence.colors.deselectedBackgroundColor
        layer.borderColor = isFirstResponder ? appearence.colors.selectedBorderColor.cgColor : appearence.colors.deselectedBorderColor.cgColor
    }
    
    func applyErrorState() {
        backgroundColor = appearence.colors.errorBackgroundColor
        layer.borderColor = appearence.colors.errorBorderColor.cgColor
    }
    
    private func updateAppearence() {
        font = appearence.font
        let text = (delegate as? MaskedTextfieldDelegate)?.fullText ?? text
        let isValid = validationRule?(text) ?? true
        let isFirstResponder = isFirstResponder
        let appearence = appearence
        UIView.animate(withDuration: 0.1, delay: .leastNonzeroMagnitude, options: [.allowUserInteraction]) {
            if isValid {
                self.backgroundColor = isFirstResponder ? appearence.colors.selectedBackgroundColor : appearence.colors.deselectedBackgroundColor
                self.layer.borderColor = isFirstResponder ? appearence.colors.selectedBorderColor.cgColor : appearence.colors.deselectedBorderColor.cgColor
            } else {
                self.backgroundColor = appearence.colors.errorBackgroundColor
                self.layer.borderColor = appearence.colors.errorBorderColor.cgColor
            }
            self.layer.borderWidth = (isFirstResponder ? appearence.border?.selectedBorderWidth : appearence.border?.idleBorderWidth) ?? 0
        }
    }
}
#endif
