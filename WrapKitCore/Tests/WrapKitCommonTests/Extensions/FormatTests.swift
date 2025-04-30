//
//  FormatTests.swift
//  WrapKit
//
//  Created by Stanislav Li on 24/4/25.
//

import Foundation
import XCTest

final class DoubleFormattingTests: XCTestCase {
    // Test: Standard rounding to two decimal places
    func testStandardRounding() {
//        XCTAssertEqual(271.88499999999999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "271.88") // WTF
//        XCTAssertEqual(271.88499999999999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "271.88") // WTF
        XCTAssertEqual(271.884.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "271.88")
        XCTAssertEqual(123.56.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "123.56")
        XCTAssertEqual(121.56.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "121.56")
        XCTAssertEqual(1231.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,231.00")
        XCTAssertEqual(1231.56.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,231.56")
    }
    
    // Test: Zero fractional part should show .00
    func testZeroFractionalPart() {
        let value = 123.0
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "123.00")
    }
    
    // Test: Single digit fractional part should show one trailing zero
    func testSingleDigitFractionalPart() {
        let value = 123.4
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "123.40")
    }
    
    // Test: Negative value should correctly format with a minus sign
    func testNegativeValue() {
        let value = -123.456
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "-123.45")
    }
    
    // Test: Large number with grouping separator for the US locale
    func testLargeNumberWithGroupingSeparator() {
        let value = 1234567.0
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "1,234,567.00")
    }
    
    // Test: Locale-specific grouping and decimal separator for Kyrgyzstan
    func testDecimals() {
        let value = 1234.28
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "ky_KG"))
        let expectedSeparator = Locale(identifier: "ky_KG").groupingSeparator ?? " "
        XCTAssertEqual(formatted, "1\(expectedSeparator)234,28")
        
        let value1 = 1234.89
        let formatted1 = value1.asString(withDecimalPlaces: 2, locale: Locale(identifier: "ky_KG"))
        XCTAssertEqual(formatted1, "1\(expectedSeparator)234,89")
    }
    
    // Test: Large number in different locales
    func testLargeNumberWithGrouping() {
        let value = 987654321.123
        let formattedUS = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        let formattedFR = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "fr_FR"))
        XCTAssertEqual(formattedUS, "987,654,321.12")
        XCTAssertEqual(formattedFR, "987\u{202f}654\u{202f}321,12")
    }
    
    // Test: Very small decimal value close to 0
    func testVerySmallValue() {
        let value = 0.0001234
        let formatted = value.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "0.0001")
    }
    
    // Test: Value of 0 should always return .00
    func testZeroValue() {
        let value = 0.0
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "0.00")
    }
    
    // Test: NaN value should return a string representation of NaN
    func testNaNValue() {
        let value = Double.nan
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, String(Double.nan))
    }
    
    // Test: Infinity value should return a string representation of Infinity
    func testInfinityValue() {
        let value = Double.infinity
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, String(Double.infinity))
    }
    
    // Test: Round up when exact match for rounding
    func testExactRounding() {
        let value = 1.2345
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "1.23")
    }
    
    // Test: Testing large negative values
    func testLargeNegativeValue() {
        let value = -987654321.123
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, "-987,654,321.12")
    }
}
