//
//  SUITextInput.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 28/4/26.
//

import SwiftUI

public struct SUITextField: View {
    @StateObject var stateModel: SUITextInputStateModel
    let appearance: TextfieldAppearance
    let leadingView: AnyView?
    let trailingView: AnyView?
    let contentInsets: SwiftUI.EdgeInsets
    let midPadding: CGFloat
    let cornerStyle: CornerStyle
    
    public init(
        adapter: TextInputOutputSwiftUIAdapter,
        appearance: TextfieldAppearance,
        leadingView: AnyView? = nil,
        trailingView: AnyView? = nil,
        contentInsets: SwiftUI.EdgeInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12),
        midPadding: CGFloat = 6.67,
        cornerStyle: CornerStyle = .fixed(10)
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.appearance = appearance
        self.leadingView = leadingView
        self.trailingView = trailingView
        self.contentInsets = contentInsets
        self.midPadding = midPadding
        self.cornerStyle = cornerStyle
    }

    init(
        stateModel: SUITextInputStateModel,
        appearance: TextfieldAppearance,
        leadingView: AnyView? = nil,
        trailingView: AnyView? = nil,
        contentInsets: SwiftUI.EdgeInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12),
        midPadding: CGFloat = 6.67,
        cornerStyle: CornerStyle = .fixed(10)
    ) {
        _stateModel = .init(wrappedValue: stateModel)
        self.appearance = appearance
        self.leadingView = leadingView
        self.trailingView = trailingView
        self.contentInsets = contentInsets
        self.midPadding = midPadding
        self.cornerStyle = cornerStyle
    }
    
    public var body: some View {
        if !stateModel.isHidden {
            if #available(iOS 15.0, *) {
                SUITextInputView(
                    text: userTextBinding,
                    placeholder: stateModel.placeholder,
                    appearance: appearance,
                    isValid: stateModel.isValid,
                    isEnabledForEditing: stateModel.isEnabledForEditing,
                    isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                    isSecureTextEntry: stateModel.isSecureTextEntry,
                    isTextSelectionDisabled: stateModel.isTextSelectionDisabled,
                    isClearButtonActive: stateModel.isClearButtonActive,
                    isClearButtonConfigured: stateModel.isClearButtonConfigured,
                    isClearButtonHidden: stateModel.isClearButtonHidden,
                    trailingViewIsHidden: stateModel.trailingViewIsHidden,
                    leadingViewIsHidden: stateModel.leadingViewIsHidden,
                    keyboardType: stateModel.keyboardType,
                    trailingSymbol: stateModel.trailingSymbol,
                    isFocused: $stateModel.isFocused,
                    shouldBecomeFirstResponder: $stateModel.shouldBecomeFirstResponder,
                    shouldResignFirstResponder: $stateModel.shouldResignFirstResponder,
                    leadingView: leadingView,
                    trailingView: trailingView,
                    onBecomeFirstResponder: stateModel.onBecomeFirstResponder,
                    onResignFirstResponder: stateModel.onResignFirstResponder,
                    onPress: stateModel.onPress,
                    onPaste: stateModel.onPaste,
                    leadingViewOnPress: stateModel.leadingViewOnPress,
                    trailingViewOnPress: stateModel.trailingViewOnPress,
                    autocapitalizationType: stateModel.autocapitalizationType,
                    inputView: stateModel.inputView,
                    mask: stateModel.mask,
                    accessibilityIdentifier: stateModel.accessibilityIdentifier,
                    inputAccessoryView: stateModel.inputAccessoryView,
                    inputAccessoryDateOnDoneTapped: stateModel.inputAccessoryDateOnDoneTapped,
                    contentInsets: contentInsets,
                    midPadding: midPadding,
                    cornerStyle: cornerStyle
                )
            } else {
                // Fallback on earlier versions
            }
        }
    }

    private var userTextBinding: Binding<String> {
        Binding(
            get: { stateModel.text },
            set: { newValue in
                let cleanValue = stateModel.trailingSymbol.map {
                    newValue.hasSuffix($0)
                        ? String(newValue.dropLast($0.count))
                        : newValue
                } ?? newValue
                stateModel.applyUserText(cleanValue)
            }
        )
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
    let isClearButtonConfigured: Bool
    let isClearButtonHidden: Bool
    let trailingViewIsHidden: Bool
    let leadingViewIsHidden: Bool
    let keyboardType: KeyboardType
    let trailingSymbol: String?
    @Binding var isFocused: Bool
    @Binding var shouldBecomeFirstResponder: Bool
    @Binding var shouldResignFirstResponder: Bool
    let leadingView: AnyView?
    let trailingView: AnyView?
    let onBecomeFirstResponder: (() -> Void)?
    let onResignFirstResponder: (() -> Void)?
    let onPress: (() -> Void)?
    let onPaste: ((String?) -> Void)?
    let leadingViewOnPress: (() -> Void)?
    let trailingViewOnPress: (() -> Void)?
    let autocapitalizationType: TextAutocapitalizationType
    let inputView: TextInputPresentableModel.InputView?
    let mask: TextInputPresentableModel.Mask?
    let accessibilityIdentifier: String?
    let inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?
    let inputAccessoryDateOnDoneTapped: ((Date) -> Void)?
    let contentInsets: SwiftUI.EdgeInsets
    let midPadding: CGFloat
    let cornerStyle: CornerStyle
    
    @FocusState private var nativeFocus: Bool
    @State private var isInputViewPresented = false
    @State private var selectedDate = Date()
    @State private var selectedPickerRows: [Int: Int] = [:]
    
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
        isFocused
            ? appearance.border?.selectedBorderWidth ?? 0
            : appearance.border?.idleBorderWidth ?? 0
    }

    private var hasInputView: Bool {
        if inputView != nil {
            return true
        }
        return false
    }

    private var canEdit: Bool {
        isUserInteractionEnabled && isEnabledForEditing
    }

    public var body: some View {
        HStack(spacing: midPadding) {
            leadingViewContent
            textFieldContent
            trailingViewContent
        }
        .padding(contentInsets)
        .fixedSize(horizontal: false, vertical: true)
        .suiTextFieldContentClip(style: cornerStyle)
        .background(
            SUITextFieldDecoration(
                style: cornerStyle,
                backgroundColor: currentBackgroundColor,
                borderColor: currentBorderColor,
                borderWidth: borderWidth
            )
        )
        .suiTextFieldClip(style: cornerStyle)
        .animation(.easeInOut(duration: 0.1), value: isValid)
        .modifier(
            SUITextInputAccessoryModifier(
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
    private var leadingViewContent: some View {
        if let leadingView, !leadingViewIsHidden {
            leadingView
                .onTapGesture { leadingViewOnPress?() }
        }
    }

    @ViewBuilder
    private var trailingViewContent: some View {
        if let trailingView, !trailingViewIsHidden {
            if !isClearButtonConfigured || !isClearButtonHidden {
                trailingView
                    .onTapGesture {
                        if isClearButtonConfigured && isClearButtonActive {
                            text = ""
                        }
                        trailingViewOnPress?()
                    }
            }
        }
    }

    @ViewBuilder
    private var textFieldContent: some View {
        if #available(iOS 15.0, *) {
            ZStack(alignment: .leading) {
                inputContent
                    .allowsHitTesting(!hasInputView)

                placeholderContent

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
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if !hasInputView {
                            onPress?()
                        }
                    }
                )
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
                SecureField("", text: nativeTextBinding)
                    .focused($nativeFocus)
            } else {
                HStack(spacing: 0) {
                    TextField("", text: nativeTextBinding)
                        .focused($nativeFocus)
                    if let trailingSymbol {
                        Text(trailingSymbol)
                    }
                }
            }
        }
        .font(SwiftUIFont(appearance.font))
        .frame(minHeight: ceil(appearance.font.lineHeight))
        .foregroundColor(currentTextColor)
        .suiKeyboardType(keyboardType)
        .if(isTextSelectionDisabled) { view in
            view.textSelection(.disabled)
        }
        .disabled(!canEdit || hasInputView)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .if(true) { view in
            if #available(iOS 15.0, *) {
                view.textInputAutocapitalization(autocapitalizationType.asSUIAutocapitalization)
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
                let value = trailingSymbol.map {
                    candidate.hasSuffix($0)
                        ? String(candidate.dropLast($0.count))
                        : candidate
                } ?? candidate
                text = normalizedText(value)
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
                SUITextInputAccessoryContent(
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

private struct SUITextFieldDecoration: View {
    private static let innerRadiusInsetFactor: CGFloat = 1.25

    let style: CornerStyle
    let backgroundColor: SwiftUIColor
    let borderColor: SwiftUIColor
    let borderWidth: CGFloat

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.0, *) {
            switch style {
            case .automatic:
                nativeDecoration(
                    outer: Capsule(style: .continuous),
                    inner: Capsule(style: .continuous)
                )
            case .fixed(let radius):
                nativeDecoration(
                    outer: ConcentricRectangle(corners: .fixed(radius), isUniform: true),
                    inner: ConcentricRectangle(
                        corners: .fixed(innerRadius(for: radius)),
                        isUniform: true
                    )
                )
            case .corners(let corners):
                nativeDecoration(
                    outer: concentricRectangle(corners: corners),
                    inner: concentricRectangle(corners: inset(corners))
                )
            case .none:
                nativeDecoration(outer: Rectangle(), inner: Rectangle())
            }
        } else {
            SUICornerShape(style: style)
                .fill(backgroundColor)
                .overlay {
                    SUICornerShape(style: style)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
        }
    }

    @available(iOS 26.0, *)
    private func nativeDecoration<Outer: Shape, Inner: Shape>(
        outer: Outer,
        inner: Inner
    ) -> some View {
        outer
            .fill(borderWidth > 0 ? borderColor : backgroundColor)
            .overlay {
                if borderWidth > 0 {
                    inner
                        .fill(backgroundColor)
                        .padding(borderWidth)
                }
            }
    }

    @available(iOS 26.0, *)
    private func concentricRectangle(corners: CornerStyle.Corners) -> ConcentricRectangle {
        ConcentricRectangle(
            topLeadingCorner: .fixed(corners.topLeft),
            topTrailingCorner: .fixed(corners.topRight),
            bottomLeadingCorner: .fixed(corners.bottomLeft),
            bottomTrailingCorner: .fixed(corners.bottomRight)
        )
    }

    private func inset(_ corners: CornerStyle.Corners) -> CornerStyle.Corners {
        .init(
            topLeft: innerRadius(for: corners.topLeft),
            topRight: innerRadius(for: corners.topRight),
            bottomLeft: innerRadius(for: corners.bottomLeft),
            bottomRight: innerRadius(for: corners.bottomRight)
        )
    }

    private func innerRadius(for radius: CGFloat) -> CGFloat {
        max(radius - borderWidth * Self.innerRadiusInsetFactor, 0)
    }
}

private extension View {
    @ViewBuilder
    func suiTextFieldContentClip(style: CornerStyle) -> some View {
        if #available(iOS 26.0, *) {
            switch style {
            case .automatic:
                clipShape(Capsule(style: .continuous))
            case .fixed(let radius):
                clipShape(ConcentricRectangle(corners: .fixed(radius), isUniform: true))
            case .corners(let corners):
                clipShape(ConcentricRectangle(
                    topLeadingCorner: .fixed(corners.topLeft),
                    topTrailingCorner: .fixed(corners.topRight),
                    bottomLeadingCorner: .fixed(corners.bottomLeft),
                    bottomTrailingCorner: .fixed(corners.bottomRight)
                ))
            case .none:
                self
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func suiTextFieldClip(style: CornerStyle) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            cornerStyle(style)
        }
    }
}

private struct SUITextInputAccessoryContent: View {
    let model: TextInputPresentableModel.AccessoryViewPresentableModel
    let onPress: (ButtonPresentableModel) -> Void

    var body: some View {
        HStack {
            Spacer()
            if let buttonModel = model.trailingButton {
                SwiftUI.Button {
                    onPress(buttonModel)
                } label: {
                    Text(buttonModel.title ?? "")
                        .frame(
                            width: buttonModel.width ?? 80,
                            height: buttonModel.height ?? 36
                        )
                }
                .disabled(buttonModel.enabled == false)
                .accessibilityIdentifier(buttonModel.accessibilityIdentifier ?? "")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: model.style.height)
        .background(SwiftUIColor(model.style.backgroundColor))
    }
}

private struct SUITextInputAccessoryModifier: ViewModifier {
    let model: TextInputPresentableModel.AccessoryViewPresentableModel?
    let onPress: (ButtonPresentableModel) -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(iOS)
        if let model {
            content.toolbar {
                ToolbarItem(placement: .keyboard) {
                    SUITextInputAccessoryContent(model: model, onPress: onPress)
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
private struct SUIKeyboardTypeModifier: ViewModifier {
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
    func suiKeyboardType(_ keyboardType: KeyboardType) -> some View {
#if os(iOS)
        modifier(SUIKeyboardTypeModifier(keyboardType: keyboardType))
#else
        self
#endif
    }
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
