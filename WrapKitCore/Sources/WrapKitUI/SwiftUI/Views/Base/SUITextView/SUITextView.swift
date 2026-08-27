import SwiftUI

public struct SUITextView: View {
    @StateObject var stateModel: SUITextInputStateModel
    let appearance: TextfieldAppearance

    public init(
        adapter: TextInputOutputSwiftUIAdapter,
        appearance: TextfieldAppearance
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter, consumer: .textView))
        self.appearance = appearance
    }

    init(
        stateModel: SUITextInputStateModel,
        appearance: TextfieldAppearance
    ) {
        _stateModel = .init(wrappedValue: stateModel)
        self.appearance = appearance
    }

    public var body: some View {
        if !stateModel.isHidden {
            SUITextViewContent(
                text: userTextBinding,
                placeholder: stateModel.placeholder,
                appearance: appearance,
                isValid: stateModel.isValid,
                isEnabledForEditing: stateModel.isEnabledForEditing,
                isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                isSecureTextEntry: stateModel.isSecureTextEntry,
                isTextSelectionDisabled: stateModel.isTextSelectionDisabled,
                keyboardType: stateModel.keyboardType,
                autocapitalizationType: stateModel.autocapitalizationType,
                mask: stateModel.mask,
                inputView: stateModel.inputView,
                inputAccessoryView: stateModel.inputAccessoryView,
                inputAccessoryDateOnDoneTapped: stateModel.inputAccessoryDateOnDoneTapped,
                isFocused: $stateModel.isFocused,
                shouldBecomeFirstResponder: $stateModel.shouldBecomeFirstResponder,
                shouldResignFirstResponder: $stateModel.shouldResignFirstResponder,
                onPress: stateModel.onPress,
                onPaste: stateModel.onPaste,
                leadingViewOnPress: stateModel.leadingViewOnPress,
                trailingViewOnPress: stateModel.trailingViewOnPress,
                onBecomeFirstResponder: stateModel.onBecomeFirstResponder,
                onResignFirstResponder: stateModel.onResignFirstResponder,
                accessibilityIdentifier: stateModel.accessibilityIdentifier
            )
        }
    }

    private var userTextBinding: Binding<String> {
        Binding(
            get: { stateModel.text },
            set: { newValue in
                stateModel.text = newValue
                stateModel.didChangeText.forEach { $0(newValue) }
            }
        )
    }
}

public struct SUITextViewContent: View {
    @Binding var text: String
    let placeholder: String?
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isEnabledForEditing: Bool
    let isUserInteractionEnabled: Bool
    let isSecureTextEntry: Bool
    let isTextSelectionDisabled: Bool
    let keyboardType: KeyboardType
    let autocapitalizationType: TextAutocapitalizationType
    let mask: TextInputPresentableModel.Mask?
    let inputView: TextInputPresentableModel.InputView?
    let inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
    let inputAccessoryDateOnDoneTapped: ((Date) -> Void)?
    @Binding var isFocused: Bool
    @Binding var shouldBecomeFirstResponder: Bool
    @Binding var shouldResignFirstResponder: Bool
    let onPress: (() -> Void)?
    let onPaste: ((String?) -> Void)?
    let leadingViewOnPress: (() -> Void)?
    let trailingViewOnPress: (() -> Void)?
    let onBecomeFirstResponder: (() -> Void)?
    let onResignFirstResponder: (() -> Void)?
    let accessibilityIdentifier: String?

    @FocusState private var nativeFocus: Bool
    @State private var isInputViewPresented = false
    @State private var selectedDate = Date()
    @State private var selectedPickerRows: [Int: Int] = [:]

