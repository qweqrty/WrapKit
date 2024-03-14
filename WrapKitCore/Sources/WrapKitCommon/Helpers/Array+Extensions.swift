//
//  Array+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 21/12/23.
//

import Foundation

public extension Array where Element: Equatable {
    typealias Index2D = (row: Int, column: Int)

    func indexOf2D(element: Element) -> Index2D? {
        for (rowIndex, row) in enumerated() {
            if let column = (row as? [Element])?.firstIndex(of: element) {
                return (row: rowIndex, column: column)
            }
        }
        return nil
    }
}
