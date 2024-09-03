//
//  Queue.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

public struct Queue<T> {
    public var elements: [T] = []
    
    public init() {}

    public mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    public mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }
    
    public var head: T? {
        return elements.first
    }
    
    public var tail: T? {
        return elements.last
    }
}