    private var currentBorderColor: SwiftUIColor {
        if !isValid {
            return SwiftUIColor(appearance.colors.errorBorderColor)
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

    private var currentPlaceholderFont: SwiftUIFont {
        appearance.placeholder.map { SwiftUIFont($0.font) } ?? .system(size: 17)
    }

    private var currentPlaceholderColor: SwiftUIColor {
        guard let placeholderAppearance = appearance.placeholder else {
            return .primary
        }
        return SwiftUIColor(
            !isUserInteractionEnabled
                ? placeholderAppearance.disabledColor ?? placeholderAppearance.color
                : placeholderAppearance.color
        )
    }

    private var borderWidth: CGFloat {
        isFocused
            ? appearance.border?.selectedBorderWidth ?? 0
            : appearance.border?.idleBorderWidth ?? 0
    }

    private var hasInputView: Bool {
        inputView != nil
    }

    private var canEdit: Bool {
        isUserInteractionEnabled && isEnabledForEditing
    }

    private var shouldShowPlaceholder: Bool {
        guard text.isEmpty else { return false }
        if mask != nil, isFocused {
            return false
        }
        return true
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            inputContent
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .allowsHitTesting(!hasInputView)

            if shouldShowPlaceholder, let placeholder {
                Text(placeholder)
                    .font(currentPlaceholderFont)
                    .foregroundColor(currentPlaceholderColor)
                    .padding(.top, 12)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)
            }

            if hasInputView {
                SwiftUIColor.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard canEdit else { return }
                        onPress?()
                        beginEditing()
                    }
            }
        }
        .frame(minHeight: 100)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                if !hasInputView {
                    onPress?()
                }
            }
        )
        .if(isUserInteractionEnabled && leadingViewOnPress != nil) { view in
            view.accessibilityAction(named: SwiftUI.Text("Leading")) {
                leadingViewOnPress?()
            }
        }
        .if(isUserInteractionEnabled && trailingViewOnPress != nil) { view in
            view.accessibilityAction(named: SwiftUI.Text("Trailing")) {
                trailingViewOnPress?()
            }
        }
        .modifier(
            SUITextViewStyleModifier(
                backgroundColor: currentBackgroundColor,
                borderColor: currentBorderColor,
                borderWidth: borderWidth
            )
        )
        .animation(.easeInOut(duration: 0.1), value: isValid)
        .modifier(
            SUITextViewAccessoryModifier(
                model: hasInputView ? nil : inputAccessoryView,
                onPress: performKeyboardAccessoryAction
            )
        )
        .sheet(
            isPresented: $isInputViewPresented,
            onDismiss: finishEditing,
            content: { inputViewPresentation }
        )
        .onAppear {
            if shouldResignFirstResponder {
                shouldResignFirstResponder = false
                finishEditing()
            } else if shouldBecomeFirstResponder || isFocused {
                shouldBecomeFirstResponder = false
                beginEditing()
            }
        }
        .onChange(of: nativeFocus) { focused in
            if focused, hasInputView {
                nativeFocus = false
                beginEditing()
            } else if !hasInputView {
                updateReportedFocus(focused)
            }
        }
        .onChange(of: isFocused) { focused in
            synchronizeExternalFocus(focused)
        }
        .onChange(of: shouldBecomeFirstResponder) { shouldBecome in
            guard shouldBecome else { return }
            shouldBecomeFirstResponder = false
            beginEditing()
        }
        .onChange(of: shouldResignFirstResponder) { shouldResign in
            guard shouldResign else { return }
            shouldResignFirstResponder = false
            finishEditing()
        }
        .onChange(of: hasInputView) { hasInputView in
            if hasInputView, nativeFocus || isFocused {
                nativeFocus = false
                beginEditing()
            } else if !hasInputView, isInputViewPresented {
                finishEditing()
            }
        }
    }

    @ViewBuilder
    private var inputContent: some View {
        Group {
            if isSecureTextEntry {
                SecureField("", text: nativeTextBinding)
                    .focused($nativeFocus)
            } else {
                TextEditor(text: nativeTextBinding)
                    .focused($nativeFocus)
                    .if(true) { view in
                        if #available(iOS 16.0, *) {
                            view.scrollContentBackground(.hidden)
                        } else {
                            view
                        }
                    }
            }
        }
        .font(SwiftUIFont(appearance.font))
        .foregroundColor(currentTextColor)
        .suiTextViewKeyboardType(keyboardType)
        .if(isTextSelectionDisabled) { view in
            view.textSelection(.disabled)
        }
        .disabled(!canEdit || hasInputView)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .if(true) { view in
            if #available(iOS 15.0, *) {
                view.textInputAutocapitalization(autocapitalizationType.asSUITextViewAutocapitalization)
            } else {
                view
            }
        }
    }

    private var nativeTextBinding: Binding<String> {
        Binding(
            get: {
                guard let mask else { return text }
                if text.isEmpty, !isFocused, placeholder != nil {
                    return ""
                }
                return mask.mask.applied(to: text).input
            },
            set: { candidate in
                text = normalizedText(candidate)
            }
        )
    }

    private func normalizedText(_ candidate: String) -> String {
        guard let masking = mask?.mask else { return candidate }

        let current = masking.applied(to: text).input
        let currentUserInput = masking.extractUserInput(from: current)
        let candidateUserInput = masking.extractUserInput(from: candidate)

        if candidate.count < current.count,
           candidateUserInput == currentUserInput,
           !currentUserInput.isEmpty {
            return masking.applied(to: String(currentUserInput.dropLast())).input
        }

        return masking.applied(to: candidate).input
    }

    @ViewBuilder
    private var inputViewPresentation: some View {
        VStack(spacing: 0) {
            if let accessoryView = presentedAccessoryView {
                SUITextViewAccessoryContent(
                    model: accessoryView,
                    onPress: performInputViewAccessoryAction
                )
            }

            switch inputView {
            case .date(let model):
                datePicker(model)
            case .custom(let model):
                customPicker(model)
            case nil:
                SwiftUI.EmptyView()
            }
        }
    }

    private var presentedAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel? {
        if case .date(let model) = inputView {
            return inputAccessoryView ?? model.accessoryView
        }
        return inputAccessoryView
    }

    @ViewBuilder
    private func datePicker(
        _ model: TextInputPresentableModel.InputView.DatePickerPresentableModel
    ) -> some View {
        let selection = Binding(
            get: { selectedDate },
            set: { date in
                selectedDate = date
                model.onChange?(date)
            }
        )
        let components = datePickerComponents(for: model.mode)

        if let minDate = model.minDate, let maxDate = model.maxDate {
            DatePicker("", selection: selection, in: minDate...maxDate, displayedComponents: components)
                .datePickerStyle(.wheel)
                .labelsHidden()
        } else if let minDate = model.minDate {
            DatePicker("", selection: selection, in: minDate..., displayedComponents: components)
                .datePickerStyle(.wheel)
                .labelsHidden()
        } else if let maxDate = model.maxDate {
            DatePicker("", selection: selection, in: ...maxDate, displayedComponents: components)
                .datePickerStyle(.wheel)
                .labelsHidden()
        } else {
            DatePicker("", selection: selection, displayedComponents: components)
                .datePickerStyle(.wheel)
                .labelsHidden()
        }
    }

    private func datePickerComponents(for mode: DatePickerMode) -> DatePickerComponents {
        switch mode {
        case .time, .countDownTimer:
            return .hourAndMinute
        case .date:
            return .date
        case .dateAndTime:
            return [.date, .hourAndMinute]
        }
    }

    @ViewBuilder
    private func customPicker(_ model: PickerViewPresentableModel) -> some View {
        let componentsCount = max(model.componentsCount?() ?? 0, 0)
        let rowsCount = max(model.rowsCount?() ?? 0, 0)
        let rows = (0..<rowsCount).map { model.titleForRowAt?($0) ?? "" }

        SUIPickerContent(
            componentsCount: componentsCount,
            rows: rows,
            selectedRows: $selectedPickerRows,
            accessibilityIdentifier: model.accessibilityIdentifier,
            didSelectAt: model.didSelectAt
        )
    }

    private func beginEditing() {
        guard canEdit else { return }

        if hasInputView {
            prepareInputView()
            nativeFocus = false
            isInputViewPresented = true
            updateReportedFocus(true)
        } else {
            nativeFocus = true
        }
    }

    private func finishEditing() {
        nativeFocus = false
        isInputViewPresented = false
        updateReportedFocus(false)
    }

    private func synchronizeExternalFocus(_ focused: Bool) {
        if focused {
            if hasInputView {
                if !isInputViewPresented {
                    beginEditing()
                }
            } else if !nativeFocus {
                nativeFocus = true
            }
        } else {
            nativeFocus = false
            isInputViewPresented = false
        }
    }

    private func updateReportedFocus(_ focused: Bool) {
        guard isFocused != focused else { return }
        isFocused = focused
        if focused {
            onBecomeFirstResponder?()
        } else {
            onResignFirstResponder?()
        }
    }

    private func prepareInputView() {
        switch inputView {
        case .date(let model):
            selectedDate = model.value
        case .custom(let model):
            let componentsCount = max(model.componentsCount?() ?? 0, 0)
            selectedPickerRows = Dictionary(
                uniqueKeysWithValues: (0..<componentsCount).map { ($0, 0) }
            )
            if let selectedRow = model.selectedRow,
               selectedRow.component >= 0,
               selectedRow.component < componentsCount,
               selectedRow.row >= 0,
               selectedRow.row < max(model.rowsCount?() ?? 0, 0) {
                selectedPickerRows[selectedRow.component] = selectedRow.row
                selectedRow.selectedRowCompletion?(selectedRow.row)
            }
        case nil:
            break
        }
    }

    private func performKeyboardAccessoryAction(_ buttonModel: ButtonPresentableModel) {
        buttonModel.onPress?()
        finishEditing()
    }

    private func performInputViewAccessoryAction(_ buttonModel: ButtonPresentableModel) {
        if case .date(let model) = inputView {
            (inputAccessoryDateOnDoneTapped ?? model.onDoneTapped)?(selectedDate)
        }
        buttonModel.onPress?()
        finishEditing()
    }
}

