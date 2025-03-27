//
//  NumericConversionHelpersTests.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 24/3/25.
//

import XCTest
@testable import WrapKit
import WrapKitTestUtils

class NumericExtensionsTests: XCTestCase {
    func testBinaryIntegerasInt() {
        // Test typical cases
        let int8: Int8 = 42
        XCTAssertEqual(int8.asInt, 42)
        
        let uint8: UInt8 = 255
        XCTAssertEqual(uint8.asInt, 255)
        
        // Test zero
        let zero: Int16 = 0
        XCTAssertEqual(zero.asInt, 0)
        
        // Test large value within Int bounds
        let large: Int64 = Int64(Int.max)
        XCTAssertEqual(large.asInt, Int.max)
    }
    
    func testBinaryIntegerasFloat() {
        let int16: Int16 = 123
        XCTAssertEqual(int16.asFloat, 123.0)
        
        let uint16: UInt16 = 456
        XCTAssertEqual(uint16.asFloat, 456.0)
        
        let zero: Int32 = 0
        XCTAssertEqual(zero.asFloat, 0.0)
        
        let int64Max: Int64 = Int64.max
        XCTAssertEqual(int64Max.asFloat, 9.223372e18, accuracy: 1e13) // Approximate
    }
    
    func testBinaryIntegerasDouble() {
        let int32: Int32 = -789
        XCTAssertEqual(int32.asDouble, -789.0)
        
        let uint32: UInt32 = 1000
        XCTAssertEqual(uint32.asDouble, 1000.0)
        
        let zero: Int64 = 0
        XCTAssertEqual(zero.asDouble, 0.0)
        
        let int64Max: Int64 = Int64.max
        XCTAssertEqual(int64Max.asDouble, 9.223372036854776e18) // Exact
    }
    
    func testBinaryIntegerasIntOrZero() {
        let int8: Int8 = 42
        XCTAssertEqual(int8.asIntOrZero, 42)
        
        let uint8: UInt8 = 255
        XCTAssertEqual(uint8.asIntOrZero, 255)
        
        let zero: Int16 = 0
        XCTAssertEqual(zero.asIntOrZero, 0)
    }
    
    // MARK: - BinaryFloatingPoint Tests
    
    func testBinaryFloatingPointasInt() {
        let float: Float = 5.7
        XCTAssertEqual(float.asInt, 5) // Truncates
        
        let double: Double = -3.2
        XCTAssertEqual(double.asInt, -3) // Truncates
        
        let zero: Float = 0.0
        XCTAssertEqual(zero.asInt, 0)
        
        // Test edge cases
        let largeFloat: Float = Float(Int.max) + 1
        XCTAssertNil(largeFloat.asInt) // Should fail due to overflow
    }
    
    func testBinaryFloatingPointasFloat() {
        let double: Double = 123.456
        XCTAssertEqual(double.asFloat, Float(123.456), accuracy: 0.001)
        
        let float: Float = -789.123
        XCTAssertEqual(float.asFloat, -789.123)
        
        let zero: Double = 0.0
        XCTAssertEqual(zero.asFloat, 0.0)
    }
    
    func testBinaryFloatingPointasDouble() {
        let float: Float = 456.789
        XCTAssertEqual(float.asDouble, Double(456.789), accuracy: 0.001)
        
        let double: Double = -987.654
        XCTAssertEqual(double.asDouble, -987.654, accuracy: 0.001)
        
        let zero: Float = 0.0
        XCTAssertEqual(zero.asDouble, 0.0, accuracy: 0.001) // Accuracy not strictly needed for zero
    }
    
    func testBinaryFloatingPointasIntOrZero() {
        let float: Float = 5.7
        XCTAssertEqual(float.asIntOrZero, 5) // Truncates
        
        let double: Double = -3.2
        XCTAssertEqual(double.asIntOrZero, -3) // Truncates
        
        let largeFloat: Float = Float(Int.max) + 1
        XCTAssertEqual(largeFloat.asIntOrZero, 0) // Falls back to 0 on failure
    }
    
    // MARK: - Edge Cases
    
    func testEdgeCases() {
        // Test Int64 max/min conversion against Int32 range
        let int64Max: Int64 = Int64.max
        let int64Min: Int64 = Int64.min
        
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(int64Max.asInt)
            XCTAssertNil(int64Min.asInt)
            XCTAssertEqual(int64Max.asIntOrZero, 0)
            XCTAssertEqual(int64Min.asIntOrZero, 0)
        } else { // 64-bit
            XCTAssertEqual(int64Max.asInt, Int.max)
            XCTAssertEqual(int64Min.asInt, Int.min)
            XCTAssertEqual(int64Max.asIntOrZero, Int.max)
            XCTAssertEqual(int64Min.asIntOrZero, Int.min)
        }
        
