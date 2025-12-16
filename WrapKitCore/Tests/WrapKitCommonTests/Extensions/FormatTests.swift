import Foundation
import XCTest

final class DecimalFormattingTests: XCTestCase {
    func testOne() {
        assertDecimal(Decimal.leastNonzeroMagnitude, "0.00")
        assertDecimal(Decimal.nan, "nan")
    }
    
    func assertDecimal(
        _ decimal: String,
        withDecimalPlaces: Int = 2,
        locale: Locale = Locale(identifier: "en_US"),
        _ expected: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertDecimal(Decimal(string: decimal) ?? .quietNaN, withDecimalPlaces: withDecimalPlaces, locale: locale, expected, file: file, line: line)
    }
    
    func assertDecimal(
        _ decimal: Decimal,
        withDecimalPlaces: Int = 2,
        locale: Locale = Locale(identifier: "en_US"),
        _ expected: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(decimal.asString(withDecimalPlaces: withDecimalPlaces, locale: locale), expected, file: file, line: line)
    }
    
    // Test: Standard rounding to two decimal places
    func testStandardRounding() {
        assertDecimal("271.88499999999999", "271.88")
        assertDecimal("271.884", "271.88")
        assertDecimal("1.74", "1.74")
        assertDecimal("1.34", "1.34")
        assertDecimal("0.73", "0.73")
        assertDecimal("80.779750000000007", "80.77")
        assertDecimal("79.879999999999995", "79.87")
        assertDecimal("80.780000000000001", "80.78")
        assertDecimal("79.87572", "79.87")
        assertDecimal("123.56", "123.56")
        assertDecimal("121.56", "121.56")
        assertDecimal("1231", withDecimalPlaces: 2, "1,231.00")
        assertDecimal("1231.56", "1,231.56")
        assertDecimal("1234.28", "1,234.28")
        assertDecimal("0.9999999999999999", "0.99")
        assertDecimal("-79.879999999999995", "-79.87")
        assertDecimal("1.0000000000000001", withDecimalPlaces: 2, "1.00")
        assertDecimal("0.005", "0.00")
        assertDecimal("0.0051", "0.00")
        assertDecimal("9.995", "9.99")
        assertDecimal("9.9951", "9.99")
        assertDecimal("-79.879999999999995", "-79.87")
        assertDecimal("1234.999", "1,234.99")
        assertDecimal("1234.9999", "1,234.99")
        assertDecimal("1234.99999", "1,234.99")
        assertDecimal("1234.999999", "1,234.99")
        assertDecimal("0.0", "0.00")
        assertDecimal("0.001", "0.00")
        assertDecimal("999999.99", "999,999.99")
        assertDecimal("-1231.56", "-1,231.56")
        assertDecimal("1231.56", withDecimalPlaces: 0, "1,231")
        assertDecimal("0.123", "0.12")
        assertDecimal("1e-10", "0.00")
        assertDecimal(Decimal.leastNonzeroMagnitude, "0.00")
        assertDecimal(Decimal.nan, "nan")
        XCTAssertEqual(Double.infinity.asString(withDecimalPlaces: 2), "inf")
        XCTAssertEqual((-Double.infinity).asString(withDecimalPlaces: 2), "-inf")
        assertDecimal("123.456789", withDecimalPlaces: 1, locale: Locale(identifier: "en_US"), "123.4")
        assertDecimal("123.456789", withDecimalPlaces: 5, locale: Locale(identifier: "en_US"), "123.45678")
        let deLocale = Locale(identifier: "de_DE")
        assertDecimal("1231.56", withDecimalPlaces: 2, locale: deLocale, "1.231,56")
        assertDecimal("999999.99", withDecimalPlaces: 2, locale: deLocale, "999.999,99")
        assertDecimal("1231.999999", withDecimalPlaces: 0, "1,231")
        assertDecimal("0.49999999999999994", "0.49")
        assertDecimal("0.5", "0.50")
        assertDecimal("0.001234", withDecimalPlaces: 5, locale: Locale(identifier: "en_US"), "0.00123")
        
        // Simple cases
        assertDecimal("5.0", "5.00")
        assertDecimal("2.3", "2.30")
        assertDecimal("0.25", "0.25")
        assertDecimal("0.0001", "0.00")
        assertDecimal("-2.3", "-2.30")
        assertDecimal("5.67", withDecimalPlaces: 0, "5")
        assertDecimal("5.99", withDecimalPlaces: 0, "5")
        assertDecimal("0.0", withDecimalPlaces: 0, "0")
        assertDecimal("10.0", withDecimalPlaces: 0, "10")
        assertDecimal("10.0", "10.00")
        assertDecimal("0.73", "0.73")
        assertDecimal("1.73", "1.73")
        assertDecimal("1.74", "1.74")
        assertDecimal("0.0", withDecimalPlaces: 3, "0.000")
        assertDecimal("42.0", withDecimalPlaces: 0, "42")
        assertDecimal("0.9", "0.90")
        assertDecimal("-0.9", "-0.90")
        assertDecimal("1000.0", "1,000.00")
        assertDecimal("1000.12", "1,000.12")
        assertDecimal("0.999", "0.99")
        assertDecimal("0.9999", "0.99")
        assertDecimal("1.0", "1.00")
        
        assertDecimal("1234567890123.45", "1,234,567,890,123.45")
        assertDecimal("1.123456789012345678901234567890123456789", withDecimalPlaces: 10, "1.1234567890")

//        XCTAssertEqual(Double.greatestFiniteMagnitude.asString(withDecimalPlaces: 2), String(format: "%.2f", Double.greatestFiniteMagnitude))
        assertDecimal("123.456789", withDecimalPlaces: 10, "123.4567890000")
        assertDecimal("1234567890123456789.99", "1,234,567,890,123,456,789.99")
        assertDecimal(Decimal(Double(0.1)), "0.10")
        assertDecimal(Decimal(Double(0.9999999999999998)), "0.99")
        assertDecimal(Decimal(Double(2.675)), "2.67") // classic banker's rounding case
        assertDecimal(Decimal(-0.000001), withDecimalPlaces: 2, "0.00")

//        let arLocale = Locale(identifier: "ar_SA")
//        assertDecimal("1231.56", withDecimalPlaces: 2, locale: arLocale, "1٬231.56") // Check actual separators
    }
    
