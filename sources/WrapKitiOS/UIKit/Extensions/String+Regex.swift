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
}
