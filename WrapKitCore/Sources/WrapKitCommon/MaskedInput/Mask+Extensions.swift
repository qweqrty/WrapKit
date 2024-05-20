//
//  Mask+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/5/24.
//

import Foundation

public extension Mask {
  enum Registrator {
    public static let phoneNumber = Mask(
      format: [
        .literal("+"),
        .literal("9"),
        .literal("9"),
        .literal("6"),
        .literal(" "),
        .specifier(placeholder: "7", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "0", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "3", allowedCharacters: .decimalDigits),
        .literal(" "),
        .specifier(placeholder: "0", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "0", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "0", allowedCharacters: .decimalDigits),
        .literal(" "),
        .specifier(placeholder: "8", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "3", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "2", allowedCharacters: .decimalDigits),
      ]
    )
    
    public static let otp = Mask(
      format: (0..<6).map { _ in .specifier(placeholder: "X", allowedCharacters: .decimalDigits) }
    )
    
    public static let icc = Mask(
      format: (0..<18).map { _ in .specifier(placeholder: "X", allowedCharacters: .decimalDigits) }
    )
    
    public static let passportNumber = Mask(
      format: [
        .specifier(placeholder: "I", allowedCharacters: .letters),
        .specifier(placeholder: "D", allowedCharacters: .letters),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "X", allowedCharacters: .decimalDigits)
      ]
    )
    
    public static let date = Mask(
      format: [
        .specifier(placeholder: "d", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "d", allowedCharacters: .decimalDigits),
        .literal("."),
        .specifier(placeholder: "m", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "m", allowedCharacters: .decimalDigits),
        .literal("."),
        .specifier(placeholder: "y", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "y", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "y", allowedCharacters: .decimalDigits),
        .specifier(placeholder: "y", allowedCharacters: .decimalDigits)
      ]
    )
  }
}
