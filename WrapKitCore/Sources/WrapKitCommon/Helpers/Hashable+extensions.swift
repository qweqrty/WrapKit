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
        
        // For enums, include the case name by using String(describing: self)
        if mirror.displayStyle == .enum {
            hasher.combine(String(describing: self))
        }
        
        // Hash all child values
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
        
        // For enums, first check if they're the same case
        if lhsMirror.displayStyle == .enum && rhsMirror.displayStyle == .enum {
            let lhsDesc = String(describing: lhs)
            let rhsDesc = String(describing: rhs)
            if lhsDesc != rhsDesc {
                return false
            }
        }
        
        // Check if number of children match
        guard lhsMirror.children.count == rhsMirror.children.count else {
            return false
        }
        
        // Compare all children
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
