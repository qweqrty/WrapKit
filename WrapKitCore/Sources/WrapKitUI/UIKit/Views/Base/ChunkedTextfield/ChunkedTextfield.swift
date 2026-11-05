import Foundation

#if canImport(UIKit)
import UIKit

extension ChunkedTextField: TextInputOutput {
    public func display(inputAccessoryView: TextInputPresentableModel.AccessoryViewPresentableModel?) {}
    public func display(inputView: TextInputPresentableModel.InputView?) {}
    
    public func startEditing() { input.becomeFirstResponder() }
    public func stopEditing() { endEditing(true) }
    
    public func display(text: String?) {
        let normalized = String((text ?? "").prefix(count))
        characters = Array(normalized)
        input.text = normalized
        previousText = normalized
        focusCell(min(normalized.count, count - 1))
    }
    
    public func display(model: TextInputPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        display(text: model.text)
        if let isValid = model.isValid { display(isValid: isValid) }
    }
    
    public func display(isValid: Bool) { isError = !isValid; renderCells() }
    public func display(isUserInteractionEnabled: Bool) { self.isUserInteractionEnabled = isUserInteractionEnabled }
    public func display(didChangeText: [((String?) -> Void)]) { self.didChangeText = didChangeText }
    
    public func display(leadingViewIsHidden: Bool) {}
    public func display(trailingViewIsHidden: Bool) {}
    public func display(mask: TextInputPresentableModel.Mask) {}
    public func display(isEnabledForEditing: Bool) {}
    public func display(isTextSelectionDisabled: Bool) {}
    public func display(placeholder: String?) {}
    public func display(isSecureTextEntry: Bool) {}
    public func display(leadingViewOnPress: (() -> Void)?) {}
    public func display(trailingViewOnPress: (() -> Void)?) {}
    public func display(onPress: (() -> Void)?) {}
    public func display(onPaste: ((String?) -> Void)?) {}
    public func display(onBecomeFirstResponder: (() -> Void)?) {}
    public func display(onResignFirstResponder: (() -> Void)?) {}
    public func display(onTapBackspace: (() -> Void)?) {}
    public func display(inputType: KeyboardType) {}
    public func display(trailingSymbol: String?) {}
    public func display(isClearButtonActive: Bool) {}
}

public final class ChunkedTextField: ViewUIKit {
    public let count: Int
    private let allowedCharacters: CharacterSet
    private var previousText: String = ""
    public var appearance: TextfieldAppearance {
        didSet {
            input.appearance = makeHiddenAppearance()
            renderCells()
        }
    }
    
    public var didChangeText = [((String?) -> Void)]()
    
    public private(set) lazy var input: Textfield = makeInput()
    
    private lazy var cells: [OTPCellView] = (0..<count).map { _ in OTPCellView() }
    
    public lazy var stackView = StackView(
        distribution: .fillEqually, axis: .horizontal, spacing: count > 4 ? 8 : 12
    )
    
    private var isError = false
    private var selectedIndex = 0
    private var characters: [Character] = []
    public var otpText: String { String(characters) }
    
    public override var isUserInteractionEnabled: Bool {
        didSet {
            input.isUserInteractionEnabled = isUserInteractionEnabled
            if isUserInteractionEnabled == false { _ = input.resignFirstResponder() }
            renderCells()
        }
    }
    
    public override func becomeFirstResponder() -> Bool {
        guard isUserInteractionEnabled else { return false }
        return input.becomeFirstResponder()
    }
    
    public init(
        count: Int,
        appearance: TextfieldAppearance,
        allowedCharacters: CharacterSet = .decimalDigits
    ) {
        self.count = count
        self.appearance = appearance
        self.allowedCharacters = allowedCharacters
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        renderCells()
    }
    
