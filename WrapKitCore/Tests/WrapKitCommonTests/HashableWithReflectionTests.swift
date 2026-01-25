//
//  HashableWithReflectionTests.swift
//  WrapKit
//
//  Created by Stanislav Li on 11/3/25.
//

import XCTest
import Foundation
import WrapKit
import WrapKitTestUtils

class HashableWithReflectionTests: XCTestCase {
    // MARK: - Basic Enum Tests (Existing)
    func test_enums() {
        XCTAssertNotEqual(EnumStub.first, EnumStub.second)
        XCTAssertNotEqual(EnumStub.second, EnumStub.third(""))
        XCTAssertNotEqual(EnumStub.third("test"), EnumStub.fourth("test"))
        XCTAssertEqual(EnumStub.third("test"), EnumStub.third("test"))
        XCTAssertNotEqual(EnumStub.fifth(.init(stringProp: "test")), EnumStub.sixth(.init(stringProp: "test")))
        XCTAssertEqual(EnumStub.fifth(.init(stringProp: "test")), EnumStub.fifth(.init(stringProp: "test")))
        XCTAssertNotEqual(EnumStub.fifth(.init(stringProp: "test")), EnumStub.fifth(.init(stringProp: "test1")))
    }
    
    // MARK: - Struct Tests
    func test_structs() {
        let struct1 = StructStub(intProp: 1, stringProp: "a")
        let struct2 = StructStub(intProp: 1, stringProp: "a")
        let struct3 = StructStub(intProp: 2, stringProp: "a")
        let struct4 = StructStub(intProp: 1, stringProp: "b")
        
        XCTAssertEqual(struct1, struct2)
        XCTAssertNotEqual(struct1, struct3)
        XCTAssertNotEqual(struct1, struct4)
    }
    
    // MARK: - Optional Values
    func test_optionalValues() {
        let optionalEnum1 = OptionalEnumStub.someValue("test")
        let optionalEnum2 = OptionalEnumStub.someValue("test")
        let optionalEnum3 = OptionalEnumStub.someValue("different")
        let optionalEnum4 = OptionalEnumStub.none
        
        XCTAssertEqual(optionalEnum1, optionalEnum2)
        XCTAssertNotEqual(optionalEnum1, optionalEnum3)
        XCTAssertNotEqual(optionalEnum1, optionalEnum4)
        XCTAssertEqual(OptionalEnumStub.none, OptionalEnumStub.none)
    }
    
    // MARK: - Nested Types
    func test_nestedTypes() {
        let nested1 = NestedStub(value: StructStub(intProp: 1, stringProp: "a"))
        let nested2 = NestedStub(value: StructStub(intProp: 1, stringProp: "a"))
        let nested3 = NestedStub(value: StructStub(intProp: 2, stringProp: "a"))
        
        XCTAssertEqual(nested1, nested2)
        XCTAssertNotEqual(nested1, nested3)
    }
    
    // MARK: - Collections
    func test_collections() {
        let collection1 = CollectionStub(
            array: [1, 2, 3],
            dict: ["a": 1, "b": 2],
            set: Set([1, 2, 3])
        )
        let collection2 = CollectionStub(
            array: [1, 2, 3],
            dict: ["a": 1, "b": 2],
            set: Set([1, 2, 3])
        )
        let collection3 = CollectionStub(
            array: [1, 2, 4],
            dict: ["a": 1, "b": 2],
            set: Set([1, 2, 3])
        )
        
        XCTAssertEqual(collection1, collection2)
        XCTAssertNotEqual(collection1, collection3)
    }
    
    // MARK: - Mixed Types
    func test_mixedTypes() {
        let mixed1 = MixedStub(
            int: 1,
            string: "test",
            optional: .some("value"),
            nested: StructStub(intProp: 2, stringProp: "nested")
        )
        let mixed2 = MixedStub(
            int: 1,
            string: "test",
            optional: .some("value"),
            nested: StructStub(intProp: 2, stringProp: "nested")
        )
        let mixed3 = MixedStub(
            int: 1,
            string: "different",
            optional: .some("value"),
            nested: StructStub(intProp: 2, stringProp: "nested")
        )
        
        XCTAssertEqual(mixed1, mixed2)
        XCTAssertNotEqual(mixed1, mixed3)
    }
    
    // MARK: - Empty Types
    func test_emptyTypes() {
        XCTAssertEqual(EmptyStructStub(), EmptyStructStub())
        XCTAssertEqual(EmptyEnumStub.case1, EmptyEnumStub.case1)
        XCTAssertNotEqual(EmptyEnumStub.case1, EmptyEnumStub.case2)
    }
}

// MARK: - UI Image / Enum payload regression tests
extension HashableWithReflectionTests {

