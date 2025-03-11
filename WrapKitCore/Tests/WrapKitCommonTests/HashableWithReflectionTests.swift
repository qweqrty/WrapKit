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
