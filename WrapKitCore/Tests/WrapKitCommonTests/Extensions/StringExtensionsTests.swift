import Foundation
import XCTest
@testable import WrapKit

final class StringExtensionsTests: XCTestCase {

    func testAsUrlTrimsWhitespace() {
        let string = "   https://example.com/path  \n"

        let url = string.asUrl

        XCTAssertEqual(url?.absoluteString, "https://example.com/path")
    }

    func testAsUrlPercentEncodesInvalidCharacters() {
        let string = "https://exam^ple.com/path with spaces"

        let url = string.asUrl

        XCTAssertEqual(url?.absoluteString, "https://exam%5Eple.com/path%20with%20spaces")
    }

    func testAsUrlAlreadyPercentEncodedIsNotDoubleEncoded() {
        let string = "https://example.com/path%20with%20spaces"

        let url = string.asUrl

        XCTAssertEqual(url?.absoluteString, "https://example.com/path%20with%20spaces")
    }

    func testAsUrlUppercasedSchemeIsAccepted() {
        let string = "HTTP://example.com"

        let url = string.asUrl

        XCTAssertEqual(url?.absoluteString, "HTTP://example.com")
    }

    func testAsUrlWithQueryNeedingEncoding() {
        let string = "https://example.com/search?q=hello world&lang=en"

        let url = string.asUrl

        XCTAssertEqual(url?.absoluteString, "https://example.com/search?q=hello%20world&lang=en")
    }

    func testAsUrlWithEmojiPath() {
        let string = "https://example.com/😃"

        let url = string.asUrl

        XCTAssertEqual(url?.absoluteString, "https://example.com/%F0%9F%98%83")
    }

    func testAsUrlReturnsNilWhenSchemeIsMissing() {
        XCTAssertNil("www.example.com/path".asUrl)
    }

    func testAsUrlReturnsNilOnPlainText() {
        XCTAssertNil("just some text without scheme".asUrl)
    }

    func testAsUrlReturnsNilOnEmptyString() {
        XCTAssertNil("   \n\t".asUrl)
    }

    func testToDateParsesMatchingFormat() {
        let dateString = "2024-02-29T12:34:56Z"
        let expected = ISO8601DateFormatter().date(from: dateString)

        XCTAssertEqual(dateString.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ"), expected)
    }

    func testToDateParsesCustomFormat() {
        let dateString = "29/02/2024"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let expected = formatter.date(from: dateString)

        XCTAssertEqual(dateString.toDate(dateFormat: "dd/MM/yyyy"), expected)
    }

    func testToDateReturnsNilOnFormatMismatch() {
        XCTAssertNil("02/29/2024".toDate(dateFormat: "yyyy-MM-dd"))
    }

    func testToDateReturnsNilOnInvalidDateValue() {
        XCTAssertNil("2024-02-30".toDate(dateFormat: "yyyy-MM-dd"))
    }
}