    // Test: Zero fractional part should show .00
    func testZeroFractionalPart() {
        assertDecimal("123.0", withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), "123.00")
    }
    
    // Test: Single digit fractional part should show one trailing zero
    func testSingleDigitFractionalPart() {
        assertDecimal("123.4", withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), "123.40")
    }
    
    // Test: Negative value should correctly format with a minus sign
    func testNegativeValue() {
        let value = "-123.456"
        assertDecimal(value, withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), "-123.45")
    }
    
    // Test: Large number with grouping separator for the US locale
    func testLargeNumberWithGroupingSeparator() {
        let value = "1234567.0"
        assertDecimal(value, withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), "1,234,567.00")
    }
    
    // Test: Locale-specific grouping and decimal separator for Kyrgyzstan
    func testDecimals() {
        let value1 = "1234.28"
        let expectedSeparator = Locale(identifier: "ky_KG").groupingSeparator ?? " "
        assertDecimal(value1, withDecimalPlaces: 2, locale: Locale(identifier: "ky_KG"), "1\(expectedSeparator)234,28")
        
        let value2 = "1234.89"
        assertDecimal(value2, withDecimalPlaces: 2, locale: Locale(identifier: "ky_KG"), "1\(expectedSeparator)234,89")
    }
    
    // Test: Large number in different locales
    func testLargeNumberWithGrouping() {
        let value = "987654321.123"
        assertDecimal(value, withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), "987,654,321.12")
        assertDecimal(value, withDecimalPlaces: 2, locale: Locale(identifier: "fr_FR"), "987\u{202f}654\u{202f}321,12")
    }
    
    // Test: Very small decimal value close to 0
    func testVerySmallValue() {
        let value = "0.0001234"
        assertDecimal(value, withDecimalPlaces: 4, locale: Locale(identifier: "en_US"), "0.0001")
    }
    
    // Test: Value of 0 should always return .00
    func testZeroValue() {
        let value = "0.0"
        assertDecimal(value, withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), "0.00")
    }
    
    // Test: NaN value should return a string representation of NaN
    func testNaNValue() {
        let value = Double.nan
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, String(Double.nan))
    }
    // Test: NaN value should return a string representation of NaN
    func testNaNDecimal() {
        assertDecimal(.nan, withDecimalPlaces: 2, locale: Locale(identifier: "en_US"), String(Double.nan))
    }
    
    // Test: Infinity value should return a string representation of Infinity
    func testInfinityValue() {
        let value = Double.infinity // Decimal do not have infinity
        let formatted = value.asString(withDecimalPlaces: 2, locale: Locale(identifier: "en_US"))
        XCTAssertEqual(formatted, String(Double.infinity))
    }
    
    // Test: Round up when exact match for rounding
    func testExactRounding() {
        assertDecimal(1.2345, "1.23")
    }
    
    // Test: Testing large negative values
    func testLargeNegativeValue() {
        assertDecimal(-987654321.123, "-987,654,321.12")
    }
    
    // Test: Testing more simple cases
    func testMoreSimpleCases() {
        let locale = Locale(identifier: "en_US")
        assertDecimal("3.14159", withDecimalPlaces: 2, locale: locale, "3.14")
        assertDecimal("42.0", withDecimalPlaces: 2, locale: locale, "42.00")
        assertDecimal("0.0", withDecimalPlaces: 2, locale: locale, "0.00")
        assertDecimal("100", withDecimalPlaces: 2, locale: locale, "100.00")
        assertDecimal("0.999", withDecimalPlaces: 2, locale: locale, "0.99")
        assertDecimal("1.0", withDecimalPlaces: 2, locale: locale, "1.00")
        assertDecimal("0.001", withDecimalPlaces: 2, locale: locale, "0.00")
        assertDecimal("0.009", withDecimalPlaces: 2, locale: locale, "0.00")
        assertDecimal("0.01", withDecimalPlaces: 2, locale: locale, "0.01")
        assertDecimal("0.09", withDecimalPlaces: 2, locale: locale, "0.09")
        assertDecimal("0.1", withDecimalPlaces: 2, locale: locale, "0.10")
        assertDecimal("0.9", withDecimalPlaces: 2, locale: locale, "0.90")
        assertDecimal("1.1", withDecimalPlaces: 2, locale: locale, "1.10")
        assertDecimal("1.9", withDecimalPlaces: 2, locale: locale, "1.90")
        assertDecimal("2.0", withDecimalPlaces: 2, locale: locale, "2.00")
        assertDecimal("2.1", withDecimalPlaces: 2, locale: locale, "2.10")
        assertDecimal("2.9", withDecimalPlaces: 2, locale: locale, "2.90")
        assertDecimal("3.0", withDecimalPlaces: 2, locale: locale, "3.00")
        assertDecimal("10.0", withDecimalPlaces: 2, locale: locale, "10.00")
        assertDecimal("10.1", withDecimalPlaces: 2, locale: locale, "10.10")
        assertDecimal("10.9", withDecimalPlaces: 2, locale: locale, "10.90")
        assertDecimal("100.0", withDecimalPlaces: 2, locale: locale, "100.00")
        assertDecimal("100.1", withDecimalPlaces: 2, locale: locale, "100.10")
        assertDecimal("100.9", withDecimalPlaces: 2, locale: locale, "100.90")
        assertDecimal("1000.0", withDecimalPlaces: 2, locale: locale, "1,000.00")
        assertDecimal("1000.1", withDecimalPlaces: 2, locale: locale, "1,000.10")
        assertDecimal("1000.9", withDecimalPlaces: 2, locale: locale, "1,000.90")
        assertDecimal("10000.0", withDecimalPlaces: 2, locale: locale, "10,000.00")
        assertDecimal("10000.1", withDecimalPlaces: 2, locale: locale, "10,000.10")
        assertDecimal("10000.9", withDecimalPlaces: 2, locale: locale, "10,000.90")
        assertDecimal("0.0", withDecimalPlaces: 2, locale: locale, "0.00")
        assertDecimal("0.0", withDecimalPlaces: 0, locale: locale, "0")
        assertDecimal("0.1", withDecimalPlaces: 0, locale: locale, "0")
        assertDecimal("0.9", withDecimalPlaces: 0, locale: locale, "0")
        assertDecimal("1.0", withDecimalPlaces: 0, locale: locale, "1")
        assertDecimal("1.1", withDecimalPlaces: 0, locale: locale, "1")
        assertDecimal("1.9", withDecimalPlaces: 0, locale: locale, "1")
        assertDecimal("2.0", withDecimalPlaces: 0, locale: locale, "2")
        assertDecimal("2.1", withDecimalPlaces: 0, locale: locale, "2")
        assertDecimal("2.9", withDecimalPlaces: 0, locale: locale, "2")
        assertDecimal("10.0", withDecimalPlaces: 0, locale: locale, "10")
        assertDecimal("10.1", withDecimalPlaces: 0, locale: locale, "10")
        assertDecimal("10.9", withDecimalPlaces: 0, locale: locale, "10")
        assertDecimal("100.0", withDecimalPlaces: 0, locale: locale, "100")
        assertDecimal("100.1", withDecimalPlaces: 0, locale: locale, "100")
        assertDecimal("100.9", withDecimalPlaces: 0, locale: locale, "100")
        assertDecimal("1000.0", withDecimalPlaces: 0, locale: locale, "1,000")
        assertDecimal("1000.1", withDecimalPlaces: 0, locale: locale, "1,000")
        assertDecimal("1000.9", withDecimalPlaces: 0, locale: locale, "1,000")
        assertDecimal("10000.0", withDecimalPlaces: 0, locale: locale, "10,000")
        assertDecimal("10000.1", withDecimalPlaces: 0, locale: locale, "10,000")
        assertDecimal("10000.9", withDecimalPlaces: 0, locale: locale, "10,000")
        assertDecimal("-0.0", withDecimalPlaces: 2, locale: locale, "0.00")
        assertDecimal("-0.1", withDecimalPlaces: 2, locale: locale, "-0.10")
        assertDecimal("-0.9", withDecimalPlaces: 2, locale: locale, "-0.90")
        assertDecimal("-1.0", withDecimalPlaces: 2, locale: locale, "-1.00")
        assertDecimal("-1.1", withDecimalPlaces: 2, locale: locale, "-1.10")
        assertDecimal("-1.9", withDecimalPlaces: 2, locale: locale, "-1.90")
        assertDecimal("-2.0", withDecimalPlaces: 2, locale: locale, "-2.00")
        assertDecimal("-2.1", withDecimalPlaces: 2, locale: locale, "-2.10")
        assertDecimal("-2.9", withDecimalPlaces: 2, locale: locale, "-2.90")
        assertDecimal("-10.0", withDecimalPlaces: 2, locale: locale, "-10.00")
        assertDecimal("-10.1", withDecimalPlaces: 2, locale: locale, "-10.10")
        assertDecimal("-10.9", withDecimalPlaces: 2, locale: locale, "-10.90")
        assertDecimal("-100.0", withDecimalPlaces: 2, locale: locale, "-100.00")
        assertDecimal("-100.1", withDecimalPlaces: 2, locale: locale, "-100.10")
        assertDecimal("-100.9", withDecimalPlaces: 2, locale: locale, "-100.90")
        assertDecimal("-1000.0", withDecimalPlaces: 2, locale: locale, "-1,000.00")
        assertDecimal("-1000.1", withDecimalPlaces: 2, locale: locale, "-1,000.10")
        assertDecimal("-1000.9", withDecimalPlaces: 2, locale: locale, "-1,000.90")
        assertDecimal("-10000.0", withDecimalPlaces: 2, locale: locale, "-10,000.00")
        assertDecimal("-10000.1", withDecimalPlaces: 2, locale: locale, "-10,000.10")
        assertDecimal("-10000.9", locale: locale, "-10,000.90")
        assertDecimal("0.999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.9999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.99999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.999999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.9999999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.99999999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.999999999", withDecimalPlaces: 3, "0.999")
        assertDecimal("0.9999999999", withDecimalPlaces: 3, "0.999")
        assertDecimal("1.0001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.00001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.000001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.0000001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.00000001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.000000001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.0000000001", withDecimalPlaces: 3, "1.000")
        assertDecimal("1.00000000001", withDecimalPlaces: 3, "1.000")
        assertDecimal("0.0001234", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456789", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567890", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678901", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456789012", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567890123", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678901234", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456789012345", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567890123456", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678901234567", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456789012345678", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567890123456789", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678901234567890", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456789012345678901", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567890123456789012", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678901234567890123", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.0001234567890123456789012345678901234", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.00012345678901234567890123456789012345", withDecimalPlaces: 4, locale: locale, "0.0001")
        assertDecimal("0.000123456789012345678901234567890123456", withDecimalPlaces: 4, locale: locale, "0.0001")
    }
}
