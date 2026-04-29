//
//  SUITextInput.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 28/4/26.
//

import SwiftUI
import SwiftUIIntrospect

public struct SUITextField: View {
    @ObservedObject var stateModel: SUITextInputStateModel
    let appearance: TextfieldAppearance
    let leadingView: AnyView?
    let trailingView: AnyView?
    
    public init(
        adapter: TextInputOutputSwiftUIAdapter,
        appearance: TextfieldAppearance,
        leadingView: AnyView? = nil,
        trailingView: AnyView? = nil
    ) {
        self.stateModel = .init(adapter: adapter)
        self.appearance = appearance
        self.leadingView = leadingView
        self.trailingView = trailingView
    }
    
    public var body: some View {
        if !stateModel.isHidden {
            if #available(iOS 15.0, *) {
                SUITextInputView(
                    text: $stateModel.text,
                    placeholder: stateModel.placeholder,
                    appearance: appearance,
                    isValid: stateModel.isValid,
                    isEnabledForEditing: stateModel.isEnabledForEditing,
                    isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                    isSecureTextEntry: stateModel.isSecureTextEntry,
                    isTextSelectionDisabled: stateModel.isTextSelectionDisabled,
                    isClearButtonActive: stateModel.isClearButtonActive,
                    trailingViewIsHidden: stateModel.trailingViewIsHidden,
                    leadingViewIsHidden: stateModel.leadingViewIsHidden,
                    keyboardType: stateModel.keyboardType,
                    trailingSymbol: stateModel.trailingSymbol,
                    shouldBecomeFirstResponder: $stateModel.shouldBecomeFirstResponder,
                    shouldResignFirstResponder: $stateModel.shouldResignFirstResponder,
                    leadingView: leadingView,
                    trailingView: trailingView,
                    onBecomeFirstResponder: stateModel.onBecomeFirstResponder,
                    onResignFirstResponder: stateModel.onResignFirstResponder,
                    onPress: stateModel.onPress,
                    leadingViewOnPress: stateModel.leadingViewOnPress,
                    trailingViewOnPress: stateModel.trailingViewOnPress,
                    didChangeText: stateModel.didChangeText,
                    autocapitalizationType: stateModel.autocapitalizationType,
                    inputView: stateModel.inputView,
                    mask: stateModel.mask,
                    accessibilityIdentifier: stateModel.accessibilityIdentifier,
                    inputAccessoryView: stateModel.inputAccessoryView,
                )
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

public struct SUITextInputView: View {
    @Binding var text: String
    let placeholder: String?
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isEnabledForEditing: Bool
    let isUserInteractionEnabled: Bool
    let isSecureTextEntry: Bool
    let isTextSelectionDisabled: Bool
    let isClearButtonActive: Bool
    let trailingViewIsHidden: Bool
    let leadingViewIsHidden: Bool
    let keyboardType: KeyboardType
    let trailingSymbol: String?
    @Binding var shouldBecomeFirstResponder: Bool
    @Binding var shouldResignFirstResponder: Bool
    let leadingView: AnyView?
    let trailingView: AnyView?
    let onBecomeFirstResponder: (() -> Void)?
    let onResignFirstResponder: (() -> Void)?
    let onPress: (() -> Void)?
    let leadingViewOnPress: (() -> Void)?
    let trailingViewOnPress: (() -> Void)?
    let didChangeText: [((String?) -> Void)]
    let autocapitalizationType: TextAutocapitalizationType
    let inputView: TextInputPresentableModel.InputView?
    let mask: TextInputPresentableModel.Mask?
    let accessibilityIdentifier: String?
    let inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
    
    @State private var isFocused: Bool = false
    @StateObject private var textFieldObserver = TextFieldObserver()
    @StateObject private var datePickerObserver = DatePickerObserver()
    @State private var maskedDelegate = MaskHolder()
    
    private var currentBorderColor: SwiftUIColor {
        if !isValid {
            return SwiftUIColor(isFocused
                ? appearance.colors.selectedErrorBorderColor
                : appearance.colors.errorBorderColor)
        }
        if isFocused {
            return SwiftUIColor(appearance.colors.selectedBorderColor)
        }
        
        if appearance.border?.idleBorderWidth == 0 {
            return SwiftUIColor(.clear)
        }
        return SwiftUIColor(appearance.colors.deselectedBorderColor)
    }
    
    private var currentBackgroundColor: SwiftUIColor {
        if !isUserInteractionEnabled {
            return SwiftUIColor(appearance.colors.disabledBackgroundColor)
        }
        if !isValid {
            return SwiftUIColor(appearance.colors.errorBackgroundColor)
        }
        return SwiftUIColor(isFocused
                            ? appearance.colors.selectedBackgroundColor
                            : appearance.colors.deselectedBackgroundColor)
    }
    
    private var currentTextColor: SwiftUIColor {
        SwiftUIColor(!isUserInteractionEnabled
                     ? appearance.colors.disabledTextColor
                     : appearance.colors.textColor)
    }
    
    private var borderWidth: CGFloat {
        max(
            appearance.border?.idleBorderWidth ?? 0,
            appearance.border?.selectedBorderWidth ?? 0
        )
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            leadingViewContent
            textFieldContent
            trailingViewContent
        }
        .padding(SwiftUI.EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(currentBackgroundColor)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(currentBorderColor, lineWidth: borderWidth)
        )
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.1), value: isValid)
    }
    
