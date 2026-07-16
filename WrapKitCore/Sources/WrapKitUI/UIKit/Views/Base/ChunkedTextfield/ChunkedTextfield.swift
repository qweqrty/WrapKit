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
        input.text = normalized
        previousText = normalized
        renderCells()
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
    public var otpText: String { input.text ?? "" }

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
    }

    func setupConstraints() {
        stackView.fillSuperview()
        input.fillSuperview()
    }

    func makeInput() -> Textfield {
        let field = Textfield(
            cornerStyle: .fixed(12), textAlignment: .center, appearance: makeHiddenAppearance()
        )
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        field.tintColor = .clear
        field.didChangeText.append { [weak self] _ in self?.handleInputChange() }
        field.onBecomeFirstResponder = { [weak self] in self?.renderCells() }
        field.onResignFirstResponder = { [weak self] in self?.renderCells() }
        return field
    }

    func handleInputChange() {
        let sanitized = String(
            (input.text ?? "")
                .filter { $0.unicodeScalars.allSatisfy(allowedCharacters.contains) }
                .prefix(count)
        )
        if sanitized != input.text { input.text = sanitized }
        if isError { isError = false }
        renderCells()
        announceEnteredCharactersIfNeeded(previous: previousText, current: sanitized)
        previousText = sanitized
        didChangeText.forEach { $0(sanitized) }
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
        let chars = Array(otpText)
        let editing = input.isFirstResponder
        let activeIndex = min(chars.count, count - 1)
        for (index, cell) in cells.enumerated() {
            cell.configure(
                character: index < chars.count ? String(chars[index]) : nil,
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
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
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