    func test_regression_enumWithUIImageAssociatedValue_shouldIgnorePointerAddress() {
        #if canImport(UIKit)
        let img1 = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: nil)
        let img2 = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: nil)

        // Ensure they are different instances (pointer differs)
        XCTAssertFalse(img1 === img2)

        let e1 = ImageEnumStub.asset(img1)
        let e2 = ImageEnumStub.asset(img2)

        XCTAssertEqual(e1, e2)

        // Hashes for equal values should match
        XCTAssertEqual(e1.hashValue, e2.hashValue)

        // Set should deduplicate
        XCTAssertEqual(Set([e1, e2]).count, 1)
        #endif
    }

    func test_regression_enumWithUIImageOptionalAssociatedValue_someVsNone() {
        #if canImport(UIKit)
        let img = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: nil)

        let some1 = ImageOptionalEnumStub.asset(img)
        let some2 = ImageOptionalEnumStub.asset(img)
        let none = ImageOptionalEnumStub.asset(nil)

        XCTAssertEqual(some1, some2)
        XCTAssertNotEqual(some1, none)
        XCTAssertEqual(none, ImageOptionalEnumStub.asset(nil))

        // Hash consistency
        XCTAssertEqual(some1.hashValue, some2.hashValue)
        XCTAssertNotEqual(some1.hashValue, none.hashValue)
        #endif
    }

    func test_regression_uiImage_accessibilityIdentifier_affectsEquality() {
        #if canImport(UIKit)
        let imgA = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: "a")
        let imgB = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: "b")
        let imgC = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: "a")
        let imgD = makeTestUIImage(size: CGSize(width: 22, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: "a")

        XCTAssertNotEqual(ImageEnumStub.asset(imgA), ImageEnumStub.asset(imgB))
        XCTAssertEqual(ImageEnumStub.asset(imgA), ImageEnumStub.asset(imgC))
        XCTAssertNotEqual(ImageEnumStub.asset(imgA), ImageEnumStub.asset(imgD))
        #endif
    }

    func test_regression_uiImage_renderingMode_affectsEquality() {
        #if canImport(UIKit)
        let imgA = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: nil)
        let imgB = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysOriginal, accessibilityIdentifier: nil)

        XCTAssertNotEqual(ImageEnumStub.asset(imgA), ImageEnumStub.asset(imgB))
        #endif
    }

    func test_regression_uiImage_size_affectsEquality() {
        #if canImport(UIKit)
        let imgA = makeTestUIImage(size: CGSize(width: 24, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: nil)
        let imgB = makeTestUIImage(size: CGSize(width: 25, height: 24), renderingMode: .alwaysTemplate, accessibilityIdentifier: nil)

        XCTAssertNotEqual(ImageEnumStub.asset(imgA), ImageEnumStub.asset(imgB))
        #endif
    }

    func test_regression_enumWithNSImageAssociatedValue_shouldIgnorePointerAddress() {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let img1 = makeTestNSImage(size: CGSize(width: 24, height: 24), isTemplate: true)
        let img2 = makeTestNSImage(size: CGSize(width: 24, height: 24), isTemplate: true)

        // Different instances
        XCTAssertFalse(img1 === img2)

        let e1 = NSImageEnumStub.asset(img1)
        let e2 = NSImageEnumStub.asset(img2)

        XCTAssertEqual(e1, e2)
        XCTAssertEqual(e1.hashValue, e2.hashValue)
        XCTAssertEqual(Set([e1, e2]).count, 1)
        #endif
    }

    func test_regression_noCrash_forEmptyStructComparison() {
        // This regression covers the AnyHashable recursion / EXC_BAD_ACCESS bug.
        // If recursion is present, this line may crash.
        XCTAssertEqual(EmptyStructStub(), EmptyStructStub())
    }

    func test_regression_noCrash_forEmptyEnumComparison() {
        // Same idea, but for enum case comparisons.
        XCTAssertEqual(EmptyEnumStub.case1, EmptyEnumStub.case1)
        XCTAssertNotEqual(EmptyEnumStub.case1, EmptyEnumStub.case2)
    }
}


// MARK: - Test Types
private extension HashableWithReflectionTests {
    // Basic Types
    struct StructStub: HashableWithReflection {
        let intProp: Int?
        let stringProp: String
        
        public init(intProp: Int? = nil, stringProp: String) {
            self.intProp = intProp
            self.stringProp = stringProp
        }
    }
    
    enum EnumStub: HashableWithReflection {
        case first
        case second
        case third(String)
        case fourth(String)
        case fifth(StructStub)
        case sixth(StructStub)
    }
    
    // Optional Type
    enum OptionalEnumStub: HashableWithReflection {
        case someValue(String)
        case none
    }
    
    // Nested Type
    struct NestedStub: HashableWithReflection {
        let value: StructStub
    }
    
    // Collection Type
    struct CollectionStub: HashableWithReflection {
        let array: [Int]
        let dict: [String: Int]
        let set: Set<Int>
    }
    
    // Mixed Type
    struct MixedStub: HashableWithReflection {
        let int: Int
        let string: String
        let optional: String?
        let nested: StructStub
    }
    
    // Empty Types
    struct EmptyStructStub: HashableWithReflection {}
    
    enum EmptyEnumStub: HashableWithReflection {
        case case1
        case case2
    }
}

// MARK: - Regression types for UI image payloads
private extension HashableWithReflectionTests {

    #if canImport(UIKit)
    enum ImageEnumStub: HashableWithReflection {
        case asset(UIImage)
    }

    enum ImageOptionalEnumStub: HashableWithReflection {
        case asset(UIImage?)
    }

    func makeTestUIImage(size: CGSize, renderingMode: UIImage.RenderingMode, accessibilityIdentifier: String?) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            // empty image is fine; we only need stable metadata
        }.withRenderingMode(renderingMode)

        image.accessibilityIdentifier = accessibilityIdentifier
        return image
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    enum NSImageEnumStub: HashableWithReflection {
        case asset(NSImage)
    }

    func makeTestNSImage(size: CGSize, isTemplate: Bool) -> NSImage {
        let image = NSImage(size: size)
        image.isTemplate = isTemplate
        return image
    }
    #endif
}
