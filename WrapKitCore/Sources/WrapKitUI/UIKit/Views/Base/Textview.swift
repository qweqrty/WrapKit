//
//  Textview.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class Textview: UITextView, UITextViewDelegate {
    public var leadingViewOnPress: (() -> Void)? { didSet { applyAccessibility() } }
    public var trailingViewOnPress: (() -> Void)? { didSet { applyAccessibility() } }
    public var onPress: (() -> Void)? { didSet { applyAccessibility() } }
    public var onPaste: ((String?) -> Void)? { didSet { applyAccessibility() } }
    public var nextTextfield: UIResponder? = nil { didSet { returnKeyType = nextTextfield == nil ? .done : .next } }
    public var onBecomeFirstResponder: (() -> Void)? { didSet { applyAccessibility() } }
    public var onResignFirstResponder: (() -> Void)? { didSet { applyAccessibility() } }
    public var onTapBackspace: (() -> Void)? { didSet { applyAccessibility() } }
    
    public var didChangeText = [((String?) -> Void)]()
    
    private var padding: UIEdgeInsets
    private var isValidState = true
    
    public lazy var placeholderLabel = Label(font: font!, textColor: .gray)
    public var textDidChange: (() -> Void)?
    public var shouldChangeText: ((NSRange, String) -> Bool)?
    public var appearance: TextfieldAppearance { didSet { updateAppearance(); applyAccessibility() } }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if textAlignment != .center {
                textAlignment = semanticContentAttribute == .forceRightToLeft ? .right : .left
            }
            applyAccessibility()
        }
    }
    
    public init(
        appearance: TextfieldAppearance,
        cornerRadius: CGFloat = 10,
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
        self.layer.borderWidth = appearance.border?.idleBorderWidth ?? 0
        self.layer.cornerRadius = cornerRadius
        self.textContainerInset = contentInset
        self.delegate = self
        self.placeholderLabel.textColor = appearance.placeholder?.color
        self.placeholderLabel.font = appearance.placeholder?.font
        setupSubviews()
        setupConstraints()
        applyAccessibility()
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
        applyAccessibility()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return shouldChangeText?(range, text) ?? true
    }
    
    private func updatePlaceholder() {
        guard let customizedPlaceholder = appearance.placeholder else { return }
        placeholderLabel.textColor = customizedPlaceholder.color
        placeholderLabel.font = customizedPlaceholder.font
    }
    
    open override func paste(_ sender: Any?) {
        if let onPaste {
            onPaste(UIPasteboard.general.string)
            applyAccessibility()
        } else {
            super.paste(sender)
            applyAccessibility()
        }
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok { onBecomeFirstResponder?() }
        updateAppearance()
        applyAccessibility()
        return ok
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        if ok { onResignFirstResponder?() }
        updateAppearance()
        applyAccessibility()
        return ok
    }
    
    open override var isUserInteractionEnabled: Bool {
        didSet {
            textColor = isUserInteractionEnabled ? appearance.colors.textColor : appearance.colors.disabledTextColor
            backgroundColor = isUserInteractionEnabled ? appearance.colors.deselectedBackgroundColor : appearance.colors.disabledBackgroundColor
            if !isUserInteractionEnabled { resignFirstResponder() }
            applyAccessibility()
        }
    }
    
    // Optional: tap hook similar to your Textfield point(inside:) pattern
    // If you don't want this behaviour for TextView, remove it.
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onPress?()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
        applyAccessibility()
    }
}

// MARK: - Appearance
public extension Textview {
   
