#if !os(tvOS) && !os(macOS) && !os(watchOS)
import SwiftUI

#if canImport(UIKit)
import UIKit

enum SUITextInputEventTarget {
    case textField
    case textView
}

/// Gives `SUITextInputView` synchronous access to the native field, so a rewrite of the user's
/// input (mask formatting, `display(text:)` from `didChangeText`) lands in the same input event,
/// the way UIKit's `MaskedTextfieldDelegate` does it.
final class SUINativeTextInputHandle {
    fileprivate weak var textField: UITextField?

    private(set) var minimumCaretOffset = 0

    func configured(minimumCaretOffset: Int) -> Self {
        self.minimumCaretOffset = minimumCaretOffset
        return self
    }

    @discardableResult
    func replaceText(with text: String) -> Bool {
        guard let textField, textField.markedTextRange == nil else { return false }
        if textField.text != text {
            textField.text = text
        }
        return true
    }
}

/// Keeps the rendered control native SwiftUI while forwarding the two input
/// events that SwiftUI does not expose on iOS.
struct SUITextInputEventBridge: UIViewRepresentable {
    let target: SUITextInputEventTarget
    let onTapBackspace: (() -> Void)?
    let onPaste: ((String?) -> Void)?
    var nativeTextHandle: SUINativeTextInputHandle? = nil

    func makeCoordinator() -> SUITextInputEventCoordinator {
        SUITextInputEventCoordinator(
            onTapBackspace: onTapBackspace,
            onPaste: onPaste,
            nativeTextHandle: nativeTextHandle
        )
    }

    func makeUIView(context: Context) -> SUITextInputEventProbeView {
        let view = SUITextInputEventProbeView()
        view.configure(target: target, coordinator: context.coordinator)
        return view
    }

    func updateUIView(
        _ uiView: SUITextInputEventProbeView,
        context: Context
    ) {
        context.coordinator.update(
            onTapBackspace: onTapBackspace,
            onPaste: onPaste,
            nativeTextHandle: nativeTextHandle
        )
        uiView.configure(target: target, coordinator: context.coordinator)
    }

    static func dismantleUIView(
        _ uiView: SUITextInputEventProbeView,
        coordinator: SUITextInputEventCoordinator
    ) {
        coordinator.detach()
    }
}

final class SUITextInputEventProbeView: UIView {
    private var target: SUITextInputEventTarget = .textField
    private weak var eventCoordinator: SUITextInputEventCoordinator?

