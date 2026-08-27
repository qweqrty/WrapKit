import SwiftUI

public struct SUIChunkedTextField: View {
    private let adapter: TextInputOutputSwiftUIAdapter?
    private let injectedStateModel: SUITextInputStateModel?
    let count: Int
    let appearance: TextfieldAppearance

    public init(
        adapter: TextInputOutputSwiftUIAdapter,
        count: Int,
        appearance: TextfieldAppearance
    ) {
        self.adapter = adapter
        self.injectedStateModel = nil
        self.count = count
        self.appearance = appearance
    }

    init(
        stateModel: SUITextInputStateModel,
        count: Int,
        appearance: TextfieldAppearance
    ) {
        stateModel.configureChunkedCharacterCount(count)
        self.adapter = nil
        self.injectedStateModel = stateModel
        self.count = count
        self.appearance = appearance
    }

    @ViewBuilder
    public var body: some View {
        if let injectedStateModel {
            SUIChunkedTextFieldStateView(
                stateModel: injectedStateModel,
                count: count,
                appearance: appearance
            )
        } else if let adapter {
            SUIOwnedChunkedTextFieldStateView(
                adapter: adapter,
                count: count,
                appearance: appearance
            )
        }
    }
}

private struct SUIOwnedChunkedTextFieldStateView: View {
    @StateObject private var stateModel: SUITextInputStateModel
    let count: Int
    let appearance: TextfieldAppearance

    init(
        adapter: TextInputOutputSwiftUIAdapter,
        count: Int,
        appearance: TextfieldAppearance
    ) {
        _stateModel = .init(wrappedValue: .init(
            adapter: adapter,
            consumer: .chunkedTextField,
            chunkedCharacterCount: count
        ))
        self.count = count
        self.appearance = appearance
    }

    var body: some View {
        SUIChunkedTextFieldStateView(
            stateModel: stateModel,
            count: count,
            appearance: appearance
        )
    }
}

private struct SUIChunkedTextFieldStateView: View {
    @ObservedObject var stateModel: SUITextInputStateModel
    let count: Int
    let appearance: TextfieldAppearance

    @ViewBuilder
    var body: some View {
        if !stateModel.isHidden {
            if #available(iOS 15.0, *) {
                SUIChunkedTextFieldContent(
                    text: $stateModel.text,
                    modelCharacters: $stateModel.chunkedCharacters,
                    count: count,
                    appearance: appearance,
                    isValid: stateModel.isValid,
                    isEnabledForEditing: stateModel.isEnabledForEditing,
                    isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                    isSecureTextEntry: stateModel.isSecureTextEntry,
                    isTextSelectionDisabled: stateModel.isTextSelectionDisabled,
                    isFocused: $stateModel.isFocused,
                    shouldBecomeFirstResponder: $stateModel.shouldBecomeFirstResponder,
                    shouldResignFirstResponder: $stateModel.shouldResignFirstResponder,
                    didChangeText: stateModel.didChangeText,
                    onPress: stateModel.onPress,
                    onBecomeFirstResponder: stateModel.onBecomeFirstResponder,
                    onResignFirstResponder: stateModel.onResignFirstResponder,
                    onTapBackspace: stateModel.onTapBackspace,
                    accessibilityIdentifier: stateModel.accessibilityIdentifier,
                    onUserCharactersChange: stateModel.applyChunkedUserCharacters
                )
            }
        }
    }
}

@available(iOS 15.0, *)
public struct SUIChunkedTextFieldContent: View {
    @Binding var text: String
    let count: Int
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isEnabledForEditing: Bool
    let isUserInteractionEnabled: Bool
    let isSecureTextEntry: Bool
    let isTextSelectionDisabled: Bool
    @Binding var isFocused: Bool
    @Binding var shouldBecomeFirstResponder: Bool
    @Binding var shouldResignFirstResponder: Bool
    let didChangeText: [((String?) -> Void)]
    let onPress: (() -> Void)?
    let onBecomeFirstResponder: (() -> Void)?
    let onResignFirstResponder: (() -> Void)?
    let onTapBackspace: (() -> Void)?
    let accessibilityIdentifier: String?
    private let modelCharacters: Binding<[String]>?
    private let onUserCharactersChange: (([String]) -> Void)?

