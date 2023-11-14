//
//  Array+Extension.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Array where Element: Equatable {
    func optionalContains(_ element: Element?) -> Bool {
        if let element = element {
            return contains(element)
        } else {
            return false
        }
    }
}
