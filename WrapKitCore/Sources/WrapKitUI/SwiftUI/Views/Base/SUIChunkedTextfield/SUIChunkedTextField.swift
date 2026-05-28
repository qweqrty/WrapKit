import SwiftUI
import SwiftUIIntrospect

public struct SUIChunkedTextField: View {
    @ObservedObject var stateModel: SUITextInputStateModel
    let count: Int
    let appearance: TextfieldAppearance

    public init(
        adapter: TextInputOutputSwiftUIAdapter,
        count: Int,
        appearance: TextfieldAppearance
    ) {
        self.stateModel = .init(adapter: adapter)
        self.count = count
        self.appearance = appearance
    }

    public var body: some View {
        if !stateModel.isHidden {
            if #available(iOS 15.0, *) {
                SUIChunkedTextFieldContent(
                    text: $stateModel.text,
                    count: count,
                    appearance: appearance,
                    isValid: stateModel.isValid,
                    isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                    didChangeText: stateModel.didChangeText
                )
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

private final class ChunkedFieldsHolder: ObservableObject {
    var textFields: [Int: UITextField] = [:]

    func focus(_ index: Int) {
        textFields[index]?.becomeFirstResponder()
    }

    func focusNext(after index: Int, count: Int) {
        if index < count - 1 {
            focus(index + 1)
        } else {
            textFields[index]?.resignFirstResponder()
        }
    }

    func focusPrev(before index: Int) {
        if index > 0 {
            focus(index - 1)
        }
    }
}

@available(iOS 15.0, *)
public struct SUIChunkedTextFieldContent: View {
    @Binding var text: String
    let count: Int
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isUserInteractionEnabled: Bool
    let didChangeText: [((String?) -> Void)]

    @State private var characters: [String] = []
    @StateObject private var fieldsHolder = ChunkedFieldsHolder()

    public init(
        text: Binding<String>,
        count: Int,
        appearance: TextfieldAppearance,
        isValid: Bool = true,
        isUserInteractionEnabled: Bool = true,
        didChangeText: [((String?) -> Void)] = []
    ) {
        self._text = text
        self.count = count
        self.appearance = appearance
        self.isValid = isValid
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.didChangeText = didChangeText
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

    private var borderWidth: CGFloat {
        max(
            appearance.border?.idleBorderWidth ?? 0,
            appearance.border?.selectedBorderWidth ?? 0
        )
    }

    private func handlePaste(_ string: String) {
        let chars = Array(string.prefix(count))
        for (i, char) in chars.enumerated() {
            guard characters.indices.contains(i) else { break }
            characters[i] = String(char)
            fieldsHolder.textFields[i]?.text = String(char)
        }
        let nextIndex = min(chars.count, count - 1)
        fieldsHolder.focus(nextIndex)
        notifyChange()
    }

    public var body: some View {
        HStack(spacing: count > 4 ? 8 : 12) {
            ForEach(0..<count, id: \.self) { index in
                SingleCharTextField(
                    character: characterBinding(for: index),
                    appearance: appearance,
                    isValid: isValid,
                    isUserInteractionEnabled: isUserInteractionEnabled,
                    borderWidth: borderWidth,
                    borderColor: borderColor,
                    focusedBorderColor: focusedBorderColor,
                    onRegister: { textField in
                        fieldsHolder.textFields[index] = textField
                    },
                    onCharacterEntered: {
                        fieldsHolder.focusNext(after: index, count: count)
                        notifyChange()
                    },
                    onBackspace: {
                        fieldsHolder.focusPrev(before: index)
                        notifyChange()
                    },
                    onPaste: { pasted in
                        handlePaste(pasted)
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            initializeCharacters()
        }
        .onChange(of: text) { newValue in
            syncFromText(newValue)
        }
    }

    private func characterBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { characters.indices.contains(index) ? characters[index] : "" },
            set: { newValue in
                guard characters.indices.contains(index) else { return }
                characters[index] = String(newValue.prefix(1))
            }
        )
    }

    private func initializeCharacters() {
        characters = Array(repeating: "", count: count)
        syncFromText(text)
    }

    private func syncFromText(_ newText: String) {
        let chars = Array(newText.prefix(count))
        characters = (0..<count).map { i in
            i < chars.count ? String(chars[i]) : ""
        }
    }

    private func notifyChange() {
        let joined = characters.joined()
        if joined != text {
            text = joined
        }
        didChangeText.forEach { $0(joined) }
    }
}

@available(iOS 15.0, *)
private struct SingleCharTextField: View {
    @Binding var character: String
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isUserInteractionEnabled: Bool
    let borderWidth: CGFloat
    let borderColor: SwiftUIColor
    let focusedBorderColor: SwiftUIColor
    let onRegister: (UITextField) -> Void
    let onCharacterEntered: () -> Void
    let onBackspace: () -> Void
    let onPaste: (String) -> Void

    @State private var isFocused: Bool = false
    @StateObject private var observer = SingleCharObserver()

    var body: some View {
        TextField("", text: $character)
            .font(SwiftUIFont(appearance.font))
            .foregroundColor(SwiftUIColor(
                isUserInteractionEnabled
                    ? appearance.colors.textColor
                    : appearance.colors.disabledTextColor
            ))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .disabled(!isUserInteractionEnabled)
            .introspect(.textField, on: .iOS(.v15, .v26)) { textField in
                onRegister(textField)

                if let existing = textField.delegate as? SingleCharDelegate {
                    existing.onCharacterEnteredHandler = { onCharacterEntered() }
                    existing.onBackspaceHandler = { onBackspace() }
                    existing.onTextChangeHandler = { newChar in character = newChar }
                    existing.onPasteHandler = { pasted in onPaste(pasted) }
                } else {
                    let delegate = SingleCharDelegate()
                    delegate.onCharacterEnteredHandler = { onCharacterEntered() }
                    delegate.onBackspaceHandler = { onBackspace() }
                    delegate.onTextChangeHandler = { newChar in character = newChar }
                    delegate.onPasteHandler = { pasted in onPaste(pasted) }
                    textField.delegate = delegate
                    observer.delegate = delegate
                }

                if textField.actions(forTarget: observer, forControlEvent: .editingDidBegin) == nil {
                    textField.addTarget(observer, action: #selector(SingleCharObserver.didBegin), for: .editingDidBegin)
                }
                if textField.actions(forTarget: observer, forControlEvent: .editingDidEnd) == nil {
                    textField.addTarget(observer, action: #selector(SingleCharObserver.didEnd), for: .editingDidEnd)
                }
                observer.onBegin = { isFocused = true }
                observer.onEnd = { isFocused = false }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(SwiftUIColor(
                        isUserInteractionEnabled
                            ? (isFocused
                                ? appearance.colors.selectedBackgroundColor
                                : appearance.colors.deselectedBackgroundColor)
                            : appearance.colors.disabledBackgroundColor
                    ))
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? focusedBorderColor : borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.1), value: isFocused)
    }
}

private final class SingleCharObserver: NSObject, ObservableObject {
    var delegate: SingleCharDelegate?
    var onBegin: (() -> Void)?
    var onEnd: (() -> Void)?

    @objc func didBegin() { onBegin?() }
    @objc func didEnd() { onEnd?() }
}

private final class SingleCharDelegate: NSObject, UITextFieldDelegate {
    var onCharacterEnteredHandler: (() -> Void)?
    var onBackspaceHandler: (() -> Void)?
    var onTextChangeHandler: ((String) -> Void)?
    var onPasteHandler: ((String) -> Void)?

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty {
            textField.text = ""
            onTextChangeHandler?("")
            onBackspaceHandler?()
            return false
        }
        let filtered = string.filter { $0.isNumber }
        guard !filtered.isEmpty else { return false }

        if filtered.count > 1 {
            onPasteHandler?(filtered)
            return false
        }

        let newChar = String(filtered.suffix(1))
        textField.text = newChar
        onTextChangeHandler?(newChar)
        onCharacterEnteredHandler?()
        return false
    }
}