    @FocusState private var focusedIndex: Int?
    @State private var equalizedCellHeight: CGFloat?

    public init(
        text: Binding<String>,
        count: Int,
        appearance: TextfieldAppearance,
        isValid: Bool = true,
        isEnabledForEditing: Bool = true,
        isUserInteractionEnabled: Bool = true,
        isSecureTextEntry: Bool = false,
        isTextSelectionDisabled: Bool = false,
        isFocused: Binding<Bool> = .constant(false),
        shouldBecomeFirstResponder: Binding<Bool> = .constant(false),
        shouldResignFirstResponder: Binding<Bool> = .constant(false),
        didChangeText: [((String?) -> Void)] = [],
        onPress: (() -> Void)? = nil,
        onBecomeFirstResponder: (() -> Void)? = nil,
        onResignFirstResponder: (() -> Void)? = nil,
        onTapBackspace: (() -> Void)? = nil,
        accessibilityIdentifier: String? = nil
    ) {
        self.init(
            text: text,
            modelCharacters: nil,
            count: count,
            appearance: appearance,
            isValid: isValid,
            isEnabledForEditing: isEnabledForEditing,
            isUserInteractionEnabled: isUserInteractionEnabled,
            isSecureTextEntry: isSecureTextEntry,
            isTextSelectionDisabled: isTextSelectionDisabled,
            isFocused: isFocused,
            shouldBecomeFirstResponder: shouldBecomeFirstResponder,
            shouldResignFirstResponder: shouldResignFirstResponder,
            didChangeText: didChangeText,
            onPress: onPress,
            onBecomeFirstResponder: onBecomeFirstResponder,
            onResignFirstResponder: onResignFirstResponder,
            onTapBackspace: onTapBackspace,
            accessibilityIdentifier: accessibilityIdentifier,
            onUserCharactersChange: nil
        )
    }

    init(
        text: Binding<String>,
        modelCharacters: Binding<[String]>,
        count: Int,
        appearance: TextfieldAppearance,
        isValid: Bool = true,
        isEnabledForEditing: Bool = true,
        isUserInteractionEnabled: Bool = true,
        isSecureTextEntry: Bool = false,
        isTextSelectionDisabled: Bool = false,
        isFocused: Binding<Bool> = .constant(false),
        shouldBecomeFirstResponder: Binding<Bool> = .constant(false),
        shouldResignFirstResponder: Binding<Bool> = .constant(false),
        didChangeText: [((String?) -> Void)] = [],
        onPress: (() -> Void)? = nil,
        onBecomeFirstResponder: (() -> Void)? = nil,
        onResignFirstResponder: (() -> Void)? = nil,
        onTapBackspace: (() -> Void)? = nil,
        accessibilityIdentifier: String? = nil,
        onUserCharactersChange: @escaping ([String]) -> Void
    ) {
        self.init(
            text: text,
            modelCharacters: Optional(modelCharacters),
            count: count,
            appearance: appearance,
            isValid: isValid,
            isEnabledForEditing: isEnabledForEditing,
            isUserInteractionEnabled: isUserInteractionEnabled,
            isSecureTextEntry: isSecureTextEntry,
            isTextSelectionDisabled: isTextSelectionDisabled,
            isFocused: isFocused,
            shouldBecomeFirstResponder: shouldBecomeFirstResponder,
            shouldResignFirstResponder: shouldResignFirstResponder,
            didChangeText: didChangeText,
            onPress: onPress,
            onBecomeFirstResponder: onBecomeFirstResponder,
            onResignFirstResponder: onResignFirstResponder,
            onTapBackspace: onTapBackspace,
            accessibilityIdentifier: accessibilityIdentifier,
            onUserCharactersChange: Optional(onUserCharactersChange)
        )
    }

