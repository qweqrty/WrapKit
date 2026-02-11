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
        let specifiersCount = maxSpecifiersLength()
        guard specifiersCount > 0 else {
            return text
        }

        var initialLiterals = ""
        var foundSpecifier = false
        for item in format {
            switch item {
            case .literal(let c):
                if !foundSpecifier {
                    initialLiterals.append(c)
                }
            case .specifier:
                foundSpecifier = true
            }
        }

        let countryCode = initialLiterals.filter(\.isNumber)

        let allowed: CharacterSet = format.compactMap {
            if case .specifier(_, let set) = $0 { return set }
            return nil
        }.reduce(CharacterSet()) { $0.union($1) }

        let clean = text.filter { allowed.contains($0) }

        // Проверяем, содержит ли исходный текст литералы (например "+996 " содержит "+", " ")
        let textWithoutAllowed = text.filter { !allowed.contains($0) }
        let hasLiterals = !textWithoutAllowed.isEmpty
        
        // СЛУЧАЙ 1: Текст уже отформатирован (содержит литералы)
        // Например: "+996 123" → clean = "996123"
        // Удаляем countryCode из начала, чтобы получить чистые данные пользователя
        if !countryCode.isEmpty && hasLiterals && clean.hasPrefix(countryCode) {
            let start = clean.index(clean.startIndex, offsetBy: countryCode.count)
            return String(clean[start...])
        }
        
        // СЛУЧАЙ 2: Вставка без литералов, но с переполнением
        // Например: "996777888999" (12 символов > 9)
        // ВАЖНО: Небольшое переполнение (1-2 символа) - это попытка обычного ввода
        // Реальная вставка имеет значительное переполнение (3+ символа)
        let overflow = clean.count - specifiersCount
        
        if !countryCode.isEmpty &&
           clean.hasPrefix(countryCode) &&
           overflow > 2 {
            // Значительное переполнение - это точно вставка
            let start = clean.index(clean.startIndex, offsetBy: countryCode.count)
            let result = String(clean[start...])
            // Обрезаем до specifiersCount
            if result.count > specifiersCount {
                let end = result.index(result.startIndex, offsetBy: specifiersCount)
                return String(result[..<end])
            }
            return result
        }
        
        // Небольшое переполнение (1-2 символа) - обрезаем без удаления countryCode
        if clean.count > specifiersCount {
            let end = clean.index(clean.startIndex, offsetBy: specifiersCount)
            return String(clean[..<end])
        }

        // СЛУЧАЙ 3: Обычный ввод пользователя (без литералов, длина ≤ specifiersCount)
        // Например: "996", "9961", "996123456"
        // Возвращаем как есть, пользователь может вводить что угодно
        return clean
    }
    
//    private func extractCleanUserInput(from text: String) -> String {
//        let specifiersCount = maxSpecifiersLength()
//        guard specifiersCount > 0 else {
//            return text
//        }
//
//        // 1. Собираем начальные литералы (для определения кода страны)
//        var initialLiterals = ""
//        var foundSpecifier = false
//        for item in format {
//            switch item {
//            case .literal(let c):
//                if !foundSpecifier {
//                    initialLiterals.append(c)
//                }
//            case .specifier:
//                foundSpecifier = true
//                break
//            }
//        }
//
//        let countryCode = initialLiterals.filter(\.isNumber)          // например "996" или "7"
//
//        // 2. Все разрешённые символы из всех specifier'ов (обычно .decimalDigits)
//        let allowed: CharacterSet = format.compactMap {
//            if case .specifier(_, let set) = $0 { return set }
//            return nil
//        }.reduce(CharacterSet()) { $0.union($1) }
//
//        // 3. Оставляем только то, что разрешено маской (убираем литералы, пробелы и т.д.)
//        let clean = text.filter { allowed.contains($0) }
//
//        // 4. Если после очистки начинается ровно с кода страны — убираем его
//        //    (только полный матч, как вы просили)
//        if !countryCode.isEmpty && clean.hasPrefix(countryCode) {
//            let start = clean.index(clean.startIndex, offsetBy: countryCode.count)
//            return String(clean[start...])
//        }
//
//        // 5. Во всех остальных случаях (typing, частичный код, дата и т.д.) — возвращаем как есть
//        return clean
//    }
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