    public func updateAppearance(isValid: Bool) { isError = !isValid; renderCells() }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension ChunkedTextField {
    func setupViews() {
        addSubviews(stackView, input)
        cells.forEach { stackView.addArrangedSubviews($0) }
        let cellTap = UITapGestureRecognizer(target: self, action: #selector(handleCellTap(_:)))
        cellTap.delegate = self
        addGestureRecognizer(cellTap)
    }
    
    func setupConstraints() {
        stackView.fillSuperview()
        input.fillSuperview()
    }
    
    func makeInput() -> Textfield {
        let field = OTPInputTextField(
            cornerStyle: .fixed(12), textAlignment: .center, appearance: makeHiddenAppearance()
        )
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        field.tintColor = .clear
        field.delegate = self
        field.onPaste = { [weak self] pasted in self?.handleInsert(pasted ?? "") }
        field.onBecomeFirstResponder = { [weak self] in
            guard let self else { return }
            focusCell(selectedIndex)
        }
        field.onResignFirstResponder = { [weak self] in self?.renderCells() }
        return field
    }
    
    @objc func handleCellTap(_ gesture: UITapGestureRecognizer) {
        if !input.isFirstResponder { _ = input.becomeFirstResponder() }
        selectedIndex = cellIndex(at: gesture.location(in: stackView))
        renderCells()
    }
    
    func handleInsert(_ text: String) {
        let allowed = String(
            text.filter { $0.unicodeScalars.allSatisfy(allowedCharacters.contains) }
        )
        guard !allowed.isEmpty else { return }
        
        if allowed.count > 1 {
            let value = String(allowed.prefix(count))
            applyText(value, nextIndex: value.count)
            return
        }
        
        var chars = characters
        if selectedIndex < chars.count {
            chars[selectedIndex] = Character(allowed)   // overwrite the focused cell in place
        } else if chars.count < count {
            chars.append(Character(allowed))            // append at the trailing cell
        } else {
            return
        }
        applyText(String(chars.prefix(count)), nextIndex: selectedIndex + 1)
    }
    
    func handleDelete() {
        var chars = characters
        guard !chars.isEmpty else { return }
        let removeAt = selectedIndex < chars.count ? selectedIndex : chars.count - 1
        chars.remove(at: removeAt)
        applyText(String(chars), nextIndex: removeAt)
    }
    
    func applyText(_ newText: String, nextIndex: Int) {
        let previous = previousText
        let normalized = String(newText.prefix(count))
        characters = Array(normalized)
        input.text = normalized
        if isError { isError = false }
        announceEnteredCharactersIfNeeded(previous: previous, current: normalized)
        previousText = normalized
        didChangeText.forEach { $0(normalized) }
        focusCell(nextIndex)
    }
    
    func focusCell(_ index: Int) {
        selectedIndex = min(max(index, 0), min(characters.count, count - 1))
        renderCells()
    }
    
    func cellIndex(at pointInStackView: CGPoint) -> Int {
        let tapped = cells.firstIndex { pointInStackView.x <= $0.frame.maxX } ?? (count - 1)
        let lastSelectable = min(characters.count, count - 1)
        return min(max(tapped, 0), lastSelectable)
    }
    
    func makeHiddenAppearance() -> TextfieldAppearance {
        TextfieldAppearance(
            colors: .init(
                textColor: .clear, selectedBorderColor: .clear, selectedBackgroundColor: .clear,
                selectedErrorBorderColor: .clear, errorBorderColor: .clear, errorBackgroundColor: .clear,
                deselectedBorderColor: .clear, deselectedBackgroundColor: .clear,
                disabledTextColor: .clear, disabledBackgroundColor: .clear
            ),
            font: appearance.font,
            border: .init(idleBorderWidth: 0, selectedBorderWidth: 0),
            placeholder: nil
        )
    }
    
    func renderCells() {
        let editing = input.isFirstResponder
        let activeIndex = editing
        ? min(max(selectedIndex, 0), count - 1)
        : min(characters.count, count - 1)
        for (index, cell) in cells.enumerated() {
            cell.configure(
                character: index < characters.count ? String(characters[index]) : nil,
                isActive: editing && index == activeIndex,
                isError: isError,
                isEnabled: isUserInteractionEnabled,
                appearance: appearance
            )
        }
    }
    
    private func announceEnteredCharactersIfNeeded(previous: String, current: String) {
        guard UIAccessibility.isVoiceOverRunning, current.count > previous.count else { return }
        let entered = current.dropFirst(previous.count)
        UIAccessibility.post(notification: .announcement, argument: spacedOut(entered))
    }
    
    private func spacedOut(_ text: some StringProtocol) -> String {
        text.map(String.init).joined(separator: " ")
    }
}

extension ChunkedTextField: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty {
            handleDelete()
        } else {
            handleInsert(string)
        }
        return false
    }
}

extension ChunkedTextField: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

private final class OTPInputTextField: Textfield {
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        endOfDocument
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { [] }
    override func caretRect(for position: UITextPosition) -> CGRect { .zero }
}

private final class OTPCellView: UIView {
    private let label: UILabel = {
        let label = UILabel(); label.textAlignment = .center; return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(character: String?, isActive: Bool, isError: Bool, isEnabled: Bool, appearance: TextfieldAppearance) {
        let colors = appearance.colors
        label.text = character
        label.font = appearance.font
        label.textColor = isEnabled ? colors.textColor : colors.disabledTextColor
        
        let selectedWidth = appearance.border?.selectedBorderWidth ?? 1
        let idleWidth = appearance.border?.idleBorderWidth ?? 0
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if isActive {
            backgroundColor = isError ? colors.errorBackgroundColor : colors.selectedBackgroundColor
            layer.borderColor = colors.selectedBorderColor.cgColor
            layer.borderWidth = selectedWidth
        } else if isError {
            backgroundColor = colors.errorBackgroundColor
            layer.borderColor = colors.errorBorderColor.cgColor
            layer.borderWidth = selectedWidth
        } else {
            backgroundColor = isEnabled ? colors.deselectedBackgroundColor : colors.disabledBackgroundColor
            layer.borderColor = colors.deselectedBorderColor.cgColor
            layer.borderWidth = idleWidth
        }
        CATransaction.commit()
    }
}
#endif