    @ViewBuilder
    private var leadingViewContent: some View {
        if let leadingView, !leadingViewIsHidden {
            leadingView
                .onTapGesture { leadingViewOnPress?() }
        }
    }
    
    @ViewBuilder
    private var trailingViewContent: some View {
        if let trailingView, !trailingViewIsHidden {
            let shouldHide = isClearButtonActive && text.isEmpty
            trailingView
                .opacity(shouldHide ? 0 : 1)
                .allowsHitTesting(!shouldHide)
                .onTapGesture {
                    if isClearButtonActive && !text.isEmpty {
                        text = ""
                        didChangeText.forEach { $0("") }
                    }
                    trailingViewOnPress?()
                }
        }
    }
    
    @ViewBuilder
    private var textFieldContent: some View {
        if #available(iOS 15.0, *) {
            inputContent
                .overlay(alignment: .leading) {
                    placeholderContent
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { onPress?() }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @ViewBuilder
    private var placeholderContent: some View {
        if text.isEmpty, let placeholder {
            Text(placeholder)
                .font(appearance.placeholder.map { SwiftUIFont($0.font) })
                .foregroundColor(
                    SwiftUIColor(!isUserInteractionEnabled
                                 ? (appearance.placeholder?.disabledColor ?? appearance.placeholder?.color ?? .gray)
                                 : (appearance.placeholder?.color ?? .gray))
                )
                .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    private var inputContent: some View {
        Group {
            if isSecureTextEntry {
                SecureField("", text: $text)
                    .onChange(of: text) { newValue in
                        didChangeText.forEach { $0(newValue) }
                    }
            } else {
                HStack {
                    TextField("", text: $text)
                        .onChange(of: text) { newValue in
                            let clean = trailingSymbol.map {
                                newValue.hasSuffix($0)
                                ? String(newValue.dropLast($0.count))
                                : newValue
                            } ?? newValue
                            if clean != newValue {
                                RunLoop.main.perform {
                                    text = clean
                                }
                            }
                            didChangeText.forEach { $0(clean) }
                        }
                    if let trailingSymbol {
                        Text(trailingSymbol)
                    }
                }
            }
        }
        .font(SwiftUIFont(appearance.font))
        .foregroundColor(currentTextColor)
        .keyboardType(UIKeyboardType(rawValue: keyboardType.rawValue) ?? .default)
        .disabled(!isUserInteractionEnabled || !isEnabledForEditing)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .if(true) { view in
            if #available(iOS 15.0, *) {
                view.textInputAutocapitalization(autocapitalizationType.asSUIAutocapitalization)
            } else {
                view
            }
        }
        .introspect(.textField, on: .iOS(.v15, .v26)) { textField in
            introspectTextField(textField)
        }
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(currentBorderColor, lineWidth: borderWidth)
    }
    
    private func introspectTextField(_ textField: UITextField) {
        
        // mask setup
        if let mask = mask {
            if maskedDelegate.delegate == nil {
                let delegate = MaskedTextfieldDelegate(
                    format: .init(
                        mask: mask.mask,
                        maskedTextColor: mask.maskColor
                    )
                )
                delegate.applyTo(uiTextField: textField)
                delegate.fullText = text
                maskedDelegate.delegate = delegate
                
                // синхронизируем text обратно в SwiftUI
                if textField.actions(forTarget: textFieldObserver, forControlEvent: .editingChanged) == nil {
                    textField.addTarget(
                        textFieldObserver,
                        action: #selector(TextFieldObserver.textChanged(_:)),
                        for: .editingChanged
                    )
                }
                textFieldObserver.onTextChange = { [weak maskedDelegate] in
                    guard let delegate = maskedDelegate?.delegate else { return }
                    text = delegate.input
                }
            }
        } else {
            if maskedDelegate.delegate != nil {
                textField.delegate = nil
                maskedDelegate.delegate = nil
            }
        }
        
        // inputView
        if let inputView = inputView {
            switch inputView {
            case .date(let model):
                if !(textField.inputView is UIDatePicker) {
                    let picker = UIDatePicker()
                    if #available(iOS 13.4, *) {
                        picker.preferredDatePickerStyle = .wheels
                    }
                    picker.datePickerMode = mapDatePickerMode(model.mode)
                    picker.date = model.value
                    picker.minimumDate = model.minDate
                    picker.maximumDate = model.maxDate
                    picker.addTarget(
                        datePickerObserver,
                        action: #selector(datePickerObserver.dateChanged(_:)),
                        for: .valueChanged
                    )
                    datePickerObserver.onChange = model.onChange
                    textField.inputView = picker
                }
                
                // inputAccessoryView
                if let accessoryModel = model.accessoryView {
                    textField.inputAccessoryView = makeAccessoryView(
                        model: accessoryModel,
                        onDone: { [weak textField] in
                            if let picker = textField?.inputView as? UIDatePicker {
                                model.onDoneTapped?(picker.date)
                            }
                            textField?.resignFirstResponder()
                        }
                    )
                }
                
            case .custom:
                break // TODO
            }
            textField.reloadInputViews()
        } else {
            if textField.inputView != nil {
                textField.inputView = nil
                textField.inputAccessoryView = nil
                textField.reloadInputViews()
            }
        }
        
        if inputView == nil, let accessoryModel = inputAccessoryView {
            if textField.inputAccessoryView == nil {
                RunLoop.main.perform {
                    textField.inputAccessoryView = makeAccessoryView(
                        model: accessoryModel,
                        onDone: { [weak textField] in
                            textField?.resignFirstResponder()
                        }
                    )
                    textField.reloadInputViews()
                }
            }
        } else if inputView == nil && inputAccessoryView == nil {
            if textField.inputAccessoryView != nil {
                RunLoop.main.perform {
                    textField.inputAccessoryView = nil
                    textField.reloadInputViews()
                }
            }
        }
        
        if shouldBecomeFirstResponder {
            textField.becomeFirstResponder()
            RunLoop.main.perform { shouldBecomeFirstResponder = false }
        }
        if shouldResignFirstResponder {
            textField.resignFirstResponder()
            RunLoop.main.perform { shouldResignFirstResponder = false }
        }
        if isTextSelectionDisabled {
            textField.tintColor = .clear
        }
        if textField.actions(forTarget: textFieldObserver, forControlEvent: .editingDidBegin) == nil {
            textField.addTarget(
                textFieldObserver,
                action: #selector(TextFieldObserver.didBeginEditing(_:)),
                for: .editingDidBegin
            )
            textField.addTarget(
                textFieldObserver,
                action: #selector(TextFieldObserver.didEndEditing(_:)),
                for: .editingDidEnd
            )
        }
        textFieldObserver.onBegin = { [weak textField] tf in
            guard tf === textField else { return }
            isFocused = true
            onBecomeFirstResponder?()
        }
        textFieldObserver.onEnd = { [weak textField] tf in
            guard tf === textField else { return }
            isFocused = false
            onResignFirstResponder?()
        }
        
        if let accessibilityIdentifier = accessibilityIdentifier {
            textField.accessibilityIdentifier = accessibilityIdentifier
        }
    }
    
    private func mapDatePickerMode(_ mode: DatePickerMode) -> UIDatePicker.Mode {
        switch mode {
        case .time: return .time
        case .date: return .date
        case .dateAndTime: return .dateAndTime
        case .countDownTimer: return .countDownTimer
        }
        
    }
    
    private func makeAccessoryView(
        model: TextInputPresentableModel.AccessoryViewPresentableModel,
        onDone: @escaping () -> Void
    ) -> UIView {
        let container = UIView(frame: CGRect(
            x: 0, y: 0,
            width: UIScreen.main.bounds.width,
            height: model.style.height
        ))
        container.backgroundColor = model.style.backgroundColor
        
        guard let buttonModel = model.trailingButton else { return container }
        
        let button = UIButton(type: .system)
        button.setTitle(buttonModel.title, for: .normal)
        if #available(iOS 14.0, *) {
            button.addAction(UIAction { _ in
                onDone()
                buttonModel.onPress?()
            }, for: .touchUpInside)
        }
        
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: buttonModel.height ?? 36),
            button.widthAnchor.constraint(equalToConstant: buttonModel.width ?? 80)
        ])
        return container
    }
}

// MARK: - TextFieldObserver для отслеживания фокуса
// вместо shared singleton
private final class TextFieldObserver: NSObject, ObservableObject {
    var onBegin: ((UITextField) -> Void)?
    var onEnd: ((UITextField) -> Void)?
    var onTextChange: (() -> Void)?
    
    @objc func didBeginEditing(_ textField: UITextField) {
        onBegin?(textField)
    }
    
    @objc func didEndEditing(_ textField: UITextField) {
        onEnd?(textField)
    }
    
    @objc func textChanged(_ textField: UITextField) {
        onTextChange?()
    }
}

private final class DatePickerObserver: NSObject, ObservableObject {
    var onChange: ((Date) -> Void)?
    
    @objc func dateChanged(_ picker: UIDatePicker) {
        onChange?(picker.date)
    }
}

private final class MaskHolder: ObservableObject {
    var delegate: MaskedTextfieldDelegate?
}

private extension TextAutocapitalizationType {
    @available(iOS 15.0, *)
    var asSUIAutocapitalization: TextInputAutocapitalization {
        switch self {
        case .none: return .never
        case .words: return .words
        case .sentences: return .sentences
        case .allCharacters: return .characters
        @unknown default: return .never
        }
    }
}
