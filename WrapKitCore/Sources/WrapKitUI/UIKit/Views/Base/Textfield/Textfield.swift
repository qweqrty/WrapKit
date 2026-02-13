//
//  Textfield.swift
//  WrapKit
//
//  Created by Stanislav Li on 8/12/23.
//

import Foundation

public enum TextAutocapitalizationType {
    case none
    case words
    case sentences
    case allCharacters
}

public struct TextfieldAppearance {
    public init(
        colors: TextfieldAppearance.Colors,
        font: Font,
        border: TextfieldAppearance.Border? = nil,
        placeholder: TextfieldAppearance.Placeholder? = nil
    ) {
        self.colors = colors
        self.font = font
        self.border = border
        self.placeholder = placeholder
    }
    
    public struct Colors {
        public init(
            textColor: Color,
            selectedBorderColor: Color,
            selectedBackgroundColor: Color,
            selectedErrorBorderColor: Color,
            errorBorderColor: Color,
            errorBackgroundColor: Color,
            deselectedBorderColor: Color,
            deselectedBackgroundColor: Color,
            disabledTextColor: Color,
            disabledBackgroundColor: Color
        ) {
            self.textColor = textColor
            self.selectedBorderColor = selectedBorderColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.selectedErrorBorderColor = selectedErrorBorderColor
            self.errorBorderColor = errorBorderColor
            self.errorBackgroundColor = errorBackgroundColor
            self.deselectedBorderColor = deselectedBorderColor
            self.deselectedBackgroundColor = deselectedBackgroundColor
            self.disabledTextColor = disabledTextColor
            self.disabledBackgroundColor = disabledBackgroundColor
        }
        
        public var textColor: Color
        public var selectedBorderColor: Color
        public var selectedBackgroundColor: Color
        public var errorBorderColor: Color
        public var selectedErrorBorderColor: Color
        public var errorBackgroundColor: Color
        public var deselectedBorderColor: Color
        public var deselectedBackgroundColor: Color
        public var disabledTextColor: Color
        public var disabledBackgroundColor: Color
    }
    public struct Border {
        public init(idleBorderWidth: CGFloat, selectedBorderWidth: CGFloat) {
            self.idleBorderWidth = idleBorderWidth
            self.selectedBorderWidth = selectedBorderWidth
        }
        
        public var idleBorderWidth: CGFloat
        public var selectedBorderWidth: CGFloat
    }
    public struct Placeholder {
        public init(color: Color, disabledColor: Color? = nil, font: Font, text: String? = nil) {
            self.color = color
            self.disabledColor = disabledColor
            self.font = font
            self.text = text
        }
        
        public var color: Color
        public var disabledColor: Color?
        public var font: Font
        public var text: String?
    }
    
    public var colors: Colors
    public var font: Font
    public var border: Border?
    public var placeholder: Placeholder?
}

public protocol TextInputOutput: AnyObject {
    func display(model: TextInputPresentableModel?)
    func display(text: String?)
    func startEditing()
    func stopEditing()
    func display(mask: TextInputPresentableModel.Mask)
    func display(isValid: Bool)
    func display(isEnabledForEditing: Bool)
    func display(isTextSelectionDisabled: Bool)
    func display(placeholder: String?)
    func display(isUserInteractionEnabled: Bool)
    func display(isSecureTextEntry: Bool)
    func display(leadingViewOnPress: (() -> Void)?)
    func display(trailingViewOnPress: (() -> Void)?)
    func display(onPress: (() -> Void)?)
    func display(onPaste: ((String?) -> Void)?)
    func display(onBecomeFirstResponder: (() -> Void)?)
    func display(onResignFirstResponder: (() -> Void)?)
    func display(onTapBackspace: (() -> Void)?)
    func display(didChangeText: [((String?) -> Void)])
    func display(trailingViewIsHidden: Bool)
    func display(leadingViewIsHidden: Bool)
    func display(isHidden: Bool)
    func display(inputView: TextInputPresentableModel.InputView?)
    func display(inputType: KeyboardType)
    func display(trailingSymbol: String?)
    func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?)
    func display(isClearButtonActive: Bool)
}

public struct TextInputPresentableModel: HashableWithReflection {
    public struct AccessoryViewPresentableModel: HashableWithReflection {
        public struct Style {
            public let height: CGFloat
            public let backgroundColor: Color
            
            public init(height: CGFloat = 48, backgroundColor: Color = .clear) {
                self.height = height
                self.backgroundColor = backgroundColor
            }
        }
        
        public let style: Style
        public let trailingButton: ButtonPresentableModel?
        
