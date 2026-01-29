#if canImport(UIKit)
import UIKit

public class MaskedTextfieldDelegate: NSObject, UITextFieldDelegate {
    public struct Format {
        let mask: Masking
        let maskedTextColor: UIColor
        
        public init(mask: Masking, maskedTextColor: UIColor) {
            self.mask = mask
            self.maskedTextColor = maskedTextColor
        }
    }
    private var format: Format {
        didSet {
            let userInput = format.mask.extractUserInput(from: fullText)
            setupMask(mask: format.mask.applied(to: userInput))
        }
    }
    
    public var backspacePressClearsText: Bool
    public var trailingSymbol: String?
    
    private weak var textfield: Textfield?
    private var isUpdatingSelection = false
    private var isUpdatingUI = false
    
    public var onlySpecifiersIfMaskedText: String { format.mask.extractUserInput(from: fullText) }
    public lazy var fullText: String = format.mask.applied(to: "").input {
        didSet {
            guard !isUpdatingUI else {
                return
            }
            
            isUpdatingUI = true
            defer { isUpdatingUI = false }
            
            updateUI()
        }
    }
    
    public init(
        format: Format,
        backspacePressClearsText: Bool = false,
        trailingSymbol: String? = nil
    ) {
        self.format = format
        self.backspacePressClearsText = backspacePressClearsText
        self.trailingSymbol = trailingSymbol
    }
    
    @discardableResult
    public func applyTo(textfield: Textfield) -> Self {
        self.textfield = textfield
        textfield.delegate = self
        textfield.keyboardType = format.mask.keyboardType()
        
        let userInput = format.mask.extractUserInput(from: fullText)
        let mask = format.mask.applied(to: userInput)
        
        let updateTextIfMasked: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            let userInput = self.format.mask.extractUserInput(from: self.fullText)
            self.setupMask(mask: self.format.mask.applied(to: userInput))
        }
        textfield.onBecomeFirstResponder = updateTextIfMasked
        textfield.onResignFirstResponder = updateTextIfMasked
        
        setupMask(mask: mask)
        return self
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            if backspacePressClearsText {
                textField.text = ""
            } else {
                setupMask(mask: format.mask.removeCharacters(from: fullText, in: range))
            }
            textField.sendActions(for: .editingChanged)
            return false
        }
        
        let maxSpecifiersLength = format.mask.maxSpecifiersLength()
        let currentUserInput = format.mask.extractUserInput(from: fullText)
        let availablePositions = maxSpecifiersLength - currentUserInput.count
        
        guard availablePositions > 0 else {
            return false
        }
        
        let cleanString: String
        if string.count == 1 {
            cleanString = string.filter { $0.isNumber }
        } else {
            cleanString = format.mask.removeLiterals(from: string.replacingOccurrences(of: " ", with: ""))
        }
        
        guard !cleanString.isEmpty else {
            return false
        }
        
        if cleanString.count >= maxSpecifiersLength {
            onPaste(cleanString)
        }
        else if cleanString.count > availablePositions {
            let combinedInput = currentUserInput + cleanString
            onPaste(combinedInput)
        } else {
            let newInput = currentUserInput + cleanString
            setupMask(mask: format.mask.applied(to: newInput))
        }
        
        textField.sendActions(for: .editingChanged)
        return false
    }

    private func onPaste(_ text: String) {
        guard let textfield = textfield else { return }
        
        let maxLength = format.mask.maxSpecifiersLength()
        let specifiers = format.mask.removeLiterals(from: text.replacingOccurrences(of: " ", with: ""))
        let newText = specifiers.count > maxLength ? String(specifiers.prefix(maxLength)) : specifiers
        let maskedText = format.mask.applied(to: newText)
        
        self.fullText = maskedText.input
        
        DispatchQueue.main.async { [weak self, weak textfield] in
            guard let self = self, let textfield = textfield else { return }
            self.isUpdatingSelection = true
            let userInput = self.format.mask.extractUserInput(from: self.fullText)
            let mask = self.format.mask.applied(to: userInput)
            let newPosition = textfield.position(from: textfield.beginningOfDocument, offset: mask.input.count) ?? textfield.beginningOfDocument
            textfield.selectedTextRange = textfield.textRange(from: newPosition, to: newPosition)
            self.isUpdatingSelection = false
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let userInput = format.mask.extractUserInput(from: fullText)
        setupMask(mask: format.mask.applied(to: userInput))
    }
    
    private func setupMask(mask: (input: String, maskToInput: String)) {
        let oldValue = self.fullText
        self.fullText = mask.input
        
        if oldValue == mask.input {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let textfield = textfield else { return }
        let userInput = format.mask.extractUserInput(from: fullText)
        let mask = format.mask.applied(to: userInput)
        
        if mask.input.isEmpty && !(textfield.placeholder?.isEmpty ?? true) && !textfield.isFirstResponder {
            textfield.attributedText = nil
        } else {
            let trailingWithString = mask.maskToInput + (trailingSymbol ?? "")
            textfield.attributedText = .combined(
                .init(mask.input, font: textfield.font ?? .systemFont(ofSize: 17), color: textfield.appearance.colors.textColor, textAlignment: textfield.textAlignment),
                .init(trailingWithString, font: textfield.font ?? .systemFont(ofSize: 17), color: format.maskedTextColor, textAlignment: textfield.textAlignment)
            )
        }
        
        isUpdatingSelection = true
        let newPosition = textfield.position(from: textfield.beginningOfDocument, offset: mask.input.count) ?? textfield.beginningOfDocument
        textfield.selectedTextRange = textfield.textRange(from: newPosition, to: newPosition)
        isUpdatingSelection = false
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard !isUpdatingSelection else {
            return
        }
        guard !isUpdatingUI else {
            return
        }
        guard let selectedTextRange = textField.selectedTextRange else { return }
        let endOffset = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
        
        let fullTextCount = fullText.count
        
        if endOffset > fullTextCount {
            isUpdatingSelection = true
            let userInput = format.mask.extractUserInput(from: fullText)
            let mask = format.mask.applied(to: userInput)
            let newPosition = textField.position(from: textField.beginningOfDocument, offset: mask.input.count) ?? textField.beginningOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            isUpdatingSelection = false
        }
    }
}

public extension MaskedTextfieldDelegate {
    func refreshMask() {
        let userInput = format.mask.extractUserInput(from: fullText)
        setupMask(mask: format.mask.applied(to: userInput))
    }
}
#endif
