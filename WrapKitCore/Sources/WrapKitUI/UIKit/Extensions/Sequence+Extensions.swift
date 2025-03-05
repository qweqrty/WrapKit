//
//  Sequence+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public extension Sequence {
    var withPreviousAndNext: [(Element?, Element, Element?)] {
        let optionalSelf = self.map(Optional.some)
        let next = optionalSelf.dropFirst() + [nil]
        let prev = [nil] + optionalSelf.dropLast()
        return zip(self, zip(prev, next)).map {
            ($1.0, $0, $1.1)
        }
    }
    
    var pairs: AnyIterator<(Element, Element?)> {
        return AnyIterator(sequence(state: makeIterator(), next: { it in
            it.next().map { ($0, it.next()) }
        }))
    }
}

public extension Sequence where Element: Hashable {
    var uniqued: [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