    func makeAccessoryView(
        model: TextInputPresentableModel.AccessoryViewPresentableModel?,
        onDoneTapped: ((Date) -> Void)? = nil
    ) -> UIView {
        guard let model else { return UIView() }
        let container = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: model.style.height
        ))
        container.backgroundColor = model.style.backgroundColor
        
        guard let toolbarModel = model.trailingButton else {
            return container
        }
        let trailingButton = Button()
        trailingButton.display(model: toolbarModel)
        trailingButton.onPress = { [weak self] in
            if let date = (self?.inputView as? UIDatePicker)?.date {
                onDoneTapped?(date)
            }
            toolbarModel.onPress?()
            self?.endEditing(true)
        }
        
        container.addSubview(trailingButton)
        trailingButton.translatesAutoresizingMaskIntoConstraints = false
    
        let defaultConstraints: (UIView, UIView) -> [NSLayoutConstraint] = { container, view in
            return [
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                view.heightAnchor.constraint(equalToConstant: model.trailingButton?.height ?? 36),
                view.widthAnchor.constraint(equalToConstant: model.trailingButton?.width ?? 80)
            ]
        }
        NSLayoutConstraint.activate((defaultConstraints)(container, trailingButton))
        return container
    }
    
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
        _ = (delegate as? MaskedTextfieldDelegate)?.fullText ?? text
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

// MARK: - TextInputOutput
extension Textview: TextInputOutput {
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        guard let inputAccessoryView else {
            self.inputAccessoryView = nil
            self.reloadInputViews()
            applyAccessibility()
            return
        }
        self.inputAccessoryView = makeAccessoryView(model: inputAccessoryView)
        self.reloadInputViews()
        applyAccessibility()
    }
    
    public func display(inputView: TextInputPresentableModel.InputView?) {
        guard let inputView else {
            self.inputView = nil
            self.reloadInputViews()
            applyAccessibility()
            return
        }
        switch inputView {
        case .date(let model):
            let picker = DatePickerView()
            picker.datePickerMode = picker.mapMode(model.mode)
            picker.date = model.value
            picker.minimumDate = model.minDate
            picker.maximumDate = model.maxDate
            picker.addAction(
                UIAction { _ in model.onChange?(picker.date) },
                for: .valueChanged
            )
            self.inputView = picker
            
            guard let accessoryView = model.accessoryView else {
                self.inputAccessoryView = nil
                applyAccessibility()
                return
            }
            self.inputAccessoryView = makeAccessoryView(model: accessoryView, onDoneTapped: model.onDoneTapped)
        case .custom(let model):
            let pickerView = PickerView()
            pickerView.display(model: model)
            self.inputView = pickerView
        }
        self.reloadInputViews()
        applyAccessibility()
    }
    
    public func startEditing() {
        becomeFirstResponder()
    }
    
    public func stopEditing() {
        resignFirstResponder()
    }
    
    public func display(model: TextInputPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        display(text: model.text)
        if let isValid = model.isValid {
            display(isValid: isValid)
            updateAppearance(isValid: isValid)
        }
        if let isEnabledForEditing = model.isEnabledForEditing { display(isEnabledForEditing: isEnabledForEditing) }
        if let isTextSelectionDisabled = model.isTextSelectionDisabled { display(isTextSelectionDisabled: isTextSelectionDisabled) }
        display(placeholder: model.placeholder)
        if let isUserInteractionEnabled = model.isUserInteractionEnabled { display(isUserInteractionEnabled: isUserInteractionEnabled) }
        if let isSecureTextEntry = model.isSecureTextEntry { display(isSecureTextEntry: isSecureTextEntry) }
        display(leadingViewOnPress: model.leadingViewOnPress)
        display(trailingViewOnPress: model.trailingViewOnPress)
        display(onPress: model.onPress)
        display(onPaste: model.onPaste)
        display(onBecomeFirstResponder: model.onBecomeFirstResponder)
        display(onResignFirstResponder: model.onResignFirstResponder)
        display(onTapBackspace: model.onTapBackspace)
        if let didChangeText = model.didChangeText {
            display(didChangeText: didChangeText)
        }
        display(trailingSymbol: model.trailingSymbol)
        display(inputAccessoryView: model.inputAccessoryView)
        display(inputView: model.inputView)
        
        applyAccessibility()
    }
    
    public func display(text: String?) {
        let decodedText = text?.removingPercentEncoding ?? text ?? ""
        self.text = decodedText
        placeholderLabel.isHidden = !decodedText.isEmpty
        applyAccessibility()
    }
    
    public func display(mask: TextInputPresentableModel.Mask) { }
    public func display(isValid: Bool) { isValidState = isValid; applyAccessibility() }
    public func display(isEnabledForEditing: Bool) { applyAccessibility() }
    public func display(isTextSelectionDisabled: Bool) { applyAccessibility() }
    
    public func display(placeholder: String?) {
        self.placeholderLabel.text = placeholder
        applyAccessibility()
    }
    
    public func display(isUserInteractionEnabled: Bool) {
        self.isUserInteractionEnabled = isUserInteractionEnabled
        applyAccessibility()
    }
    
    public func display(isSecureTextEntry: Bool) {
        self.isSecureTextEntry = isSecureTextEntry
        applyAccessibility()
    }
    
    public func display(leadingViewOnPress: (() -> Void)?) {
        self.leadingViewOnPress = leadingViewOnPress
        applyAccessibility()
    }
    
    public func display(trailingViewOnPress: (() -> Void)?) {
        self.trailingViewOnPress = trailingViewOnPress
        applyAccessibility()
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
        applyAccessibility()
    }
    
    public func display(leadingViewIsHidden: Bool) { applyAccessibility() }
    public func display(trailingViewIsHidden: Bool) { applyAccessibility() }
    
    public func display(onPaste: ((String?) -> Void)?) {
        self.onPaste = onPaste
        applyAccessibility()
    }
    
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        self.onBecomeFirstResponder = onBecomeFirstResponder
        applyAccessibility()
    }
    
    public func display(onResignFirstResponder: (() -> Void)?) {
        self.onResignFirstResponder = onResignFirstResponder
        applyAccessibility()
    }
    
    public func display(onTapBackspace: (() -> Void)?) {
        self.onTapBackspace = onTapBackspace
        applyAccessibility()
    }
    
    public func display(didChangeText: [((String?) -> Void)]) {
        self.didChangeText = didChangeText
        applyAccessibility()
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
        applyAccessibility()
    }

    public func display(inputType: KeyboardType) {
        self.keyboardType = UIKeyboardType(rawValue: inputType.rawValue) ?? .default
        applyAccessibility()
    }
    
    public func display(trailingSymbol: String?) {}
    public func display(isClearButtonActive: Bool) { }
}

