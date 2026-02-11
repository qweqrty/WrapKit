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
        
        let userInput = extractCleanUserInput(from: text)
        
        var input = ""
        var formatOffset = 0
        
        var userInputIterator = userInput.startIndex
        for maskedCharacter in format {
            switch maskedCharacter {
            case .literal(let character):
                input += String(character)
                
            case .specifier(_, let allowedCharacters):
                guard userInputIterator < userInput.endIndex else {
                    // Если пользовательский ввод закончился, возвращаем маску для остальных символов
                    return (input, format[formatOffset...].map { $0.mask }.joined())
                }
                
                let currentCharacter = userInput[userInputIterator]
                
                if allowedCharacters.contains(currentCharacter) {
                    input += String(currentCharacter)
                    userInputIterator = userInput.index(after: userInputIterator)
                } else {
                    return (input, format[formatOffset...].map { $0.mask }.joined())
                }
            }
            formatOffset += 1
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
        return extractCleanUserInput(from: text)
    }
    
    public func isLiteralCharacter(at index: Int) -> Bool {
        switch format.item(at: index) {
        case .literal:
            return true
        default:
            return false
        }
    }
    
    private func extractCleanUserInput(from text: String) -> String {
        let cleanText = text.filter { $0 != " " }
        
        let specifiersCount = maxSpecifiersLength()
        
        guard !cleanText.isEmpty, specifiersCount > 0 else {
            return cleanText
        }

        var initialLiterals: [Character] = []
        var foundFirstSpecifier = false

        for maskedCharacter in format {
            if case .literal(let char) = maskedCharacter {
                if char != " " && !foundFirstSpecifier {
                    initialLiterals.append(char)
                }
            } else {
                foundFirstSpecifier = true
                break
            }
        }

        if initialLiterals.isEmpty {
            return cleanText
        }

        let literalsString = String(initialLiterals)

        if cleanText.hasPrefix(literalsString) {
            let startIndex = cleanText.index(cleanText.startIndex, offsetBy: literalsString.count)
            let processedText = String(cleanText[startIndex...])
            return processedText
        }

        if cleanText.count <= specifiersCount {
            return cleanText
        }

        let overflow = cleanText.count - specifiersCount
        if overflow <= 2 {
            let endIndex = cleanText.index(cleanText.startIndex, offsetBy: specifiersCount)
            return String(cleanText[..<endIndex])
        }

        for i in 0...literalsString.count {
            let literalsSuffix = String(literalsString.suffix(literalsString.count - i))
            
            if !literalsSuffix.isEmpty && cleanText.hasPrefix(literalsSuffix) {
                let startIndex = cleanText.index(cleanText.startIndex, offsetBy: literalsSuffix.count)
                var userData = String(cleanText[startIndex...])
                
                if userData.count > specifiersCount {
                    let endIndex = userData.index(userData.startIndex, offsetBy: specifiersCount)
                    userData = String(userData[..<endIndex])
                }
                
                return userData
            }
        }

        if cleanText.count > specifiersCount {
            let endIndex = cleanText.index(cleanText.startIndex, offsetBy: specifiersCount)
            return String(cleanText[..<endIndex])
        }
        
        return cleanText
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
        return extractCleanUserInput(from: text)
    }
}
