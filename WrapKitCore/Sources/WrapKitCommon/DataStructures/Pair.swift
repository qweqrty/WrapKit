//
//  Pair.swift
//  WrapKit
//
//  Created by Stanislav Li on 12/12/24.
//

import Foundation

public struct Pair<T: Equatable & Hashable, U: Equatable & Hashable>: Equatable, Hashable, CustomStringConvertible {
    public let first: T
    public let second: U

    public init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }

    public static func == (lhs: Pair<T, U>, rhs: Pair<T, U>) -> Bool {
        return lhs.first == rhs.first && lhs.second == rhs.second
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(first)
        hasher.combine(second)
    }

    public var description: String {
        "\(first), \(second)"
    }
}
