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
    func testBinaryIntegerToInt() {
        // Test typical cases
        let int8: Int8 = 42
        XCTAssertEqual(int8.toInt, 42)
        
        let uint8: UInt8 = 255
        XCTAssertEqual(uint8.toInt, 255)
        
        // Test zero
        let zero: Int16 = 0
        XCTAssertEqual(zero.toInt, 0)
        
        // Test large value within Int bounds
        let large: Int64 = Int64(Int.max)
        XCTAssertEqual(large.toInt, Int.max)
    }
    
    func testBinaryIntegerToFloat() {
        let int16: Int16 = 123
        XCTAssertEqual(int16.toFloat, 123.0)
        
        let uint16: UInt16 = 456
        XCTAssertEqual(uint16.toFloat, 456.0)
        
        let zero: Int32 = 0
        XCTAssertEqual(zero.toFloat, 0.0)
        
        let int64Max: Int64 = Int64.max
        XCTAssertEqual(int64Max.toFloat, 9.223372e18, accuracy: 1e13) // Approximate
    }
    
    func testBinaryIntegerToDouble() {
        let int32: Int32 = -789
        XCTAssertEqual(int32.toDouble, -789.0)
        
        let uint32: UInt32 = 1000
        XCTAssertEqual(uint32.toDouble, 1000.0)
        
        let zero: Int64 = 0
        XCTAssertEqual(zero.toDouble, 0.0)
        
        let int64Max: Int64 = Int64.max
        XCTAssertEqual(int64Max.toDouble, 9.223372036854776e18) // Exact
    }
    
    func testBinaryIntegerToIntOrZero() {
        let int8: Int8 = 42
        XCTAssertEqual(int8.toIntOrZero, 42)
        
        let uint8: UInt8 = 255
        XCTAssertEqual(uint8.toIntOrZero, 255)
        
        let zero: Int16 = 0
        XCTAssertEqual(zero.toIntOrZero, 0)
    }
    
    // MARK: - BinaryFloatingPoint Tests
    
    func testBinaryFloatingPointToInt() {
        let float: Float = 5.7
        XCTAssertEqual(float.toInt, 5) // Truncates
        
        let double: Double = -3.2
        XCTAssertEqual(double.toInt, -3) // Truncates
        
        let zero: Float = 0.0
        XCTAssertEqual(zero.toInt, 0)
        
        // Test edge cases
        let largeFloat: Float = Float(Int.max) + 1
        XCTAssertNil(largeFloat.toInt) // Should fail due to overflow
    }
    
    func testBinaryFloatingPointToFloat() {
        let double: Double = 123.456
        XCTAssertEqual(double.toFloat, Float(123.456), accuracy: 0.001)
        
        let float: Float = -789.123
        XCTAssertEqual(float.toFloat, -789.123)
        
        let zero: Double = 0.0
        XCTAssertEqual(zero.toFloat, 0.0)
    }
    
    func testBinaryFloatingPointToDouble() {
        let float: Float = 456.789
        XCTAssertEqual(float.toDouble, Double(456.789), accuracy: 0.001)
        
        let double: Double = -987.654
        XCTAssertEqual(double.toDouble, -987.654, accuracy: 0.001)
        
        let zero: Float = 0.0
        XCTAssertEqual(zero.toDouble, 0.0, accuracy: 0.001) // Accuracy not strictly needed for zero
    }
    
    func testBinaryFloatingPointToIntOrZero() {
        let float: Float = 5.7
        XCTAssertEqual(float.toIntOrZero, 5) // Truncates
        
        let double: Double = -3.2
        XCTAssertEqual(double.toIntOrZero, -3) // Truncates
        
        let largeFloat: Float = Float(Int.max) + 1
        XCTAssertEqual(largeFloat.toIntOrZero, 0) // Falls back to 0 on failure
    }
    
    // MARK: - Edge Cases
    
    func testEdgeCases() {
        // Test Int64 max/min conversion against Int32 range
        let int64Max: Int64 = Int64.max
        let int64Min: Int64 = Int64.min
        
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(int64Max.toInt)
            XCTAssertNil(int64Min.toInt)
            XCTAssertEqual(int64Max.toIntOrZero, 0)
            XCTAssertEqual(int64Min.toIntOrZero, 0)
        } else { // 64-bit
            XCTAssertEqual(int64Max.toInt, Int.max)
            XCTAssertEqual(int64Min.toInt, Int.min)
            XCTAssertEqual(int64Max.toIntOrZero, Int.max)
            XCTAssertEqual(int64Min.toIntOrZero, Int.min)
        }
        
        // Test just outside Int32 range
        let justAboveInt32Max: Int64 = Int64(Int32.max) + 1
        let justBelowInt32Min: Int64 = Int64(Int32.min) - 1
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(justAboveInt32Max.toInt)
            XCTAssertNil(justBelowInt32Min.toInt)
            XCTAssertEqual(justAboveInt32Max.toIntOrZero, 0)
            XCTAssertEqual(justBelowInt32Min.toIntOrZero, 0)
        } else { // 64-bit
            XCTAssertEqual(justAboveInt32Max.toInt, 2147483648)
            XCTAssertEqual(justBelowInt32Min.toInt, -2147483649)
        }
    }
    
    func testBinaryIntegerNegativeEdgeCases() {
        let int8Min: Int8 = Int8.min // -128
        XCTAssertEqual(int8Min.toInt, -128)
        XCTAssertEqual(int8Min.toIntOrZero, -128)
        
        let int16Min: Int16 = Int16.min // -32768
        XCTAssertEqual(int16Min.toInt, -32768)
        XCTAssertEqual(int16Min.toFloat, -32768.0)
        XCTAssertEqual(int16Min.toDouble, -32768.0)
    }
    
    func testBinaryIntegerUnsignedOverflow() {
        let uint64Max: UInt64 = UInt64.max // 18446744073709551615
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(uint64Max.toInt)
            XCTAssertEqual(uint64Max.toIntOrZero, 0)
        } else { // 64-bit
            XCTAssertNil(uint64Max.toInt) // Exceeds Int.max (9223372036854775807)
            XCTAssertEqual(uint64Max.toIntOrZero, 0)
        }
        
        XCTAssertEqual(uint64Max.toFloat, 1.8446744e19 as Float, accuracy: 1e15)
        XCTAssertEqual(uint64Max.toDouble, 1.8446744073709552e19)
        
        // Add Int64.max for comparison
        let int64Max: Int64 = Int64.max
        if MemoryLayout<Int>.size == 4 { // 32-bit
            XCTAssertNil(int64Max.toInt) // Exceeds Int32.max
            XCTAssertEqual(int64Max.toIntOrZero, 0)
        } else { // 64-bit
            XCTAssertEqual(int64Max.toInt, Int.max) // Fits in 64-bit Int
            XCTAssertEqual(int64Max.toIntOrZero, Int.max)
        }
        XCTAssertEqual(int64Max.toFloat, 9.223372e18 as Float, accuracy: 1e13)
        XCTAssertEqual(int64Max.toDouble, 9.223372036854776e18)
    }
    
    func testBinaryIntegerToFloatPrecision() {
        let largeInt64: Int64 = 1_000_000_000_000_000 // 1e15
        XCTAssertEqual(largeInt64.toFloat, 1e15, accuracy: 1e10)
    }
    
    func testBinaryFloatingPointToFloatPrecision() {
        let preciseDouble: Double = 1.2345678901234567
        XCTAssertEqual(preciseDouble.toFloat, 1.234568, accuracy: 0.000001) // Float has ~7 digits precision
    }
    
    func testBinaryFloatingPointExtremes() {
        let infinity: Double = .infinity
        XCTAssertNil(infinity.toInt) // Should fail
        XCTAssertEqual(infinity.toIntOrZero, 0)
        
        let nan: Double = .nan
        XCTAssertNil(nan.toInt) // Should fail
        XCTAssertEqual(nan.toIntOrZero, 0)
        
        let subnormal: Double = Double.leastNonzeroMagnitude
        XCTAssertEqual(subnormal.toInt, 0) // Truncates to 0
        XCTAssertEqual(subnormal.toFloat, Float(subnormal), accuracy: 1e-45)
        
        // Test very large/small floating point
        let hugeDouble: Double = Double.greatestFiniteMagnitude
        XCTAssertNil(hugeDouble.toInt)
        XCTAssertEqual(hugeDouble.toIntOrZero, 0)
    }
    
    func testBinaryIntegerToFloatEdgeCases() {
        let veryLargeInt64: Int64 = 1 << 53 // Beyond Float’s exact integer range (2^24)
        
        XCTAssertEqual(veryLargeInt64.toFloat, 9.007199254740992e15, accuracy: 1e10)
        XCTAssertEqual(veryLargeInt64.toDouble, 9.007199254740992e15) // Exact
    }
    
    func testBinaryFloatingPointTruncation() {
        let floatUp: Float = 5.999
        XCTAssertEqual(floatUp.toInt, 5) // Truncates toward zero
        
        let floatDown: Float = -5.999
        XCTAssertEqual(floatDown.toInt, -5) // Truncates toward zero
    }
    
    func testBinaryIntegerConsistency() {
        let smallUInt: UInt8 = 200
        XCTAssertEqual(smallUInt.toInt, 200)
        XCTAssertEqual(smallUInt.toFloat, 200.0)
        XCTAssertEqual(smallUInt.toDouble, 200.0)
    }
}