private struct SUITextViewStyleModifier: ViewModifier {
    static let cornerRadius: CGFloat = 10

    let backgroundColor: SwiftUIColor
    let borderColor: SwiftUIColor
    let borderWidth: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .clipShape(
                    RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                )
                .background(
                    RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                        .fill(borderWidth > 0 ? borderColor : backgroundColor)
                        .overlay {
                            if borderWidth > 0 {
                                RoundedRectangle(
                                    cornerRadius: max(Self.cornerRadius - borderWidth, 0),
                                    style: .continuous
                                )
                                .fill(backgroundColor)
                                .padding(borderWidth)
                            }
                        }
                )
        } else {
            content
                .clipShape(
                    RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                )
                .background(
                    RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                        .fill(borderWidth > 0 ? borderColor : backgroundColor)
                        .overlay {
                            if borderWidth > 0 {
                                RoundedRectangle(
                                    cornerRadius: max(Self.cornerRadius - borderWidth, 0),
                                    style: .continuous
                                )
                                .fill(backgroundColor)
                                .padding(borderWidth)
                            }
                        }
                )
        }
    }
}

private struct SUITextViewAccessoryContent: View {
    let model: TextInputPresentableModel.AccessoryViewPresentableModel
    let onPress: (ButtonPresentableModel) -> Void

