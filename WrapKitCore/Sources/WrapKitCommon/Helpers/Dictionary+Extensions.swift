//
//  Dictionary+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/6/25.
//

import Foundation

public extension Dictionary {
    func merged(_ other: [Key: Value]) -> [Key: Value] {
        var result = self
        result.merge(other) { (current, _) in current }
        return result
    }
}
