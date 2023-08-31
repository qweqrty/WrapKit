//
//  CharacterSet+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 27/8/23.
//

import Foundation

public extension CharacterSet {
    func contains(_ character: Character) -> Bool {
        for scalar in character.unicodeScalars {
            if !contains(scalar) {
                return false
            }
        }
        return true
    }
}