    private init(
        text: Binding<String>,
        modelCharacters: Binding<[String]>?,
        count: Int,
        appearance: TextfieldAppearance,
        isValid: Bool,
        isEnabledForEditing: Bool,
        isUserInteractionEnabled: Bool,
        isSecureTextEntry: Bool,
        isTextSelectionDisabled: Bool,
        isFocused: Binding<Bool>,
        shouldBecomeFirstResponder: Binding<Bool>,
        shouldResignFirstResponder: Binding<Bool>,
        didChangeText: [((String?) -> Void)],
        onPress: (() -> Void)?,
        onBecomeFirstResponder: (() -> Void)?,
        onResignFirstResponder: (() -> Void)?,
        onTapBackspace: (() -> Void)?,
        accessibilityIdentifier: String?,
        onUserCharactersChange: (([String]) -> Void)?
    ) {
        self._text = text
        self.modelCharacters = modelCharacters
        self.count = count
        self.appearance = appearance
        self.isValid = isValid
        self.isEnabledForEditing = isEnabledForEditing
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.isSecureTextEntry = isSecureTextEntry
        self.isTextSelectionDisabled = isTextSelectionDisabled
        self._isFocused = isFocused
        self._shouldBecomeFirstResponder = shouldBecomeFirstResponder
        self._shouldResignFirstResponder = shouldResignFirstResponder
        self.didChangeText = didChangeText
        self.onPress = onPress
        self.onBecomeFirstResponder = onBecomeFirstResponder
        self.onResignFirstResponder = onResignFirstResponder
        self.onTapBackspace = onTapBackspace
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onUserCharactersChange = onUserCharactersChange
    }

    private var borderColor: SwiftUIColor {
        if !isValid {
            return SwiftUIColor(appearance.colors.errorBorderColor)
        }
        return SwiftUIColor(appearance.colors.deselectedBorderColor)
    }

    private var focusedBorderColor: SwiftUIColor {
        if !isValid {
            return SwiftUIColor(appearance.colors.selectedErrorBorderColor)
        }
        return SwiftUIColor(appearance.colors.selectedBorderColor)
    }

    private var fieldCount: Int {
        max(count, 0)
    }

    private var canEdit: Bool {
        isUserInteractionEnabled && isEnabledForEditing
    }

    private func handleBulkInput(_ string: String, startingFrom startIndex: Int) {
        let updatedCharacters = Self.applyingPaste(
            string,
            startingFrom: startIndex,
            to: currentCharacters,
            count: fieldCount
        )
        applyUserCharacters(updatedCharacters)
        focusedIndex = (startIndex..<fieldCount).first { updatedCharacters[$0].isEmpty }
    }

    static func applyingPaste(
        _ pastedText: String,
        startingFrom startIndex: Int,
        to currentCharacters: [String],
        count: Int
    ) -> [String] {
        let count = max(count, 0)
        guard startIndex >= 0, startIndex < count else { return currentCharacters }

        var result = (0..<count).map { index in
            currentCharacters.indices.contains(index) ? currentCharacters[index] : ""
        }
        var remainingCharacters = pastedText[...]

        for currentIndex in startIndex..<count {
            guard !remainingCharacters.isEmpty else { break }
            guard result[currentIndex].isEmpty else { continue }

            let character = remainingCharacters.removeFirst()
            result[currentIndex] = String(character)
        }
        return result
    }

