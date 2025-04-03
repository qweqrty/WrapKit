public extension BinaryInteger {
    /// Converts to an `Int`, returning `nil` if the value is outside `Int`’s range.
    /// - Example: `Int64.max.toInt` → `nil` on 32-bit systems (Int.max = 2147483647), `9223372036854775807` on 64-bit.
    /// - Example: `UInt(5).toInt` → `5` (fits in Int range).
    var asInt: Int? {
        return Int(exactly: self)
    }
    
    /// Converts to a `Float`, approximating if necessary (non-optional).
    /// - Note: Large integers may lose precision when converted to `Float`.
    /// - Example: `UInt64.max.toFloat` → `1.8446744e+19` (approximate, loses precision).
    /// - Example: `Int64.max.toFloat` → `9.223372e+18` (approximate, loses precision).
    var asFloat: Float {
        return Float(self)
    }
    
    /// Converts to a `Double`, approximating if necessary (non-optional).
    /// - Note: Large integers may lose precision when converted to `Double`.
    /// - Example: `UInt64.max.toDouble` → `1.8446744073709552e+19` (exact for `UInt64.max`).
    /// - Example: `Int64.max.toDouble` → `9.223372036854776e+18` (exact for `Int64.max`).
    var asDouble: Double {
        return Double(self)
    }
    
    /// Converts to an `Int`, falling back to `0` if outside `Int`’s range.
    /// - Example: `Int64.max.toIntOrZero` → `0` on 32-bit, `9223372036854775807` on 64-bit.
    /// - Example: `UInt(5).toIntOrZero` → `5`.
    var asIntOrZero: Int {
        return asInt ?? 0
    }
}

public extension BinaryFloatingPoint {
    /// Converts to an `Int`, truncating toward zero, returning `nil` if outside `Int`’s range.
    /// - Example: `Double(3.9).toInt` → `3` (truncates).
    /// - Example: `Float(1e40).toInt` → `nil` (exceeds Int.max).
    /// - Example: `Double(-5.7).toInt` → `-5` (truncates).
    var asInt: Int? {
        return asInt(roundingRule: .towardZero)
    }
    
    /// Converts to an `Int` using the specified rounding rule, returning `nil` if the rounded value is outside `Int`’s range.
    /// - Parameter roundingRule: The rounding rule to apply (e.g. `.up`, `.down`, `.towardZero`, `.awayFromZero`).
    /// - Example: `Double(5.7).asInt(roundingRule: .up)` → `6`
    /// - Example: `Double(3.9).asInt(roundingRule: .towardZero)` → `3`
    func asInt(roundingRule: FloatingPointRoundingRule) -> Int? {
        return Int(exactly: rounded(roundingRule))
    }
    
    /// Converts to a `Float`, preserving the value (non-optional).
    /// - Note: May lose precision if the value exceeds `Float`’s range or precision.
    /// - Example: `Double(3.141592653589793).toFloat` → `3.1415927` (rounded to `Float` precision).
    /// - Example: `Float(42.0).toFloat` → `42.0` (exact).
    var asFloat: Float {
        return Float(self)
    }
    
    /// Converts to a `Double`, preserving the value (non-optional).
    /// - Note: Always safe for `Float` → `Double` (no precision loss).
    /// - Example: `Float(3.14).toDouble` → `3.140000104904175` (exact representation of `Float`).
    /// - Example: `Double(1e50).toDouble` → `1e50` (exact).
    var asDouble: Double {
        return Double(self)
    }
    
    /// Converts to an `Int`, truncating toward zero, falling back to `0` if outside `Int`’s range.
    /// - Example: `Double(3.9).toIntOrZero` → `3`.
    /// - Example: `Float(1e40).toIntOrZero` → `0` (out of range).
    /// - Example: `Double(-5.7).toIntOrZero` → `-5`.
    var asIntOrZero: Int {
        return asInt ?? 0
    }
}