    func configure(
        target: SUITextInputEventTarget,
        coordinator: SUITextInputEventCoordinator
    ) {
        self.target = target
        eventCoordinator = coordinator
        attachToNearestInput()
        DispatchQueue.main.async { [weak self] in
            self?.attachToNearestInput()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        attachToNearestInput()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        attachToNearestInput()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attachToNearestInput()
    }

    private func attachToNearestInput() {
        guard let window, let eventCoordinator else { return }

        let center = convert(
            CGPoint(x: bounds.midX, y: bounds.midY),
            to: window
        )
        switch target {
        case .textField:
            guard let textField = window
                .suiDescendants(of: UITextField.self)
                .suiNearest(to: center, in: window) else { return }
            eventCoordinator.attach(to: textField)
        case .textView:
            guard let textView = window
                .suiDescendants(of: UITextView.self)
                .suiNearest(to: center, in: window) else { return }
            eventCoordinator.attach(to: textView)
        }
    }
}

final class SUITextInputEventCoordinator: NSObject,
    UITextFieldDelegate,
    UITextViewDelegate,
    UITextPasteDelegate {
    private weak var textField: UITextField?
    private weak var textView: UITextView?
    private weak var originalTextFieldDelegate: UITextFieldDelegate?
    private weak var originalTextViewDelegate: UITextViewDelegate?
    private weak var originalPasteDelegate: UITextPasteDelegate?
    private var onTapBackspace: (() -> Void)?
    private var onPaste: ((String?) -> Void)?
    private var nativeTextHandle: SUINativeTextInputHandle?

    init(
        onTapBackspace: (() -> Void)?,
        onPaste: ((String?) -> Void)?,
        nativeTextHandle: SUINativeTextInputHandle? = nil
    ) {
        self.onTapBackspace = onTapBackspace
        self.onPaste = onPaste
        self.nativeTextHandle = nativeTextHandle
    }

    func update(
        onTapBackspace: (() -> Void)?,
        onPaste: ((String?) -> Void)?,
        nativeTextHandle: SUINativeTextInputHandle? = nil
    ) {
        self.onTapBackspace = onTapBackspace
        self.onPaste = onPaste
        self.nativeTextHandle = nativeTextHandle
        nativeTextHandle?.textField = textField
        updatePasteDelegate()
    }

    func attach(to textField: UITextField) {
        guard self.textField !== textField else {
            refreshDelegate(on: textField)
            return
        }
        detach()
        self.textField = textField
        nativeTextHandle?.textField = textField
        originalTextFieldDelegate = textField.delegate
        originalPasteDelegate = textField.pasteDelegate
        textField.delegate = self
        updatePasteDelegate()
    }

    func attach(to textView: UITextView) {
        guard self.textView !== textView else {
            refreshDelegate(on: textView)
            return
        }
        detach()
        self.textView = textView
        originalTextViewDelegate = textView.delegate
        originalPasteDelegate = textView.pasteDelegate
        textView.delegate = self
        updatePasteDelegate()
    }

    func detach() {
        if let textField {
            if textField.delegate === self {
                textField.delegate = originalTextFieldDelegate
            }
            if textField.pasteDelegate === self {
                textField.pasteDelegate = originalPasteDelegate
            }
        }
        if let textView {
            if textView.delegate === self {
                textView.delegate = originalTextViewDelegate
            }
            if textView.pasteDelegate === self {
                textView.pasteDelegate = originalPasteDelegate
            }
        }
        textField = nil
        textView = nil
        originalTextFieldDelegate = nil
        originalTextViewDelegate = nil
        originalPasteDelegate = nil
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let shouldChange = originalTextFieldDelegate?.textField?(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string
        ) ?? true
        if string.isEmpty {
            notifyBackspaceAfterNativeMutation()
        }
        return shouldChange
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        let shouldChange = originalTextViewDelegate?.textView?(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        ) ?? true
        if text.isEmpty {
            notifyBackspaceAfterNativeMutation()
        }
        return shouldChange
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        originalTextFieldDelegate?.textFieldDidChangeSelection?(textField)
        clampCaret(in: textField)
    }

    private func clampCaret(in textField: UITextField) {
        guard let minimum = nativeTextHandle?.minimumCaretOffset,
              minimum > 0,
              textField.markedTextRange == nil,
              let selection = textField.selectedTextRange,
              let lowerBound = textField.position(from: textField.beginningOfDocument, offset: minimum) else { return }
        let start = textField.offset(from: textField.beginningOfDocument, to: selection.start)
        guard start < minimum else { return }
        let end = textField.offset(from: textField.beginningOfDocument, to: selection.end) < minimum
            ? lowerBound
            : selection.end
        textField.selectedTextRange = textField.textRange(from: lowerBound, to: end)
    }

    private func notifyBackspaceAfterNativeMutation() {
        let callback = onTapBackspace
        DispatchQueue.main.async {
            callback?()
        }
    }

    func textPasteConfigurationSupporting(
        _ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
        performPasteOf attributedString: NSAttributedString,
        to textRange: UITextRange
    ) -> UITextRange {
        onPaste?(attributedString.string)
        // UIKit Textfield/Textview also intercept the paste when this callback
        // is configured, so the value is not inserted automatically.
        return textRange
    }

    override func responds(to selector: Selector!) -> Bool {
        super.responds(to: selector)
            || originalTextFieldDelegate?.responds(to: selector) == true
            || originalTextViewDelegate?.responds(to: selector) == true
            || originalPasteDelegate?.responds(to: selector) == true
    }

    override func forwardingTarget(for selector: Selector!) -> Any? {
        if originalTextFieldDelegate?.responds(to: selector) == true {
            return originalTextFieldDelegate
        }
        if originalTextViewDelegate?.responds(to: selector) == true {
            return originalTextViewDelegate
        }
        if originalPasteDelegate?.responds(to: selector) == true {
            return originalPasteDelegate
        }
        return super.forwardingTarget(for: selector)
    }

    private func refreshDelegate(on textField: UITextField) {
        if textField.delegate !== self {
            originalTextFieldDelegate = textField.delegate
            textField.delegate = self
        }
        if textField.pasteDelegate !== self,
           textField.pasteDelegate !== originalPasteDelegate {
            originalPasteDelegate = textField.pasteDelegate
        }
        updatePasteDelegate()
    }

    private func refreshDelegate(on textView: UITextView) {
        if textView.delegate !== self {
            originalTextViewDelegate = textView.delegate
            textView.delegate = self
        }
        if textView.pasteDelegate !== self,
           textView.pasteDelegate !== originalPasteDelegate {
            originalPasteDelegate = textView.pasteDelegate
        }
        updatePasteDelegate()
    }

    private func updatePasteDelegate() {
        if let textField {
            textField.pasteDelegate = onPaste == nil
                ? originalPasteDelegate
                : self
        }
        if let textView {
            textView.pasteDelegate = onPaste == nil
                ? originalPasteDelegate
                : self
        }
    }
}

private extension UIView {
    func suiDescendants<T: UIView>(of type: T.Type) -> [T] {
        let current = (self as? T).map { [$0] } ?? []
        return current + subviews.flatMap { $0.suiDescendants(of: type) }
    }
}

private extension Array where Element: UIView {
    func suiNearest(to point: CGPoint, in window: UIWindow) -> Element? {
        filter { !$0.isHidden && $0.alpha > 0 && $0.window === window }
            .map { view -> (Element, CGFloat) in
                let frame = view.convert(view.bounds, to: window)
                let distance = hypot(frame.midX - point.x, frame.midY - point.y)
                let score = frame.insetBy(dx: -2, dy: -2).contains(point)
                    ? distance
                    : distance + 10_000
                return (view, score)
            }
            .min(by: { $0.1 < $1.1 })?
            .0
    }
}
#endif
#endif
