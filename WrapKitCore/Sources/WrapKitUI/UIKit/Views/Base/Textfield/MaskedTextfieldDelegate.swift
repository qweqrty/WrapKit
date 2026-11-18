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
            setupMask(mask: format.mask.applied(to: fullText))
        }
    }
    
    public var backspacePressClearsText: Bool
    public var trailingSymbol: String?
    
    private weak var textfield: Textfield?
    private var isUpdatingSelection = false
    private var isUpdatingUI = false
    
    public var input: String { format.mask.applied(to: fullText).input }
    public var onlySpecifiersIfMaskedText: String { format.mask.extractUserInput(from: fullText) }
    public var hasMaskTemplate: Bool { !format.mask.format.isEmpty }
    public lazy var fullText: String = format.mask.applied(to: "").input {
        didSet {
            guard !isUpdatingUI else {
                return
            }
            guard let textfield = textfield else { return }
            
            isUpdatingUI = true
            defer { isUpdatingUI = false }
            
            let mask = format.mask.applied(to: fullText)
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
        let mask = format.mask.applied(to: fullText)
        let updateTextIfMasked: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            let mask = self.format.mask
            self.setupMask(mask: mask.applied(to: self.fullText))
        }
        textfield.onBecomeFirstResponder = updateTextIfMasked
        textfield.onResignFirstResponder = updateTextIfMasked
        
        setupMask(mask: mask)
        return self
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty && backspacePressClearsText {
            textField.text = ""
        } else {
            let maxSpecifiersLength = format.mask.maxSpecifiersLength()
            let currentUserInput = format.mask.extractUserInput(from: fullText)
            
            let cleanString = format.mask.removeLiterals(from: string.replacingOccurrences(of: " ", with: ""))
            
            if cleanString.count >= maxSpecifiersLength {
                onPaste(cleanString)
            }
            
            else {
                if string.isEmpty {
                    var deletionRange = range
                    if range.length == 1 {
                        while deletionRange.location > 0,
                              format.mask.isLiteralCharacter(at: deletionRange.location) {
                            deletionRange.location -= 1
                        }
                    }
                    setupMask(mask: format.mask.removeCharacters(from: fullText, in: deletionRange))
                    isUpdatingSelection = true
                    let prefixLength = format.mask.applied(to: "").input.utf16.count
                    let offset = min(max(deletionRange.location, prefixLength), fullText.utf16.count)
                    if let position = textField.position(from: textField.beginningOfDocument, offset: offset) {
                        textField.selectedTextRange = textField.textRange(from: position, to: position)
                    }
                    isUpdatingSelection = false
                } else {
                    let text = fullText as NSString
                    let start = text.substring(to: min(range.location, text.length)).count
                    let end = text.substring(to: min(NSMaxRange(range), text.length)).count
                    let inputStart = min((0..<start).filter { !format.mask.isLiteralCharacter(at: $0) }.count, currentUserInput.count)
                    let inputEnd = min((0..<end).filter { !format.mask.isLiteralCharacter(at: $0) }.count, currentUserInput.count)
                    let capacity = maxSpecifiersLength - currentUserInput.count + inputEnd - inputStart
                    let inserted = String(cleanString.prefix(max(0, capacity)))
                    var newInput = Array(currentUserInput)
                    newInput.replaceSubrange(inputStart..<inputEnd, with: inserted)
                    setupMask(mask: format.mask.applied(to: String(newInput)))
                    let prefix = format.mask.applied(to: String(newInput.prefix(inputStart + inserted.count))).input
                    isUpdatingSelection = true
                    if let position = textField.position(from: textField.beginningOfDocument, offset: prefix.utf16.count) {
                        textField.selectedTextRange = textField.textRange(from: position, to: position)
                    }
                    isUpdatingSelection = false
                }
            }
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
            let mask = self.format.mask.applied(to: self.fullText)
            let newPosition = textfield.position(from: textfield.beginningOfDocument, offset: mask.input.count) ?? textfield.beginningOfDocument
            textfield.selectedTextRange = textfield.textRange(from: newPosition, to: newPosition)
            self.isUpdatingSelection = false
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        setupMask(mask: format.mask.applied(to: fullText))
    }
    
    private func setupMask(mask: (input: String, maskToInput: String)) {
        self.fullText = mask.input
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
            let mask = format.mask.applied(to: fullText)
            let newPosition = textField.position(from: textField.beginningOfDocument, offset: mask.input.count) ?? textField.beginningOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            isUpdatingSelection = false
        }
    }
}

public extension MaskedTextfieldDelegate {
    func refreshMask() {
        setupMask(mask: format.mask.applied(to: fullText))
    }
}
#endif
