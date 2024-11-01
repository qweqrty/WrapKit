import Foundation

public protocol ChunkedTextFieldOutput: AnyObject {
    func display(text: String?)
    func display(isValid: Bool)
}

#if canImport(UIKit)
extension ChunkedTextField: ChunkedTextFieldOutput {
    public func display(text: String?) {
        let text = String((text ?? "").prefix(count))
        text.enumerated().forEach {
            textfields.item(at: $0.offset)?.text = String($0.element)
        }
    }
    
    public func display(isValid: Bool) {
        textfields.forEach { $0.updateAppearance(isValid: isValid) }
    }
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
            }
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