        // Test just outside Int32 range
        let justAboveInt32Max: Int64 = Int64(Int32.max) + 1
        let justBelowInt32Min: Int64 = Int64(Int32.min) - 1
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(justAboveInt32Max.asInt)
            XCTAssertNil(justBelowInt32Min.asInt)
            XCTAssertEqual(justAboveInt32Max.asIntOrZero, 0)
            XCTAssertEqual(justBelowInt32Min.asIntOrZero, 0)
        } else { // 64-bit
            XCTAssertEqual(justAboveInt32Max.asInt, 2147483648)
            XCTAssertEqual(justBelowInt32Min.asInt, -2147483649)
        }
    }
    
    func testBinaryIntegerNegativeEdgeCases() {
        let int8Min: Int8 = Int8.min // -128
        XCTAssertEqual(int8Min.asInt, -128)
        XCTAssertEqual(int8Min.asIntOrZero, -128)
        
        let int16Min: Int16 = Int16.min // -32768
        XCTAssertEqual(int16Min.asInt, -32768)
        XCTAssertEqual(int16Min.asFloat, -32768.0)
        XCTAssertEqual(int16Min.asDouble, -32768.0)
    }
    
    func testBinaryIntegerUnsignedOverflow() {
        let uint64Max: UInt64 = UInt64.max // 18446744073709551615
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(uint64Max.asInt)
            XCTAssertEqual(uint64Max.asIntOrZero, 0)
        } else { // 64-bit
            XCTAssertNil(uint64Max.asInt) // Exceeds Int.max (9223372036854775807)
            XCTAssertEqual(uint64Max.asIntOrZero, 0)
        }
        
        XCTAssertEqual(uint64Max.asFloat, 1.8446744e19 as Float, accuracy: 1e15)
        XCTAssertEqual(uint64Max.asDouble, 1.8446744073709552e19)
        
        // Add Int64.max for comparison
        let int64Max: Int64 = Int64.max
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(int64Max.asInt) // Exceeds Int32.max
            XCTAssertEqual(int64Max.asIntOrZero, 0)
        } else { // 64-bit
            XCTAssertEqual(int64Max.asInt, Int.max) // Fits in 64-bit Int
            XCTAssertEqual(int64Max.asIntOrZero, Int.max)
        }
        XCTAssertEqual(int64Max.asFloat, 9.223372e18 as Float, accuracy: 1e13)
        XCTAssertEqual(int64Max.asDouble, 9.223372036854776e18)
    }
    
    func testBinaryIntegerasFloatPrecision() {
        let largeInt64: Int64 = 1_000_000_000_000_000 // 1e15
        XCTAssertEqual(largeInt64.asFloat, 1e15, accuracy: 1e10)
    }
    
    func testBinaryFloatingPointasFloatPrecision() {
        let preciseDouble: Double = 1.2345678901234567
        XCTAssertEqual(preciseDouble.asFloat, 1.234568, accuracy: 0.000001) // Float has ~7 digits precision
    }
    
    func testBinaryFloatingPointExtremes() {
        let infinity: Double = .infinity
        XCTAssertNil(infinity.asInt) // Should fail
        XCTAssertEqual(infinity.asIntOrZero, 0)
        
        let nan: Double = .nan
        XCTAssertNil(nan.asInt) // Should fail
        XCTAssertEqual(nan.asIntOrZero, 0)
        
        let subnormal: Double = Double.leastNonzeroMagnitude
        XCTAssertEqual(subnormal.asInt, 0) // Truncates to 0
        XCTAssertEqual(subnormal.asFloat, Float(subnormal), accuracy: 1e-45)
        
        // Test very large/small floating point
        let hugeDouble: Double = Double.greatestFiniteMagnitude
        XCTAssertNil(hugeDouble.asInt)
        XCTAssertEqual(hugeDouble.asIntOrZero, 0)
    }
    
    func testBinaryIntegerasFloatEdgeCases() {
        let veryLargeInt64: Int64 = 1 << 53 // Beyond Float’s exact integer range (2^24)
        
        XCTAssertEqual(veryLargeInt64.asFloat, 9.007199254740992e15, accuracy: 1e10)
        XCTAssertEqual(veryLargeInt64.asDouble, 9.007199254740992e15) // Exact
    }
    
    func testBinaryFloatingPointTruncation() {
        let floatUp: Float = 5.999
        XCTAssertEqual(floatUp.asInt, 5) // Truncates toward zero
        
        let floatDown: Float = -5.999
        XCTAssertEqual(floatDown.asInt, -5) // Truncates toward zero
    }
    
    func testBinaryIntegerConsistency() {
        let smallUInt: UInt8 = 200
        XCTAssertEqual(smallUInt.asInt, 200)
        XCTAssertEqual(smallUInt.asFloat, 200.0)
        XCTAssertEqual(smallUInt.asDouble, 200.0)
    }
}
