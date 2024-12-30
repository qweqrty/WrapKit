import Foundation

// Define a custom infix operator `??=` with the same precedence as the Nil-Coalescing operator (`??`).
infix operator ??= : NilCoalescingPrecedence

/// A custom operator that applies a transformation to an optional value if it exists.
///
/// - Parameters:
///   - optional: An optional value of type `T?`.
///   - transform: A closure that takes a non-optional value of type `T` and returns an optional value of type `U?`.
///
/// - Returns:
///   - If `optional` contains a value, the `transform` closure is applied to it, and its result is returned.
///   - If `optional` is `nil`, the operator directly returns `nil`.
///
/// This operator allows for concise handling of transformations on optional values, similar to chaining `map` and `flatMap` on `Optional`.
///
/// Example Usage:
/// ```
/// let number: Int? = 5
/// let result: String? = number ??= { "\($0)" } // Transforms Int? to String?
/// print(result) // Prints: Optional("5")
///
/// let emptyNumber: Int? = nil
/// let emptyResult: String? = emptyNumber ??= { "\($0)" } // Transforms Int? to String?
/// print(emptyResult) // Prints: nil
/// ```
public func ??=<T, U>(optional: T?, transform: (T) -> U?) -> U? {
    // Check if `optional` has a value.
    guard let value = optional else {
        // If `optional` is nil, return nil immediately.
        return nil
    }
    // Apply the transformation and return the result.
    return transform(value)
}
