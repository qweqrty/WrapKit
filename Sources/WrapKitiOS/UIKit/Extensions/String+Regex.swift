//
//  String+Regex.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension String {
    static let nonEmptyRegex = #"^(?!\s*$).+"#
    static let onlyDigitsRegex = #"^(\s*|\d+)$"#
    static let nameRegex = "^[\\p{L}\\p{M}\\s'-]+$"
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let nonSymbolicRegex = "^[^\\W_]+$"
    static func lengthRegex(from min: Int, to max: Int) -> String {
        return "^.{\(min),\(max)}$"
    }
    
    func evaluate(regexes: String...) -> Bool {
        return regexes.reduce(true) { result, regex in
            return result && NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
        }
    }
}

public extension Optional where Wrapped == String {
    func evaluate(regexes: String...) -> Bool {
        return regexes.reduce(true) { result, regex in
            return result && NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
        }
    }
}
