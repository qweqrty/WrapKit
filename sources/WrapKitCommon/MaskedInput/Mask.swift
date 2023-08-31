//
//  Mask.swift
//  WrapKit
//
//  Created by Stas Lee on 28/8/23.
//

import Foundation

public protocol Masking {
    init(format: [MaskedCharacter])
    func apply(to text: String) -> (input: String, maskToInput: String)
    func removeCharacters(from text: String, in range: NSRange) -> (input: String, maskToInput: String)
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
    private let format: [MaskedCharacter]
    
    public init(format: [MaskedCharacter]) {
        self.format = format
    }
    
    public func apply(to text: String) -> (input: String, maskToInput: String) {
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
        guard range.location >= 0, range.length > 0, range.location <= text.count else {
            return (text, format[max(text.count - 1, 0)...].map { $0.mask }.joined())
        }
        
        let start = text.index(text.startIndex, offsetBy: range.location)
        let end = text.index(start, offsetBy: range.length)
        var text = text
        text.removeSubrange(start..<end)
        text = apply(to: text).input
        var removeCount = 0
        var index = text.count - 1
        while index >= 0 {
            if format.indices.contains(index), case .literal = format[index] {
                removeCount += 1
            } else {
                break
            }
            index -= 1
        }
        let input = String(text.dropLast(removeCount))
        return (input, format[input.count...].map { $0.mask }.joined())
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