        public init(
            style: Style = .init(),
            trailingButton: ButtonPresentableModel? = nil
        ) {
            self.style = style
            self.trailingButton = trailingButton
        }
    }
    
    public enum InputView {
        public struct DatePickerPresentableModel {
            public let accessoryView: AccessoryViewPresentableModel?
            public let mode: DatePickerMode
            public let value: Date
            public let minDate: Date?
            public let maxDate: Date?
            public let onChange: ((Date) -> Void)?
            public let onDoneTapped: ((Date) -> Void)?
            
            public init(
                minDate: Date? = nil,
                maxDate: Date? = nil,
                mode: DatePickerMode = .date,
                value: Date = Date(),
                accessoryView: AccessoryViewPresentableModel? = nil,
                onChange: ((Date) -> Void)? = nil,
                onDoneTapped: ((Date) -> Void)? = nil
            ) {
                self.mode = mode
                self.value = value
                self.onChange = onChange
                self.accessoryView = accessoryView
                self.minDate = minDate
                self.maxDate = maxDate
                self.onDoneTapped = onDoneTapped
            }
        }
        case date(DatePickerPresentableModel)
        case custom(PickerViewPresentableModel)
    }
    
    public struct Mask {
        public let mask: Masking
        public let maskColor: Color
        
        public init(mask: Masking, maskColor: Color) {
            self.mask = mask
            self.maskColor = maskColor
        }
    }
    
    public let accessibilityIdentifier: String?
    public let mask: Mask?
    public let text: String?
    public let isValid: Bool?
    public let isEnabledForEditing: Bool?
    public let isTextSelectionDisabled: Bool?
    public let placeholder: String?
    public let isUserInteractionEnabled: Bool?
    public let isSecureTextEntry: Bool?
    public let inputView: InputView?
    public let inputAccessoryView: AccessoryViewPresentableModel?
    public let trailingSymbol: String?
    public let autocapitalizationType: TextAutocapitalizationType?
    public let inputType: KeyboardType?
    public var leadingViewOnPress: (() -> Void)?
    public var trailingViewOnPress: (() -> Void)?
    public var onPress: (() -> Void)?
    public var onPaste: ((String?) -> Void)?
    public var onBecomeFirstResponder: (() -> Void)?
    public var onResignFirstResponder: (() -> Void)?
    public var onTapBackspace: (() -> Void)?
    public var didChangeText: [((String?) -> Void)]?
    
    public init(
        accessibilityIdentifier: String? = nil,
        text: String? = nil,
        mask: Mask? = nil,
        isValid: Bool? = nil,
        isEnabledForEditing: Bool? = nil,
        isTextSelectionDisabled: Bool? = nil,
        placeholder: String? = nil,
        isUserInteractionEnabled: Bool? = nil,
        isSecureTextEntry: Bool? = nil,
        inputView: InputView? = nil,
        inputAccessoryView: AccessoryViewPresentableModel? = nil,
        trailingSymbol: String? = nil,
        autocapitalizationType: TextAutocapitalizationType = .none,
        inputType: KeyboardType? = nil,
        leadingViewOnPress: (() -> Void)? = nil,
        trailingViewOnPress: (() -> Void)? = nil,
        onPress: (() -> Void)? = nil,
        onPaste: ((String?) -> Void)? = nil,
        onBecomeFirstResponder: (() -> Void)? = nil,
        onResignFirstResponder: (() -> Void)? = nil,
        onTapBackspace: (() -> Void)? = nil,
        didChangeText: [(String?) -> Void]? = nil
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.text = text
        self.mask = mask
        self.isValid = isValid
        self.isEnabledForEditing = isEnabledForEditing
        self.isTextSelectionDisabled = isTextSelectionDisabled
        self.placeholder = placeholder
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.isSecureTextEntry = isSecureTextEntry
        self.leadingViewOnPress = leadingViewOnPress
        self.trailingViewOnPress = trailingViewOnPress
        self.onPress = onPress
        self.onPaste = onPaste
        self.onBecomeFirstResponder = onBecomeFirstResponder
        self.onResignFirstResponder = onResignFirstResponder
        self.onTapBackspace = onTapBackspace
        self.didChangeText = didChangeText
        self.inputView = inputView
        self.trailingSymbol = trailingSymbol
        self.inputAccessoryView = inputAccessoryView
        self.autocapitalizationType = autocapitalizationType
        self.inputType = inputType
    }
}

#if canImport(UIKit)
import UIKit

// MARK: - UIView Accessibility helpers (automatic summary)
private extension UIView {
    var isVisiblyInteractable: Bool {
        !isHidden && alpha > 0.01 && isUserInteractionEnabled
    }