    public var body: some View {
        HStack(spacing: fieldCount > 4 ? 8 : 12) {
            ForEach(0..<fieldCount, id: \.self) { index in
                SingleCharTextField(
                    character: characterBinding(for: index),
                    index: index,
                    focusedIndex: $focusedIndex,
                    appearance: appearance,
                    isValid: isValid,
                    isEnabled: canEdit,
                    isSecureTextEntry: isSecureTextEntry,
                    isTextSelectionDisabled: isTextSelectionDisabled,
                    borderColor: borderColor,
                    focusedBorderColor: focusedBorderColor,
                    equalizedHeight: equalizedCellHeight,
                    accessibilityIdentifier: accessibilityIdentifier.map { "\($0).\(index)" }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded { onPress?() })
        .onPreferenceChange(ChunkedTextFieldCellHeightPreferenceKey.self) { height in
            let measuredHeight = height > 0 ? height : nil
            if equalizedCellHeight != measuredHeight {
                equalizedCellHeight = measuredHeight
            }
        }
        .onAppear {
            let hasFocusCommand = shouldBecomeFirstResponder || shouldResignFirstResponder
            applyFocusRequests()
            if !hasFocusCommand {
                synchronizeExternalFocus(isFocused)
            }
        }
        .onChange(of: shouldBecomeFirstResponder) { _ in
            applyFocusRequests()
        }
        .onChange(of: shouldResignFirstResponder) { _ in
            applyFocusRequests()
        }
        .onChange(of: isFocused) { focused in
            synchronizeExternalFocus(focused)
        }
        .onChange(of: isUserInteractionEnabled) { enabled in
            if !enabled {
                finishEditing()
            }
        }
        .onChange(of: isEnabledForEditing) { enabled in
            if !enabled {
                finishEditing()
            }
        }
        .onChange(of: focusedIndex) { index in
            let focused = index != nil
            guard focused != isFocused else { return }
            isFocused = focused
            if focused {
                onBecomeFirstResponder?()
            } else {
                onResignFirstResponder?()
            }
        }
    }

    private func characterBinding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                let characters = currentCharacters
                return characters.indices.contains(index) ? characters[index] : ""
            },
            set: { newValue in
                handleInput(newValue, at: index)
            }
        )
    }

    private func handleInput(_ newValue: String, at index: Int) {
        var characters = currentCharacters
        guard characters.indices.contains(index) else { return }

        let currentCharacter = characters[index]
        guard !newValue.isEmpty else {
            guard !currentCharacter.isEmpty else { return }
            characters[index] = ""
            applyUserCharacters(characters)
            onTapBackspace?()
            if index > 0 {
                focusedIndex = index - 1
            }
            return
        }

        let digits = newValue.filter { $0.isNumber }
        guard !digits.isEmpty else { return }

        let insertedCharacters: String
        if !currentCharacter.isEmpty,
           digits.hasPrefix(currentCharacter),
           digits.count > currentCharacter.count {
            insertedCharacters = String(digits.dropFirst(currentCharacter.count))
        } else {
            insertedCharacters = digits
        }

        guard !insertedCharacters.isEmpty else { return }
        if insertedCharacters.count > 1 {
            handleBulkInput(insertedCharacters, startingFrom: index)
            return
        }

        characters[index] = String(insertedCharacters.suffix(1))
        applyUserCharacters(characters)
        focusedIndex = index < fieldCount - 1 ? index + 1 : nil
    }

    private static func characters(from text: String, count: Int) -> [String] {
        let source = Array(text.prefix(count))
        return (0..<count).map { index in
            source.indices.contains(index) ? String(source[index]) : ""
        }
    }

    private var currentCharacters: [String] {
        guard let modelCharacters else {
            return Self.characters(from: text, count: fieldCount)
        }
        let source = modelCharacters.wrappedValue
        return (0..<fieldCount).map { index in
            source.indices.contains(index) ? String(source[index].prefix(1)) : ""
        }
    }

    private func applyUserCharacters(_ characters: [String]) {
        if let onUserCharactersChange {
            onUserCharactersChange(characters)
            return
        }

        let joined = characters.joined()
        if joined != text {
            text = joined
        }
        didChangeText.forEach { $0(joined) }
    }

    private func applyFocusRequests() {
        if shouldResignFirstResponder {
            shouldResignFirstResponder = false
            finishEditing()
            return
        }
        if shouldBecomeFirstResponder {
            shouldBecomeFirstResponder = false
            if canEdit {
                focusedIndex = fieldCount > 0 ? 0 : nil
            }
        }
    }

    private func synchronizeExternalFocus(_ focused: Bool) {
        if focused {
            if focusedIndex == nil, canEdit {
                focusedIndex = fieldCount > 0 ? 0 : nil
            }
        } else {
            finishEditing()
        }
    }

    private func finishEditing() {
        let shouldNotify = isFocused || focusedIndex != nil
        focusedIndex = nil
        guard shouldNotify else { return }
        isFocused = false
        onResignFirstResponder?()
    }
}

