//
//  Hashable+extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/5/24.
//

import Foundation

public protocol HashableWithReflection: Hashable {}

public extension HashableWithReflection {
    func hash(into hasher: inout Hasher) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let value = child.value as? AnyHashable {
                hasher.combine(value)
            } else {
                hasher.combine(String(describing: child.value))
            }
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        let lhsMirror = Mirror(reflecting: lhs)
        let rhsMirror = Mirror(reflecting: rhs)

        guard lhsMirror.children.count == rhsMirror.children.count else { return false }

        for (lhsChild, rhsChild) in zip(lhsMirror.children, rhsMirror.children) {
            if let lhsValue = lhsChild.value as? AnyHashable,
               let rhsValue = rhsChild.value as? AnyHashable {
                if lhsValue != rhsValue {
                    return false
                }
            } else {
                let lhsDescription = String(describing: lhsChild.value)
                let rhsDescription = String(describing: rhsChild.value)
                if lhsDescription != rhsDescription {
                    return false
                }
            }
        }

        return true
    }
}
