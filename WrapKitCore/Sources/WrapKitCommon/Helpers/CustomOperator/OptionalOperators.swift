import Foundation

infix operator ??= : NilCoalescingPrecedence

public func ??=<T, U>(optional: T?, transform: (T) -> U?) -> U? {
    guard let value = optional else {
        return nil
    }
    return transform(value)
}
