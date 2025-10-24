//
//  View+Condition.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 21/10/25.
//

import SwiftUI

public extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        @ViewBuilder modifier: (Self) -> Content
    ) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
    
    /// Applies the given transform if the given value is `not nil`.
    /// - Parameters:
    ///   - value: The optional value.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the  value is `not nil`.
    @ViewBuilder
    func `ifLet`<Content: View, T: Any>(
        _ value: T?,
        @ViewBuilder modifier: (Self, T) -> Content
    ) -> some View {
        if let value {
            modifier(self, value)
            self
        }
    }
    
    func `ifLet`<T: Any>(
        _ value: T?,
        modifier: (Self, T) -> Self
    ) -> Self {
        if let value {
            modifier(self, value)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        modifier(self)
    }
    
    @ViewBuilder
    func modify(@ViewBuilder _ modifier: (Self) -> Self) -> Self {
        modifier(self)
    }
}