@available(iOS 15.0, *)
private struct SingleCharTextField: View {
    @Binding var character: String
    let index: Int
    let focusedIndex: FocusState<Int?>.Binding
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isEnabled: Bool
    let isSecureTextEntry: Bool
    let isTextSelectionDisabled: Bool
    let borderColor: SwiftUIColor
    let focusedBorderColor: SwiftUIColor
    let equalizedHeight: CGFloat?
    let accessibilityIdentifier: String?

    private var isFocused: Bool {
        focusedIndex.wrappedValue == index
    }

    private var borderWidth: CGFloat {
        isFocused
            ? appearance.border?.selectedBorderWidth ?? 0
            : appearance.border?.idleBorderWidth ?? 0
    }

    var body: some View {
        Group {
            if isSecureTextEntry {
                SecureField("", text: $character)
                    .focused(focusedIndex, equals: index)
            } else {
                TextField("", text: $character)
                    .focused(focusedIndex, equals: index)
            }
        }
            .font(SwiftUIFont(appearance.font))
            .foregroundColor(SwiftUIColor(
                isEnabled
                    ? appearance.colors.textColor
                    : appearance.colors.disabledTextColor
            ))
            .multilineTextAlignment(.center)
            .suiChunkedKeyboardType()
            .if(isTextSelectionDisabled) { view in
                view.textSelection(.disabled)
            }
            .disabled(!isEnabled)
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .padding(10)
        .background(
            GeometryReader { proxy in
                SwiftUIColor.clear.preference(
                    key: ChunkedTextFieldCellHeightPreferenceKey.self,
                    value: proxy.size.height
                )
            }
        )
        .frame(height: equalizedHeight)
        .background(
            ChunkedTextFieldCellDecoration(
                backgroundColor: SwiftUIColor(
                    !isValid
                        ? appearance.colors.errorBackgroundColor
                        : isFocused
                            ? appearance.colors.selectedBackgroundColor
                            : appearance.colors.deselectedBackgroundColor
                ),
                borderColor: isFocused ? focusedBorderColor : borderColor,
                borderWidth: borderWidth
            )
        )
        .animation(.easeInOut(duration: 0.1), value: isFocused)
    }
}

private struct ChunkedTextFieldCellDecoration: View {
    private static let cornerRadius: CGFloat = 12

    let backgroundColor: SwiftUIColor
    let borderColor: SwiftUIColor
    let borderWidth: CGFloat

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.0, *) {
            ConcentricRectangle(corners: .fixed(Self.cornerRadius), isUniform: true)
                .fill(borderWidth > 0 ? borderColor : backgroundColor)
                .overlay {
                    if borderWidth > 0 {
                        ConcentricRectangle(
                            corners: .fixed(max(Self.cornerRadius - borderWidth * 1.25, 0)),
                            isUniform: true
                        )
                        .fill(backgroundColor)
                        .padding(borderWidth)
                    }
                }
        } else {
            SUICornerShape(style: .fixed(Self.cornerRadius))
                .fill(backgroundColor)
                .overlay {
                    SUICornerShape(style: .fixed(Self.cornerRadius))
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                }
        }
    }
}

private struct ChunkedTextFieldCellHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private extension View {
    @ViewBuilder
    func suiChunkedKeyboardType() -> some View {
#if os(iOS)
        keyboardType(.numberPad)
#else
        self
#endif
    }
}
