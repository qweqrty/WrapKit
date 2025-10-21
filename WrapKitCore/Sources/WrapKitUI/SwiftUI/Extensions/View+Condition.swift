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
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies the given transform if the given value is `not nil`.
    /// - Parameters:
    ///   - value: The optional value.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the  value is `not nil`.
    @ViewBuilder func `ifLet`<Content: View, T: Any>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
    }
}
