//
//  Mask.swift
//  WrapKit
//
//  Created by Stas Lee on 28/8/23.
//

import Foundation

public protocol Masking {
    init(format: [MaskedCharacter])
    var format: [MaskedCharacter] { get }
    func applied(to text: String) -> (input: String, maskToInput: String)
    func removeCharacters(from text: String, in range: NSRange) -> (input: String, maskToInput: String)
    func extractUserInput(from text: String) -> String  // Only characters associated with specifiers
    func isLiteralCharacter(at index: Int) -> Bool
    func maxSpecifiersLength() -> Int
    func removeLiterals(from text: String) -> String
}

public enum MaskedCharacter {
    case literal(Character)
    case specifier(placeholder: Character, allowedCharacters: CharacterSet)
    
    var mask: String {
        switch self {
        case .literal(let char):
            return String(char)
        case .specifier(let char, _):
            return String(char)
        }
    }
}

public struct Mask: Masking {
    public let format: [MaskedCharacter]
    
    public init(format: [MaskedCharacter]) {
        self.format = format
    }
    
    public func applied(to text: String) -> (input: String, maskToInput: String) {
        guard !format.isEmpty else {
            return (text, "")
        }
        
        let text = text.prefix(format.count)
        
        var input = ""
        var textIterator = text.startIndex
        
        for (offset, maskedCharacter) in format.enumerated() {
            guard textIterator < text.endIndex else {
                let literals = format.getLiterals(startingFrom: offset)
                input += literals.text
                return (input, format[literals.endIndex...].map { $0.mask }.joined())
            }
            let currentCharacter = text[textIterator]
            
            switch maskedCharacter {
            case .specifier(_, let allowedCharacters):
                if allowedCharacters.contains(currentCharacter) {
                    input += String(currentCharacter)
                    textIterator = text.index(after: textIterator)
                } else {
                    return (input, format[offset...].map { $0.mask }.joined())
                }
            case .literal(let character):
                input += String(character)
                textIterator = character == currentCharacter ? text.index(after: textIterator) : textIterator
            }
        }
        return (input, "")
    }
    
    public func removeCharacters(from text: String, in range: NSRange) -> (input: String, maskToInput: String) {
        guard !format.isEmpty else {
            let startIndex = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) ?? text.endIndex
            let endIndex = text.index(startIndex, offsetBy: range.length, limitedBy: text.endIndex) ?? text.endIndex
            let updatedText = text.replacingCharacters(in: startIndex..<endIndex, with: "")
            return (updatedText, "")
        }

        guard range.location >= 0, range.length > 0, range.location <= text.count else {
            return (text, format[max(text.count - 1, 0)...].map { $0.mask }.joined())
        }
        
        var removeCount = range.length
        var index = text.count - 1
        while index >= 0 {
            if format.indices.contains(index), case .literal = format.item(at: index) {
                removeCount += 1
            } else {
                break
            }
            index -= 1
        }
        let input = String(text.dropLast(removeCount))
        return (input, format[input.count...].map { $0.mask }.joined())
    }

    
    public func extractUserInput(from text: String) -> String {
        var result = ""
        for (index, character) in text.enumerated() {
            if !isLiteralCharacter(at: index) {
                result += String(character)
            }
        }
        return result
    }
    
    public func isLiteralCharacter(at index: Int) -> Bool {
        switch format.item(at: index) {
        case .literal:
            return true
        default:
            return false
        }
    }
}

extension Array where Element == MaskedCharacter {
    func getLiterals(startingFrom index: Int) -> (text: String, endIndex: Int) {
        var text = ""
        var endIndex = index
        
        for element in self[index...] {
            switch element {
            case .literal(let char):
                text += String(char)
                endIndex += 1
            case .specifier(_, _):
                return (text, endIndex)
            }
        }
        
        return (text, endIndex)
    }
}

public extension Mask {
    func maxSpecifiersLength() -> Int {
        return format.filter {
            switch $0 {
            case .specifier:
                return true
            case .literal:
                return false
            }
        }.count
    }
    
    func removeLiterals(from text: String) -> String {
        var result = ""
        var textIterator = text.startIndex
        
        for maskedCharacter in format {
            guard textIterator < text.endIndex else { break }
            let currentCharacter = text[textIterator]
            
            switch maskedCharacter {
            case .literal(let literalChar):
                if currentCharacter == literalChar {
                    textIterator = text.index(after: textIterator)
                }
            case .specifier:
                result.append(currentCharacter)
                textIterator = text.index(after: textIterator)
            }
        }
        
        while textIterator < text.endIndex {
            result.append(text[textIterator])
            textIterator = text.index(after: textIterator)
        }
        
        return result
    }
}