// MARK: - Accessibility (automatic summary + actions)
private extension Textview {
    func applyAccessibility() {
        guard UIAccessibility.isVoiceOverRunning else { return }
        // UITextView - редактируемый элемент по умолчанию
        isAccessibilityElement = true
        accessibilityHint = nil

        // label: placeholder или текст (без локализации)
        accessibilityLabel = accessibilityTextSummaryForSelf()

        // traits: если disabled -> notEnabled
        var traits = accessibilityTraits
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            traits.insert(.notEnabled)
        } else {
            traits.remove(.notEnabled)
        }
        accessibilityTraits = traits

        // custom actions: leading/trailing (т.к. у textview нет встроенных view, только closures)
        updateAccessibilityCustomActions()
    }

    func accessibilityTextSummaryForSelf(maxLen: Int = 140) -> String? {
        let txt = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !txt.isEmpty { return String(txt.prefix(maxLen)) }
        let ph = (placeholderLabel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return ph.isEmpty ? nil : String(ph.prefix(maxLen))
    }

    func updateAccessibilityCustomActions() {
        var actions: [UIAccessibilityCustomAction] = []

        if isLeadingActionAvailable {
            actions.append(UIAccessibilityCustomAction(name: "Leading", target: self, selector: #selector(a11yTapLeading)))
        }
        if isTrailingActionAvailable {
            actions.append(UIAccessibilityCustomAction(name: "Trailing", target: self, selector: #selector(a11yTapTrailing)))
        }

        accessibilityCustomActions = actions.isEmpty ? nil : actions
    }

    var isLeadingActionAvailable: Bool {
        isUserInteractionEnabled && !isHidden && alpha > 0.01 && leadingViewOnPress != nil
    }

    var isTrailingActionAvailable: Bool {
        isUserInteractionEnabled && !isHidden && alpha > 0.01 && trailingViewOnPress != nil
    }

    @objc func a11yTapLeading() -> Bool {
        leadingViewOnPress?()
        return true
    }

    @objc func a11yTapTrailing() -> Bool {
        trailingViewOnPress?()
        return true
    }
}
#endif
