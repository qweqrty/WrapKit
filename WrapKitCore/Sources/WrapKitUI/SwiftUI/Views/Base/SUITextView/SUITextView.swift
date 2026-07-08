import SwiftUI
import SwiftUIIntrospect

public struct SUITextView: View {
    @ObservedObject var stateModel: SUITextInputStateModel
    let appearance: TextfieldAppearance

    public init(
        adapter: TextInputOutputSwiftUIAdapter,
        appearance: TextfieldAppearance
    ) {
        self.stateModel = .init(adapter: adapter)
        self.appearance = appearance
    }

    public var body: some View {
        if !stateModel.isHidden {
            SUITextViewContent(
                text: $stateModel.text,
                placeholder: stateModel.placeholder,
                appearance: appearance,
                isValid: stateModel.isValid,
                isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                onBecomeFirstResponder: stateModel.onBecomeFirstResponder,
                onResignFirstResponder: stateModel.onResignFirstResponder,
                didChangeText: stateModel.didChangeText
            )
        }
    }
}

public struct SUITextViewContent: View {
    @Binding var text: String
    let placeholder: String?
    let appearance: TextfieldAppearance
    let isValid: Bool
    let isUserInteractionEnabled: Bool
    let onBecomeFirstResponder: (() -> Void)?
    let onResignFirstResponder: (() -> Void)?
    let didChangeText: [((String?) -> Void)]

    @State private var isFocused: Bool = false
    @State private var isTextEmpty: Bool = true

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
        TextEditor(text: $text)
            .font(SwiftUIFont(appearance.font))
            .foregroundColor(currentTextColor)
            .if(true) { view in
                if #available(iOS 16.0, *) {
                    view.scrollContentBackground(.hidden)
                } else {
                    view
                }
            }
            .disabled(!isUserInteractionEnabled)
            .frame(minHeight: 100)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .onChange(of: text) { newValue in
                didChangeText.forEach { $0(newValue) }
            }
            .introspect(.textEditor, on: .iOS(.v15, .v26)) { textView in
                textView.backgroundColor = .clear
            }
            .onReceive(NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)) { _ in
                isFocused = true
                onBecomeFirstResponder?()
            }
            .onReceive(NotificationCenter.default.publisher(for: UITextView.textDidEndEditingNotification)) { _ in
                isFocused = false
                onResignFirstResponder?()
            }
            .onReceive(NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification)) { notification in
                guard let textView = notification.object as? UITextView else { return }
                isTextEmpty = textView.text.isEmpty
            }
            .if(true) { view in
                if #available(iOS 15.0, *) {
                    view.overlay(alignment: .topLeading) {
                        if isTextEmpty, let placeholder {
                            Text(placeholder)
                                .font(appearance.placeholder.map { SwiftUIFont($0.font) })
                                .foregroundColor(
                                    SwiftUIColor(!isUserInteractionEnabled
                                        ? (appearance.placeholder?.disabledColor ?? appearance.placeholder?.color ?? .gray)
                                        : (appearance.placeholder?.color ?? .gray))
                                )
                                .padding(.top, 16)
                                .padding(.leading, 16)
                                .allowsHitTesting(false)
                        }
                    }
                } else {
                    view
                }
            }
            .background(currentBackgroundColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(currentBorderColor, lineWidth: borderWidth)
            )
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.1), value: isValid)
    }
}
