//
//  Array+Extension.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Array {
    func item(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

public extension Array where Element: Equatable {
    func optionalContains(_ element: Element?) -> Bool {
        if let element = element {
            return contains(element)
        } else {
            return false
        }
    }
}