    var body: some View {
        HStack {
            Spacer()
            if let buttonModel = model.trailingButton {
                SUIButtonView(
                    model: buttonModel,
                    onPress: { onPress(buttonModel) },
                    isEnabled: buttonModel.enabled ?? true,
                    fillsAvailableWidth: false,
                    fillsAvailableHeight: false
                )
            }
        }
        .padding(.horizontal, 16)
        .frame(height: model.style.height)
        .background(SwiftUIColor(model.style.backgroundColor))
    }
}

private struct SUITextViewAccessoryModifier: ViewModifier {
    let model: TextInputPresentableModel.AccessoryViewPresentableModel?
    let onPress: (ButtonPresentableModel) -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(iOS)
        if let model {
            content.toolbar {
                ToolbarItem(placement: .keyboard) {
                    SUITextViewAccessoryContent(model: model, onPress: onPress)
                }
            }
        } else {
            content
        }
#else
        content
#endif
    }
}

#if os(iOS)
private struct SUITextViewKeyboardTypeModifier: ViewModifier {
    let keyboardType: KeyboardType

    @ViewBuilder
    func body(content: Content) -> some View {
        switch keyboardType {
        case .default:
            content.keyboardType(.default)
        case .asciiCapable:
            content.keyboardType(.asciiCapable)
        case .numbersAndPunctuation:
            content.keyboardType(.numbersAndPunctuation)
        case .URL:
            content.keyboardType(.URL)
        case .numberPad:
            content.keyboardType(.numberPad)
        case .phonePad:
            content.keyboardType(.phonePad)
        case .namePhonePad:
            content.keyboardType(.namePhonePad)
        case .emailAddress:
            content.keyboardType(.emailAddress)
        case .decimalPad:
            content.keyboardType(.decimalPad)
        case .twitter:
            content.keyboardType(.twitter)
        case .webSearch:
            content.keyboardType(.webSearch)
        case .asciiCapableNumberPad:
            content.keyboardType(.asciiCapableNumberPad)
        }
    }
}
#endif

private extension View {
    @ViewBuilder
    func suiTextViewKeyboardType(_ keyboardType: KeyboardType) -> some View {
#if os(iOS)
        modifier(SUITextViewKeyboardTypeModifier(keyboardType: keyboardType))
#else
        self
#endif
    }
}

private extension TextAutocapitalizationType {
    @available(iOS 15.0, *)
    var asSUITextViewAutocapitalization: TextInputAutocapitalization {
        switch self {
        case .none: return .never
        case .words: return .words
        case .sentences: return .sentences
        case .allCharacters: return .characters
        @unknown default: return .never
        }
    }
}
