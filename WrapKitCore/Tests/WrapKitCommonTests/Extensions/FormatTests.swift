import Foundation
import XCTest

final class DoubleFormattingTests: XCTestCase {
    // Test: Standard rounding to two decimal places
    func testStandardRounding() {
        XCTAssertEqual(271.88499999999999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "271.88")
        XCTAssertEqual(271.884.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "271.88")
        XCTAssertEqual(1.74.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1.74")
        XCTAssertEqual(1.34.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1.34")
        XCTAssertEqual(0.73.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.73")
        XCTAssertEqual(80.779750000000007.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "80.77")
//        XCTAssertEqual(79.879999999999995.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "79.87") // Decimal bug
        XCTAssertEqual(80.780000000000001.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "80.78")
        XCTAssertEqual(79.87572.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "79.87")
        XCTAssertEqual(123.56.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "123.56")
        XCTAssertEqual(121.56.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "121.56")
        XCTAssertEqual(1231.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,231.00")
        XCTAssertEqual(1231.56.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,231.56")
        XCTAssertEqual(1234.28.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234.28")
//        XCTAssertEqual(0.9999999999999999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.99")  // Decimal bug
//        XCTAssertEqual((-79.879999999999995).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-79.87")  // Decimal bug
        XCTAssertEqual(1.0000000000000001.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1.00")
        XCTAssertEqual(0.005.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual(0.0051.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual(9.995.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "9.99")
        XCTAssertEqual(9.9951.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "9.99")
//        XCTAssertEqual((-79.879999999999995).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-79.87")  // Decimal bug
        XCTAssertEqual(1234.999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234.99")
        XCTAssertEqual(1234.9999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234.99")
        XCTAssertEqual(1234.99999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234.99")
        XCTAssertEqual(1234.999999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234.99")
        XCTAssertEqual(0.0.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual(0.001.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual(999999.99.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "999,999.99")
        XCTAssertEqual((-1231.56).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-1,231.56")
        XCTAssertEqual(1231.56.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "1,231")
        XCTAssertEqual(0.123.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.12")
        XCTAssertEqual(1e-10.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual(Double.leastNonzeroMagnitude.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual(Double.nan.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "nan")
        XCTAssertEqual(Double.infinity.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "inf")
        XCTAssertEqual((-Double.infinity).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-inf")
        XCTAssertEqual(123.456789.asString(withDecimalPlaces: 1, locale: Locale(identifier: "en_US")), "123.4")
        XCTAssertEqual(123.456789.asString(withDecimalPlaces: 5, locale: Locale(identifier: "en_US")), "123.45678")
        let deLocale = Locale(identifier: "de_DE")
        XCTAssertEqual(1231.56.asString(withDecimalPlaces: 2, locale: deLocale), "1.231,56")
        XCTAssertEqual(999999.99.asString(withDecimalPlaces: 2, locale: deLocale), "999.999,99")
        XCTAssertEqual(1231.999999.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "1,231")
//        XCTAssertEqual(0.49999999999999994.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.49")  // Decimal bug
        XCTAssertEqual(0.5.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.50")
        XCTAssertEqual(0.001234.asString(withDecimalPlaces: 5, locale: Locale(identifier: "en_US")), "0.00123")
        
        // Simple cases
        XCTAssertEqual(5.0.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "5.00")
        XCTAssertEqual(2.3.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "2.30")
        XCTAssertEqual(0.25.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.25")
        XCTAssertEqual(0.0001.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.00")
        XCTAssertEqual((-2.3).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-2.30")
        XCTAssertEqual(5.67.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "5")
        XCTAssertEqual(5.99.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "5")
        XCTAssertEqual(0.0.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "0")
        XCTAssertEqual(10.0.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "10")
        XCTAssertEqual(10.0.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "10.00")
        XCTAssertEqual(0.73.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.73")
        XCTAssertEqual(1.73.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1.73")
        XCTAssertEqual(1.74.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1.74")
        XCTAssertEqual(0.0.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.000")
        XCTAssertEqual(42.0.asString(withDecimalPlaces: 0, locale: Locale(identifier: "en_US")), "42")
        XCTAssertEqual(0.9.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.90")
        XCTAssertEqual((-0.9).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-0.90")
        XCTAssertEqual(1000.0.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,000.00")
        XCTAssertEqual(1000.12.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,000.12")
        XCTAssertEqual(0.999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.99")
        XCTAssertEqual(0.9999.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "0.99")
        XCTAssertEqual(1.0.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1.00")
        
        //        XCTAssertEqual(1234567890123.45.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234,567,890,123.45")
        //        XCTAssertEqual(Double.greatestFiniteMagnitude.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), String(format: "%.2f", Double.greatestFiniteMagnitude))
        //        XCTAssertEqual(123.456789.asString(withDecimalPlaces: 10, locale: Locale(identifier: "en_US")), "123.4567890000")
        //        XCTAssertEqual(1234567890123456789.99.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "1,234,567,890,123,456,789.99")
        //        let arLocale = Locale(identifier: "ar_SA")
        //        XCTAssertEqual(1231.56.asString(withDecimalPlaces: 2, locale: arLocale), "1٬231.56") // Check actual separators
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
    
    // Test: Testing more simple cases
    func testMoreSimpleCases() {
        let locale = Locale(identifier: "en_US")
        XCTAssertEqual(3.14159.asString(withDecimalPlaces: 2, locale: locale), "3.14")
        XCTAssertEqual(42.0.asString(withDecimalPlaces: 2, locale: locale), "42.00")
        XCTAssertEqual(0.0.asString(withDecimalPlaces: 2, locale: locale), "0.00")
        XCTAssertEqual(100.asString(withDecimalPlaces: 2, locale: locale), "100.00")
        XCTAssertEqual(0.999.asString(withDecimalPlaces: 2, locale: locale), "0.99")
        XCTAssertEqual(1.0.asString(withDecimalPlaces: 2, locale: locale), "1.00")
        XCTAssertEqual(0.001.asString(withDecimalPlaces: 2, locale: locale), "0.00")
        XCTAssertEqual(0.009.asString(withDecimalPlaces: 2, locale: locale), "0.00")
        XCTAssertEqual(0.01.asString(withDecimalPlaces: 2, locale: locale), "0.01")
        XCTAssertEqual(0.09.asString(withDecimalPlaces: 2, locale: locale), "0.09")
        XCTAssertEqual(0.1.asString(withDecimalPlaces: 2, locale: locale), "0.10")
        XCTAssertEqual(0.9.asString(withDecimalPlaces: 2, locale: locale), "0.90")
        XCTAssertEqual(1.1.asString(withDecimalPlaces: 2, locale: locale), "1.10")
        XCTAssertEqual(1.9.asString(withDecimalPlaces: 2, locale: locale), "1.90")
        XCTAssertEqual(2.0.asString(withDecimalPlaces: 2, locale: locale), "2.00")
        XCTAssertEqual(2.1.asString(withDecimalPlaces: 2, locale: locale), "2.10")
        XCTAssertEqual(2.9.asString(withDecimalPlaces: 2, locale: locale), "2.90")
        XCTAssertEqual(3.0.asString(withDecimalPlaces: 2, locale: locale), "3.00")
        XCTAssertEqual(10.0.asString(withDecimalPlaces: 2, locale: locale), "10.00")
        XCTAssertEqual(10.1.asString(withDecimalPlaces: 2, locale: locale), "10.10")
        XCTAssertEqual(10.9.asString(withDecimalPlaces: 2, locale: locale), "10.90")
        XCTAssertEqual(100.0.asString(withDecimalPlaces: 2, locale: locale), "100.00")
        XCTAssertEqual(100.1.asString(withDecimalPlaces: 2, locale: locale), "100.10")
        XCTAssertEqual(100.9.asString(withDecimalPlaces: 2, locale: locale), "100.90")
        XCTAssertEqual(1000.0.asString(withDecimalPlaces: 2, locale: locale), "1,000.00")
        XCTAssertEqual(1000.1.asString(withDecimalPlaces: 2, locale: locale), "1,000.10")
        XCTAssertEqual(1000.9.asString(withDecimalPlaces: 2, locale: locale), "1,000.90")
        XCTAssertEqual(10000.0.asString(withDecimalPlaces: 2, locale: locale), "10,000.00")
        XCTAssertEqual(10000.1.asString(withDecimalPlaces: 2, locale: locale), "10,000.10")
        XCTAssertEqual(10000.9.asString(withDecimalPlaces: 2, locale: locale), "10,000.90")
        XCTAssertEqual(0.0.asString(withDecimalPlaces: 2, locale: locale), "0.00")
        XCTAssertEqual(0.0.asString(withDecimalPlaces: 0, locale: locale), "0")
        XCTAssertEqual(0.1.asString(withDecimalPlaces: 0, locale: locale), "0")
        XCTAssertEqual(0.9.asString(withDecimalPlaces: 0, locale: locale), "0")
        XCTAssertEqual(1.0.asString(withDecimalPlaces: 0, locale: locale), "1")
        XCTAssertEqual(1.1.asString(withDecimalPlaces: 0, locale: locale), "1")
        XCTAssertEqual(1.9.asString(withDecimalPlaces: 0, locale: locale), "1")
        XCTAssertEqual(2.0.asString(withDecimalPlaces: 0, locale: locale), "2")
        XCTAssertEqual(2.1.asString(withDecimalPlaces: 0, locale: locale), "2")
        XCTAssertEqual(2.9.asString(withDecimalPlaces: 0, locale: locale), "2")
        XCTAssertEqual(10.0.asString(withDecimalPlaces: 0, locale: locale), "10")
        XCTAssertEqual(10.1.asString(withDecimalPlaces: 0, locale: locale), "10")
        XCTAssertEqual(10.9.asString(withDecimalPlaces: 0, locale: locale), "10")
        XCTAssertEqual(100.0.asString(withDecimalPlaces: 0, locale: locale), "100")
        XCTAssertEqual(100.1.asString(withDecimalPlaces: 0, locale: locale), "100")
        XCTAssertEqual(100.9.asString(withDecimalPlaces: 0, locale: locale), "100")
        XCTAssertEqual(1000.0.asString(withDecimalPlaces: 0, locale: locale), "1,000")
        XCTAssertEqual(1000.1.asString(withDecimalPlaces: 0, locale: locale), "1,000")
        XCTAssertEqual(1000.9.asString(withDecimalPlaces: 0, locale: locale), "1,000")
        XCTAssertEqual(10000.0.asString(withDecimalPlaces: 0, locale: locale), "10,000")
        XCTAssertEqual(10000.1.asString(withDecimalPlaces: 0, locale: locale), "10,000")
        XCTAssertEqual(10000.9.asString(withDecimalPlaces: 0, locale: locale), "10,000")
        XCTAssertEqual((-0.0).asString(withDecimalPlaces: 2, locale: locale), "0.00")
        XCTAssertEqual((-0.1).asString(withDecimalPlaces: 2, locale: locale), "-0.10")
        XCTAssertEqual((-0.9).asString(withDecimalPlaces: 2, locale: locale), "-0.90")
        XCTAssertEqual((-1.0).asString(withDecimalPlaces: 2, locale: locale), "-1.00")
        XCTAssertEqual((-1.1).asString(withDecimalPlaces: 2, locale: locale), "-1.10")
        XCTAssertEqual((-1.9).asString(withDecimalPlaces: 2, locale: locale), "-1.90")
        XCTAssertEqual((-2.0).asString(withDecimalPlaces: 2, locale: locale), "-2.00")
        XCTAssertEqual((-2.1).asString(withDecimalPlaces: 2, locale: locale), "-2.10")
        XCTAssertEqual((-2.9).asString(withDecimalPlaces: 2, locale: locale), "-2.90")
        XCTAssertEqual((-10.0).asString(withDecimalPlaces: 2, locale: locale), "-10.00")
        XCTAssertEqual((-10.1).asString(withDecimalPlaces: 2, locale: locale), "-10.10")
        XCTAssertEqual((-10.9).asString(withDecimalPlaces: 2, locale: locale), "-10.90")
        XCTAssertEqual((-100.0).asString(withDecimalPlaces: 2, locale: locale), "-100.00")
        XCTAssertEqual((-100.1).asString(withDecimalPlaces: 2, locale: locale), "-100.10")
        XCTAssertEqual((-100.9).asString(withDecimalPlaces: 2, locale: locale), "-100.90")
        XCTAssertEqual((-1000.0).asString(withDecimalPlaces: 2, locale: locale), "-1,000.00")
        XCTAssertEqual((-1000.1).asString(withDecimalPlaces: 2, locale: locale), "-1,000.10")
        XCTAssertEqual((-1000.9).asString(withDecimalPlaces: 2, locale: locale), "-1,000.90")
        XCTAssertEqual((-10000.0).asString(withDecimalPlaces: 2, locale: locale), "-10,000.00")
        XCTAssertEqual((-10000.1).asString(withDecimalPlaces: 2, locale: locale), "-10,000.10")
        XCTAssertEqual((-10000.9).asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US")), "-10,000.90")
        XCTAssertEqual(0.999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.9999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.99999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.999999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.9999999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.99999999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.999999999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(0.9999999999.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "0.999")
        XCTAssertEqual(1.0001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.00001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.000001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.0000001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.00000001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.000000001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.0000000001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(1.00000000001.asString(withDecimalPlaces: 3, locale: Locale(identifier: "en_US")), "1.000")
        XCTAssertEqual(0.0001234.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456789.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567890.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678901.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456789012.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567890123.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678901234.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456789012345.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567890123456.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678901234567.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456789012345678.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567890123456789.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678901234567890.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456789012345678901.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567890123456789012.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678901234567890123.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.0001234567890123456789012345678901234.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.00012345678901234567890123456789012345.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
        XCTAssertEqual(0.000123456789012345678901234567890123456.asString(withDecimalPlaces: 4, locale: Locale(identifier: "en_US")), "0.0001")
    }
}
