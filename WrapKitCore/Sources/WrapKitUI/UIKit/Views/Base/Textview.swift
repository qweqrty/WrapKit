//
//  Textview.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class Textview: UITextView, UITextViewDelegate {
    public var leadingViewOnPress: (() -> Void)?
    public var trailingViewOnPress: (() -> Void)?
    public var onPress: (() -> Void)?
    public var onPaste: ((String?) -> Void)?
    public var nextTextfield: UIResponder? = nil { didSet { returnKeyType = nextTextfield == nil ? .done : .next } }
    public var onBecomeFirstResponder: (() -> Void)?
    public var onResignFirstResponder: (() -> Void)?
    public var onTapBackspace: (() -> Void)?
    
    public var didChangeText = [((String?) -> Void)]()
    
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
        placeholderLabel.textColor = customizedPlaceholder.color
        placeholderLabel.font = customizedPlaceholder.font
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }
}

public extension Textview {
   
    func makeAccessoryView(
        model: TextInputPresentableModel.AccessoryViewPresentableModel?
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

extension Textview: TextInputOutput {
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        guard let inputAccessoryView else {
            self.inputAccessoryView = nil
            self.reloadInputViews()
            return
        }
        self.inputAccessoryView = makeAccessoryView(model: inputAccessoryView)
        self.reloadInputViews()
    }
    
    public func display(inputView: TextInputPresentableModel.InputView?) {
        guard let inputView else {
            self.inputView = nil
            self.reloadInputViews()
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
            
            guard let accessoryView = model.accessoryView else { return }
            self.inputAccessoryView = makeAccessoryView(model: accessoryView)
        case .custom(let model):
            let pickerView = PickerView()
            pickerView.display(model: model)
            self.inputView = pickerView
        }
        self.reloadInputViews()
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
    }
    
    public func display(text: String?) {
        let decodedText = text?.removingPercentEncoding ?? ""
        self.text = decodedText
        placeholderLabel.isHidden = !decodedText.isEmpty
    }
    
    public func display(mask: TextInputPresentableModel.Mask) { }
    public func display(isValid: Bool) {
        isValidState = isValid
    }
    
    public func display(isEnabledForEditing: Bool) { }
    public func display(isTextSelectionDisabled: Bool) { }
    public func display(placeholder: String?) {
        self.placeholderLabel.text = placeholder
    }
    
    public func display(isUserInteractionEnabled: Bool) {
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    public func display(isSecureTextEntry: Bool) {
        self.isSecureTextEntry = isSecureTextEntry
    }
    
    public func display(leadingViewOnPress: (() -> Void)?) {
        self.leadingViewOnPress = leadingViewOnPress
    }
    
    public func display(trailingViewOnPress: (() -> Void)?) {
        self.trailingViewOnPress = trailingViewOnPress
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(leadingViewIsHidden: Bool) {

    }
    
    public func display(trailingViewIsHidden: Bool) {
        
    }
    
    public func display(onPaste: ((String?) -> Void)?) {
        self.onPaste = onPaste
    }
    
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        self.onBecomeFirstResponder = onBecomeFirstResponder
    }
    
    public func display(onResignFirstResponder: (() -> Void)?) {
        self.onResignFirstResponder = onResignFirstResponder
    }
    
    public func display(onTapBackspace: (() -> Void)?) {
        self.onTapBackspace = onTapBackspace
    }
    
    public func display(didChangeText: [((String?) -> Void)]) {
        self.didChangeText = didChangeText
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }

    public func display(inputType: KeyboardType) {
        self.keyboardType = UIKeyboardType(rawValue: inputType.rawValue) ?? .default
    }
    
    public func display(trailingSymbol: String?) {}
    public func display(isClearButtonActive: Bool) { }
}

public extension Textview {
    func makeAccessoryView(
        accessoryView: UIView,
        height: CGFloat = 60,
        constraints: ((UIView, UIView) -> [NSLayoutConstraint])? = nil
    ) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        container.backgroundColor = .systemGroupedBackground
        
        container.addSubview(accessoryView)
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
    
        let defaultConstraints: (UIView, UIView) -> [NSLayoutConstraint] = { container, view in
            return [
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                view.heightAnchor.constraint(equalToConstant: 36),
                view.widthAnchor.constraint(equalToConstant: 80)
            ]
        }
        NSLayoutConstraint.activate((constraints ?? defaultConstraints)(container, accessoryView))
        return container
    }
}
#endif
