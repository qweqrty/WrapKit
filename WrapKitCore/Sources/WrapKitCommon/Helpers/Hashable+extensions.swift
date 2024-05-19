//
//  Hashable+extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/5/24.
//

import Foundation

public protocol HashableWithReflection: Hashable {
    var createdAt: Date { get }
}

public extension HashableWithReflection {
    var createdAt: Date {
        return Date()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(createdAt)
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let value = child.value as? AnyHashable {
                hasher.combine(value)
            } else if let value = child.value as? CustomHashable {
                value.customHash(into: &hasher)
            }
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public protocol CustomHashable {
    func customHash(into hasher: inout Hasher)
}
