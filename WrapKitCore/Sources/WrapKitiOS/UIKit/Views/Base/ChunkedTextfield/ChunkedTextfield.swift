import Foundation

#if canImport(UIKit)
extension ChunkedTextField: TextInputOutput {
    public func display(text: String?) {
        let text = String((text ?? "").prefix(count))
        text.enumerated().forEach {
            textfields.item(at: $0.offset)?.text = String($0.element)
        }
    }
    
    public func display(model: TextInputPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        display(text: model.text)
        if let isValid = model.isValid { display(isValid: isValid) }
    }
    
    public func display(isValid: Bool) {
        textfields.forEach { $0.updateAppearance(isValid: isValid) }
    }
    
    public func display(isUserInteractionEnabled: Bool) {
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    public func display(didChangeText: [((String?) -> Void)]) {
        self.didChangeText = didChangeText
    }
    
    public func display(mask: TextInputPresentableModel.Mask) { }
    public func display(isEnabledForEditing: Bool) { }
    public func display(isTextSelectionDisabled: Bool) { }
    public func display(placeholder: String?) { }
    public func display(isSecureTextEntry: Bool) { }
    public func display(leadingViewOnPress: (() -> Void)?) {}
    public func display(trailingViewOnPress: (() -> Void)?) {}
    public func display(onPress: (() -> Void)?) {}
    public func display(onPaste: ((String?) -> Void)?) {}
    public func display(onBecomeFirstResponder: (() -> Void)?) {}
    public func display(onResignFirstResponder: (() -> Void)?) {}
    public func display(onTapBackspace: (() -> Void)?) {}
}

public class ChunkedTextField: View {
    private static let maxCharactersPerTextfield = 1
    private static let characterSet = CharacterSet.decimalDigits
    
    public let count: Int
    public var appearance: TextfieldAppearance { didSet { textfields.forEach { $0.updateAppearance() } }}
    
    public lazy var stackView = StackView(distribution: .fillEqually, axis: .horizontal, spacing: count > 4 ? 8 : 12)
    public lazy var textfields = makeTextfields()
    
    public var didChangeText = [((String?) -> Void)]()
    
    open override var isUserInteractionEnabled: Bool {
        didSet {
            textfields.forEach {
                $0.textColor = isUserInteractionEnabled ? appearance.colors.textColor : appearance.colors.disabledTextColor
                $0.backgroundColor = isUserInteractionEnabled ? appearance.colors.deselectedBackgroundColor : appearance.colors.disabledBackgroundColor
                $0.updatePlaceholder()
                if isUserInteractionEnabled == false {
                    $0.resignFirstResponder()
                }
            }
        }
    }
    
    public override func becomeFirstResponder() -> Bool {
        if isUserInteractionEnabled {
            return super.becomeFirstResponder()
        } else {
            return false
        }
    }
    
    public init(
        count: Int,
        appearance: TextfieldAppearance
    ) {
        self.count = count
        self.appearance = appearance
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
    }
    
    public func updateAppearance(isValid: Bool) {
        textfields.forEach { $0.updateAppearance(isValid: isValid) }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChunkedTextField {
    func setupViews() {
        addSubviews(stackView)
        textfields.forEach {
            stackView.addArrangedSubviews($0)
        }
    }
    
    func setupConstraints() {
        stackView.fillSuperview()
    }
    
    func handlePaste(pastedText: String?, startingFrom startIndex: Int) {
        guard let pastedText = pastedText, startIndex < textfields.count else { return }
        
        var remainingCharacters = pastedText[...]
        
        for currentIndex in startIndex..<textfields.count {
            guard !remainingCharacters.isEmpty else { break }
            guard let currentTextField = textfields.item(at: currentIndex) else { break }
            
            let currentText = currentTextField.text ?? ""
            let availableSpace = Self.maxCharactersPerTextfield - currentText.count
            guard availableSpace > 0 else { continue }
            
            let charactersToInsert = remainingCharacters.prefix(availableSpace)
            currentTextField.text = currentText + charactersToInsert
            remainingCharacters = remainingCharacters.dropFirst(charactersToInsert.count)
        }
        
        let allFieldsText = textfields.compactMap { $0.text }.joined()
        didChangeText.forEach { $0(allFieldsText) }
    }
}

private extension ChunkedTextField {
    func makeTextfields() -> [Textfield] {
        return stride(from: 0, to: count, by: 1).map { offset in
            let textfield = Textfield(cornerRadius: 12, textAlignment: .center, appearance: appearance)
            textfield.keyboardType = .numberPad
            textfield.tintColor = .clear
            textfield.textContentType = .oneTimeCode
            
            textfield.didChangeText.append { [weak self, weak textfield] text in
                let text = text?.filter { Self.characterSet.contains($0) }
                if let nextTextfield = self?.textfields.item(at: offset + 1), (text?.count ?? 0) >= Self.maxCharactersPerTextfield {
                    nextTextfield.becomeFirstResponder()
                }
                textfield?.text = String(text?.suffix(Self.maxCharactersPerTextfield) ?? "")
                
                let allFieldsText = self?.textfields.compactMap {
                    if let suffix = $0.text?.suffix(Self.maxCharactersPerTextfield) {
                        return String(suffix)
                    } else {
                        return nil
                    }
                }.joined()
                self?.didChangeText.forEach { $0(allFieldsText) }
            }
            
            textfield.onPaste = { [weak self] pastedText in
                self?.handlePaste(pastedText: pastedText, startingFrom: offset)
            }
            
            textfield.onTapBackspace = { [weak self, weak textfield] in
                if let prevTextfield = self?.textfields.item(at: offset - 1), (textfield?.text ?? "").isEmpty {
                    prevTextfield.becomeFirstResponder()
                }
            }
            return textfield
        }
    }
}
#endif
