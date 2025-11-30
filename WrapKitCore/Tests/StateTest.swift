//
//  StateTest.swift
//  WrapKit
//
//  Created by Stanislav Li on 30/11/25.
//

import Foundation
import XCTest
import SwiftUI
import Combine
import WrapKit

final class SwiftUIStateTests: XCTestCase {

    func test_case1() {
        let suite = SwiftUIStateTestSuite()
        XCTAssertEqual(suite.case1(), "abc")
    }

    func test_case2() {
        let suite = SwiftUIStateTestSuite()
        XCTAssertEqual(suite.case2(), "xx")
    }

    func test_case3() {
        let suite = SwiftUIStateTestSuite()
        XCTAssertEqual(suite.case3(), "xyzxyz")
    }

    func test_case4() {
        let suite = SwiftUIStateTestSuite()
        XCTAssertEqual(suite.case4(), "ok")
    }

    func test_case5() {
        let suite = SwiftUIStateTestSuite()
        XCTAssertEqual(suite.case5(), "hello")
    }

    func test_case6() {
        let suite = SwiftUIStateTestSuite()
        XCTAssertEqual(suite.case6(), "111")
    }

}