    func accessibilityTextSummary(maxLen: Int = 80) -> String? {
        if let label = accessibilityLabel?.trimmingCharacters(in: .whitespacesAndNewlines),
           !label.isEmpty {
            return String(label.prefix(maxLen))
        }

        if let l = self as? UILabel,
           let t = l.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !t.isEmpty {
            return String(t.prefix(maxLen))
        }

        if let tf = self as? UITextField {
            let t = (tf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            if !t.isEmpty { return String(t.prefix(maxLen)) }
            let p = (tf.placeholder?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
            if !p.isEmpty { return String(p.prefix(maxLen)) }
        }

        if let tv = self as? UITextView,
           let t = tv.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !t.isEmpty {
            return String(t.prefix(maxLen))
        }

        var parts: [String] = []
        for v in subviews where v.isVisiblyInteractable {
            if let s = v.accessibilityTextSummary(maxLen: maxLen), !s.isEmpty {
                parts.append(s)
            }
        }

        let result = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return result.isEmpty ? nil : String(result.prefix(maxLen))
    }
}

public extension Textfield {
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
}

extension Textfield: TextInputOutput {
   
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {
        guard let inputAccessoryView else {
            self.inputAccessoryView = nil
            self.reloadInputViews()
            invalidateA11y()
            return
        }
        self.inputAccessoryView = makeAccessoryView(model: inputAccessoryView)
        self.reloadInputViews()
        invalidateA11y()
    }
    
    public func startEditing() {
        becomeFirstResponder()
    }
    
    public func stopEditing() {
        resignFirstResponder()
    }
    
    public func display(model: TextInputPresentableModel?) {
        isHidden = model == nil
        
        if let accessibilityIdentifier = model?.accessibilityIdentifier {
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        guard let model = model else { return }
        
        if isFirstResponder {
            if let text = model.text {
                display(text: text)
            }
            if let isValid = model.isValid {
                display(isValid: isValid)
            }
            return
        }
        
        if let mask = model.mask {
            maskedTextfieldDelegate = .init(format: .init(mask: mask.mask, maskedTextColor: mask.maskColor))
        }
        display(text: model.text)
        if let isValid = model.isValid { display(isValid: isValid) }
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
        
        display(inputAccessoryView: model.inputAccessoryView)
        display(inputView: model.inputView)
        display(trailingSymbol: model.trailingSymbol)
        
        if model.inputAccessoryView == nil, model.inputView == nil {
            self.inputAccessoryView = nil
            self.reloadInputViews()
        }
        if let type = model.autocapitalizationType {
            self.autocapitalizationType = type.asUITextAutocapitalizationType
        }
        
        if let inputType = model.inputType {
            display(inputType: inputType)
        }
        
        invalidateA11y()
    }
    
    public func display(inputView: TextInputPresentableModel.InputView?) {
        guard let inputView else {
            self.inputView = nil
            self.reloadInputViews()
            invalidateA11y()
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
                invalidateA11y()
                return
            }
            self.inputAccessoryView = makeAccessoryView(model: accessoryView, onDoneTapped: model.onDoneTapped)
        case .custom(let model):
            let pickerView = PickerView()
            pickerView.display(model: model)
            self.inputView = pickerView
        }
        self.reloadInputViews()
        invalidateA11y()
    }
    
    public func display(text: String?) {
        let newText = text?.removingPercentEncoding ?? text ?? ""
        
        let currentText: String
        if let maskedDelegate = maskedTextfieldDelegate {
            currentText = maskedDelegate.fullText
        } else {
            currentText = self.text ?? ""
        }
        
        guard currentText != newText else { return }
        
        self.text = newText
        invalidateA11y()
    }
    
    public func display(mask: TextInputPresentableModel.Mask) {
        maskedTextfieldDelegate = .init(format: .init(mask: mask.mask, maskedTextColor: mask.maskColor))
        invalidateA11y()
    }
    
    public func display(isValid: Bool) {
        isValidState = isValid
        updateAppearance(isValid: isValid)
        invalidateA11y()
    }
    
    public func display(isEnabledForEditing: Bool) {
        self.isEnabledForEditing = isEnabledForEditing
        invalidateA11y()
    }
    
    public func display(leadingViewIsHidden: Bool) {
        leadingView?.isHidden = leadingViewIsHidden
        invalidateA11y()
    }
    
    public func display(trailingViewIsHidden: Bool) {
        trailingView?.isHidden = trailingViewIsHidden
        invalidateA11y()
    }
    
    public func display(isTextSelectionDisabled: Bool) {
        self.isTextSelectionDisabled = isTextSelectionDisabled
        invalidateA11y()
    }
    
    public func display(placeholder: String?) {
        self.placeholder = placeholder
        invalidateA11y()
    }
    
    public func display(isUserInteractionEnabled: Bool) {
        self.isUserInteractionEnabled = isUserInteractionEnabled
        invalidateA11y()
    }
    
    public func display(isSecureTextEntry: Bool) {
        self.isSecureTextEntry = isSecureTextEntry
        invalidateA11y()
    }
    
    public func display(leadingViewOnPress: (() -> Void)?) {
        self.leadingViewOnPress = leadingViewOnPress
        invalidateA11y()
    }
    
    public func display(trailingViewOnPress: (() -> Void)?) {
        self.trailingViewOnPress = trailingViewOnPress
        invalidateA11y()
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
        // onPress не меняет VO label обычно, но actions может поменять
        invalidateA11y()
    }
    
    public func display(onPaste: ((String?) -> Void)?) {
        self.onPaste = onPaste
        invalidateA11y()
    }
    
    public func display(onBecomeFirstResponder: (() -> Void)?) {
        self.onBecomeFirstResponder = onBecomeFirstResponder
        invalidateA11y()
    }
    
    public func display(onResignFirstResponder: (() -> Void)?) {
        self.onResignFirstResponder = onResignFirstResponder
        invalidateA11y()
    }
    
    public func display(onTapBackspace: (() -> Void)?) {
        self.onTapBackspace = onTapBackspace
        invalidateA11y()
    }
    
    public func display(didChangeText: [((String?) -> Void)]) {
        self.didChangeText = didChangeText
        invalidateA11y()
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
        invalidateA11y()
    }

    public func display(inputType: KeyboardType) {
        self.keyboardType = UIKeyboardType(rawValue: inputType.rawValue) ?? .default
        invalidateA11y()
    }
    
    public func display(trailingSymbol: String?) {
        guard let delegate = maskedTextfieldDelegate else { return }
        delegate.trailingSymbol = trailingSymbol
        delegate.refreshMask()
        invalidateA11y()
    }
    
    public func display(isClearButtonActive: Bool) {
        self.isClearButtonActive = isClearButtonActive
        invalidateA11y()
    }
}

open class Textfield: UITextField {
    // MARK: - A11y proxies (leading / field / clear / trailing)

    private final class A11yProxy: UIAccessibilityElement {
        var activate: (() -> Void)?
        override func accessibilityActivate() -> Bool { activate?(); return true }
    }

    private lazy var a11yLeadingProxy: A11yProxy = {
        let e = A11yProxy(accessibilityContainer: self)
        e.accessibilityTraits = [.button]
        return e
    }()

    private lazy var a11yFieldProxy: A11yProxy = {
        let e = A11yProxy(accessibilityContainer: self)
        e.accessibilityTraits = []
        return e
    }()

    private lazy var a11yClearProxy: A11yProxy = {
        let e = A11yProxy(accessibilityContainer: self)
        e.accessibilityTraits = [.button]
        return e
    }()

    private lazy var a11yTrailingProxy: A11yProxy = {
        let e = A11yProxy(accessibilityContainer: self)
        e.accessibilityTraits = [.button]
        return e
    }()

    private var a11yCache: [Any] = []
    private var a11yDirty = true
    private var lastBounds: CGRect = .zero

    private func invalidateA11y() {
        a11yDirty = true
        updateAccessibilityCustomActions()
    }

    // MARK: - Helpers: find tap + label in subtree

    private func findFirstOnPress(in view: UIView) -> (() -> Void)? {
        // твой базовый тип
        if let v = view as? ViewUIKit, let h = v.onPress { return h }
        if let v = view as? Button, let h = v.onPress { return h }
        if let v = view as? ImageView, let h = v.onPress { return h }

        for s in view.subviews {
            if let h = findFirstOnPress(in: s) { return h }
        }
        return nil
    }

    private func findA11yTitle(in view: UIView, fallback: String) -> String {
        let l = (view.accessibilityLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !l.isEmpty { return l }

        if let l = view as? UILabel {
            let t = (l.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { return t }
        }

        for s in view.subviews {
            let t = findA11yTitle(in: s, fallback: "")
            if !t.isEmpty { return t }
        }
        return fallback
    }

    private var hasTextForClear: Bool {
        let current = (delegate as? MaskedTextfieldDelegate)?.onlySpecifiersIfMaskedText ?? (text ?? "")
        return !current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func rebuildA11yIfNeeded() {
        guard a11yDirty else { return }
        a11yDirty = false

        layoutIfNeeded()

        super.isAccessibilityElement = false
        accessibilityElementsHidden = false

        var result: [Any] = []

        // --- Leading ---
        if let lv = leadingView,
           !lv.isHidden, lv.alpha > 0.01, isUserInteractionEnabled,
           let onPress = findFirstOnPress(in: lv) ?? leadingViewOnPress {

            a11yLeadingProxy.accessibilityLabel = findA11yTitle(in: lv, fallback: "Leading")
            a11yLeadingProxy.activate = { [weak self] in
                self?.leadingViewOnPress?()
                onPress()
            }
            a11yLeadingProxy.accessibilityFrame =
                UIAccessibility.convertToScreenCoordinates(lv.bounds, in: lv)

            // важно: сами view внутри не делаем элементами, иначе будет дубль
            lv.isAccessibilityElement = false
            result.append(a11yLeadingProxy)
        }

        // --- Field ---
        let value = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let ph = (placeholder ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        a11yFieldProxy.accessibilityLabel = !ph.isEmpty ? ph : "Text field"
        a11yFieldProxy.accessibilityValue = value.isEmpty ? nil : value
        a11yFieldProxy.activate = { [weak self] in _ = self?.becomeFirstResponder() }

        let inputRect = editingRect(forBounds: bounds)
        a11yFieldProxy.accessibilityFrame =
            UIAccessibility.convertToScreenCoordinates(inputRect, in: self)

        result.append(a11yFieldProxy)

        // --- Clear (когда trailingView используется как clear и текст не пустой) ---
        if isClearButtonActive, hasTextForClear,
           let tv = trailingView, !tv.isHidden, tv.alpha > 0.01, isUserInteractionEnabled {

            a11yClearProxy.accessibilityLabel = "Clear" // при желании локализуешь
            a11yClearProxy.activate = { [weak self] in
                guard let self else { return }
                self.text = ""
                self.sendActions(for: .editingChanged)
                self.trailingView?.isHidden = true
                self.invalidateA11y()
            }
            a11yClearProxy.accessibilityFrame =
                UIAccessibility.convertToScreenCoordinates(tv.bounds, in: tv)

            result.append(a11yClearProxy)
        }

        // --- Trailing (если это не clear, а реальная action) ---
        if let tv = trailingView,
           !tv.isHidden, tv.alpha > 0.01, isUserInteractionEnabled,
           let onPress = (findFirstOnPress(in: tv) ?? trailingViewOnPress),
           // чтобы trailing не дублировал clear-кнопку:
           !(isClearButtonActive && hasTextForClear) {

            a11yTrailingProxy.accessibilityLabel = findA11yTitle(in: tv, fallback: "Trailing")
            a11yTrailingProxy.activate = { [weak self] in
                self?.trailingViewOnPress?()
                onPress()
            }
            a11yTrailingProxy.accessibilityFrame =
                UIAccessibility.convertToScreenCoordinates(tv.bounds, in: tv)

            tv.isAccessibilityElement = false
            result.append(a11yTrailingProxy)
        }

        a11yCache = result
    }

    // MARK: - UIAccessibilityContainer

    open override func accessibilityElementCount() -> Int {
        rebuildA11yIfNeeded()
        return a11yCache.count
    }

    open override func accessibilityElement(at index: Int) -> Any? {
        rebuildA11yIfNeeded()
        guard index >= 0, index < a11yCache.count else { return nil }
        return a11yCache[index]
    }

    open override func index(ofAccessibilityElement element: Any) -> Int {
        rebuildA11yIfNeeded()
        return a11yCache.firstIndex { ($0 as AnyObject) === (element as AnyObject) } ?? NSNotFound
    }

    open override func accessibilityHitTest(_ point: CGPoint, event: UIEvent?) -> Any? {
        rebuildA11yIfNeeded()

        let screenPoint: CGPoint = bounds.contains(point) ? convert(point, to: nil) : point

        // приоритет: clear -> trailing -> leading -> field
        if let tv = trailingView, !tv.isHidden, tv.alpha > 0.01 {
            let p = tv.convert(screenPoint, from: nil)
            if tv.bounds.contains(p) {
                if isClearButtonActive && hasTextForClear { return a11yClearProxy }
                if a11yCache.contains(where: { ($0 as AnyObject) === (a11yTrailingProxy as AnyObject) }) { return a11yTrailingProxy }
            }
        }

        if let lv = leadingView, !lv.isHidden, lv.alpha > 0.01 {
            let p = lv.convert(screenPoint, from: nil)
            if lv.bounds.contains(p) {
                if a11yCache.contains(where: { ($0 as AnyObject) === (a11yLeadingProxy as AnyObject) }) { return a11yLeadingProxy }
            }
        }

        let local = convert(screenPoint, from: nil)
        return bounds.contains(local) ? a11yFieldProxy : nil
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        invalidateA11y()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.equalTo(lastBounds) {
            lastBounds = bounds
            invalidateA11y()
        }
    }
    
    func updateAccessibilityCustomActions() {
        var actions: [UIAccessibilityCustomAction] = []

        if isLeadingActionAvailable {
            let name = leadingView?.accessibilityTextSummary(maxLen: 40) ?? "Leading"
            actions.append(UIAccessibilityCustomAction(name: name, target: self, selector: #selector(a11yTapLeading)))
        }

        if isClearActionAvailable {
            actions.append(UIAccessibilityCustomAction(name: "Clear", target: self, selector: #selector(a11yClear)))
        }

        if isTrailingActionAvailable {
            let name = trailingView?.accessibilityTextSummary(maxLen: 40) ?? "Trailing"
            actions.append(UIAccessibilityCustomAction(name: name, target: self, selector: #selector(a11yTapTrailing)))
        }

        accessibilityCustomActions = actions.isEmpty ? nil : actions
    }

    var isLeadingActionAvailable: Bool {
        guard let leadingView else { return false }
        return isUserInteractionEnabled && leadingView.isVisiblyInteractable && leadingView.onPress != nil
    }

    var isTrailingActionAvailable: Bool {
        guard let trailingView else { return false }
        // trailing custom action только если у контейнера есть onPress
        return isUserInteractionEnabled && trailingView.isVisiblyInteractable && trailingView.onPress != nil
    }

    var isClearActionAvailable: Bool {
        guard isClearButtonActive else { return false }
        guard trailingView != nil else { return false }
        let current = (delegate as? MaskedTextfieldDelegate)?.onlySpecifiersIfMaskedText ?? (text ?? "")
        return !current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc func a11yTapLeading() -> Bool {
        leadingViewOnPress?()
        return true
    }

    @objc func a11yTapTrailing() -> Bool {
        trailingViewOnPress?()
        return true
    }

    @objc func a11yClear() -> Bool {
        text = ""
        sendActions(for: .editingChanged)
        trailingView?.isHidden = true
        invalidateA11y()
        return true
    }

    public enum TrailingViewStyle {
        case clear(trailingView: ViewUIKit)
        case custom(trailingView: ViewUIKit)
    }
    
    public var leadingView: ViewUIKit? {
        didSet {
            oldValue?.removeFromSuperview()
            setupLeadingView()
            invalidateA11y()
        }
    }
    public var trailingView: ViewUIKit? {
        didSet {
            oldValue?.removeFromSuperview()
            setupTrailingView()
            invalidateA11y()
        }
    }
    
    private var isValidState = true
    private var isPressHandled = false
    private var isClearButtonActive = true
    
    public var padding: UIEdgeInsets = .zero
    public var midPadding: CGFloat = 0
    public var clearButtonEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
    public var disabledMenus = [UIMenu.Identifier]()
    
    public var isTextSelectionDisabled = false
    public var isEnabledForEditing = true {
        didSet {
            if !isEnabledForEditing {
                _  = resignFirstResponder()
            }
            invalidateA11y()
        }
    }
    
    open override func buildMenu(with builder: UIMenuBuilder) {
        if #available(iOS 17.0, *) {
            if isTextSelectionDisabled {
                builder.remove(menu: .text)
                builder.remove(menu: .edit)
                builder.remove(menu: .standardEdit)
                builder.remove(menu: .format)
                builder.remove(menu: .lookup)
                builder.remove(menu: .autoFill)
            }
            disabledMenus.forEach {
                builder.remove(menu: $0)
            }
        }
        super.buildMenu(with: builder)
    }
    
    public var leadingViewOnPress: (() -> Void)? {
        didSet {
            leadingView?.onPress = leadingViewOnPress
            invalidateA11y()
        }
    }
    public var trailingViewOnPress: (() -> Void)? {
        didSet {
            trailingView?.onPress = trailingViewOnPress
            invalidateA11y()
        }
    }
    
    public var onPress: (() -> Void)? { didSet { invalidateA11y() } }
    public var onPaste: ((String?) -> Void)? { didSet { invalidateA11y() } }
    public var nextTextfield: UIResponder? = nil { didSet { returnKeyType = nextTextfield == nil ? .done : .next } }
    public var onBecomeFirstResponder: (() -> Void)? { didSet { invalidateA11y() } }
    public var onResignFirstResponder: (() -> Void)? { didSet { invalidateA11y() } }
    public var onTapBackspace: (() -> Void)? { didSet { invalidateA11y() } }
    
    public var didChangeText = [((String?) -> Void)]()
    private var didChangeTextClear: ((String?) -> Void)?
    
    open override var placeholder: String? {
        didSet {
            updatePlaceholder()
            invalidateA11y()
        }
    }
    
    open override var text: String? {
        didSet {
            if let delegate = delegate as? MaskedTextfieldDelegate {
                delegate.fullText = text ?? ""
            }
            invalidateA11y()
        }
    }
    
    public var maskedTextfieldDelegate: MaskedTextfieldDelegate? {
        didSet {
            maskedTextfieldDelegate?.applyTo(textfield: self)
            invalidateA11y()
        }
    }
    
    public var appearance: TextfieldAppearance { didSet { updateAppearance(); invalidateA11y() } }
    
    public init(
        cornerRadius: CGFloat = 10,
        textAlignment: NSTextAlignment = .natural,
        appearance: TextfieldAppearance,
        midPadding: CGFloat = 6.67,
        padding: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12),
        nextTextfield: UIResponder? = nil,
        leadingView: ViewUIKit? = nil,
        trailingView: TrailingViewStyle? = nil,
        inputView: UIView? = nil,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        delegate: MaskedTextfieldDelegate? = nil
    ) {
        self.midPadding = midPadding
        self.padding = padding
        self.nextTextfield = nextTextfield
        self.appearance = appearance
        super.init(frame: .zero)
        
        self.textAlignment = textAlignment
        self.cornerRadius = cornerRadius
        self.autocorrectionType = .no
        self.textColor = appearance.colors.textColor
        self.autocapitalizationType = autocapitalizationType
        self.inputView = inputView
        maskedTextfieldDelegate = delegate
        delegate?.applyTo(textfield: self)
        returnKeyType = nextTextfield == nil ? .done : .next
        
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addTarget(self, action: #selector(textFieldDidChangeClear), for: .editingChanged)
        addTarget(self, action: #selector(onTapReturnButton), for: .editingDidEndOnExit)

        self.leadingView = leadingView
        updateAppearance()
        
        switch trailingView {
        case .custom(let trailingView):
            self.trailingView = trailingView
        case .clear(let trailingView):
            trailingView.allSubviews.forEach {
                // Assign clear on press for common types
                ($0 as? ViewUIKit)?.onPress = { [weak self] in
                    self?.text = ""
                    self?.sendActions(for: .editingChanged)
                    trailingView.isHidden = true
                    self?.invalidateA11y()
                }
                ($0 as? ImageView)?.onPress = { [weak self] in
                    self?.text = ""
                    self?.sendActions(for: .editingChanged)
                    trailingView.isHidden = true
                    self?.invalidateA11y()
                }
                ($0 as? Button)?.onPress = { [weak self] in
                    self?.text = ""
                    self?.sendActions(for: .editingChanged)
                    trailingView.isHidden = true
                    self?.invalidateA11y()
                }
                
                // Make inner views accessible as clear button (automatic label)
                if let v = $0 as? UIView {
                    v.isAccessibilityElement = false
                    v.accessibilityTraits = [.button]
                    if (v.accessibilityLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        v.accessibilityLabel = v.accessibilityTextSummary(maxLen: 40) ?? "Clear"
                    }
                    v.accessibilityHint = nil
                }
            }
            didChangeTextClear = { [weak self] text in
                guard self?.isClearButtonActive ?? true else { return }
                let txt = self?.maskedTextfieldDelegate?.onlySpecifiersIfMaskedText ?? text ?? ""
                self?.trailingView?.isHidden = txt.isEmpty
                self?.invalidateA11y()
            }
            self.trailingView = trailingView
            trailingView.isHidden = true
        default:
            break
        }
        
        setupLeadingView()
        setupTrailingView()
        invalidateA11y()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let trailingView = trailingView, trailingView.frame.contains(point) {
            return true
        } else if let leadingView = leadingView, leadingView.frame.contains(point) {
            return true
        }

        let isTouchInside = super.point(inside: point, with: event)
        if isTouchInside, !isPressHandled {
            isPressHandled = true
            onPress?()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.isPressHandled = false
            }
        }

        return isTouchInside
    }
    
    open override func deleteBackward() {
        super.deleteBackward()
        onTapBackspace?()
    }
    
    open override var isUserInteractionEnabled: Bool {
        didSet {
            textColor = isUserInteractionEnabled ? appearance.colors.textColor : appearance.colors.disabledTextColor
            backgroundColor = isUserInteractionEnabled ? appearance.colors.deselectedBackgroundColor : appearance.colors.disabledBackgroundColor
            updatePlaceholder()
            if !isUserInteractionEnabled {
                resignFirstResponder()
            }
            invalidateA11y()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func textFieldDidChange() {
        didChangeText.forEach {
            if let delegate = self.delegate as? MaskedTextfieldDelegate {
                $0(delegate.fullText)
            } else {
                $0(self.text)
            }
        }
        invalidateA11y()
    }
    
    @objc private func textFieldDidChangeClear() {
        if let delegate = self.delegate as? MaskedTextfieldDelegate {
            didChangeTextClear?(delegate.fullText)
        } else {
            didChangeTextClear?(self.text)
        }
        invalidateA11y()
    }
    
    @objc private func onTapReturnButton() {
        guard returnKeyType == .done else { return }
        resignFirstResponder()
        invalidateA11y()
    }
    
    public func updatePlaceholder() {
        guard let customizedPlaceholder = appearance.placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: customizedPlaceholder.text ?? placeholder ?? "",
            attributes: [
                NSAttributedString.Key.foregroundColor: isUserInteractionEnabled ? customizedPlaceholder.color : (customizedPlaceholder.disabledColor ?? customizedPlaceholder.color),
                NSAttributedString.Key.font: customizedPlaceholder.font
            ]
        )
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return textArea(for: bounds)
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textArea(for: bounds)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textArea(for: bounds)
    }
    
    open override func paste(_ sender: Any?) {
        if let onPaste {
            onPaste(UIPasteboard.general.string)
        } else {
            super.paste(sender)
        }
        invalidateA11y()
    }
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        guard isEnabledForEditing, isUserInteractionEnabled else { return false }
        let success = super.becomeFirstResponder()
        if success { onBecomeFirstResponder?() }
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
        updateAppearance()
        invalidateA11y()
        return success
    }
    
    open override var canBecomeFirstResponder: Bool {
        return isEnabledForEditing
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result { onResignFirstResponder?() }
        updateAppearance()
        invalidateA11y()
        return result
    }
    
    open override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
            invalidateA11y()
        }
    }
    
    open override func caretRect(for position: UITextPosition) -> CGRect {
        return isTextSelectionDisabled ? .zero : super.caretRect(for: position)
    }
    
    open override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return isTextSelectionDisabled ? [] : super.selectionRects(for: range)
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
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
                padding.right += leftView.frame.width + midPadding
            } else {
                padding.left += leftView.frame.width + midPadding
            }
        }
        if let rightView = trailingView, !rightView.isHidden {
            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
                padding.left += rightView.frame.width + midPadding
            } else {
                padding.right += rightView.frame.width + midPadding
            }
        }
        return bounds.inset(by: padding)
    }
    
    func setupTrailingView() {
        guard let trailingView = trailingView else { return }
        addSubview(trailingView)
        trailingView.anchor(
            .topGreaterThanEqual(topAnchor),
            .trailing(trailingAnchor, constant: padding.right),
            .centerY(centerYAnchor),
            .bottomLessThanEqual(bottomAnchor)
        )
    }
    
    func setupLeadingView() {
        guard let leadingView = leadingView else { return }
        addSubview(leadingView)
        leadingView.anchor(
            .topGreaterThanEqual(topAnchor),
            .leading(leadingAnchor, constant: padding.left),
            .centerY(centerYAnchor),
            .bottomLessThanEqual(bottomAnchor)
        )
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
        invalidateA11y()
    }
}

public extension Textfield {
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
                self.layer.borderColor = isFirstResponder ? appearance.colors.selectedErrorBorderColor.cgColor : appearance.colors.errorBorderColor.cgColor
            }
            self.layer.borderWidth = (isFirstResponder ? appearance.border?.selectedBorderWidth : appearance.border?.idleBorderWidth) ?? 0
        }
    }
    
    func updateAppearance() {
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
                self.layer.borderColor = isFirstResponder ? appearance.colors.selectedErrorBorderColor.cgColor : appearance.colors.errorBorderColor.cgColor
            }
            self.layer.borderWidth = (isFirstResponder ? appearance.border?.selectedBorderWidth : appearance.border?.idleBorderWidth) ?? 0
        }
    }
}

private extension TextAutocapitalizationType {
    var asUITextAutocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .allCharacters: return .allCharacters
        case .sentences: return .sentences
        case .words: return .words
        case .none: return .none
        }
    }
}
#endif
