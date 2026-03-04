//
//  XCUIApplication+Extensions.swift
//  WrapKitTestUtils
//
//  Created by Stanislav Li on 2/2/26.
//

import Foundation
import XCTest

public extension XCUIApplication {
    @discardableResult
    func launchUI(
        scenario: String,
        language: String = "ru",
        locale: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        launchArguments += [
            "-ui-testing",
            "-use-stubs",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale ?? language
        ]

        launchEnvironment["STUBS_SCENARIO"] = scenario

        launch()
        XCTAssertTrue(
            wait(for: .runningForeground, timeout: 5),
            "App not in foreground",
            file: file,
            line: line
        )
        return self
    }
    
    // MARK: - open Cell
    func open(cell: XCUIElement, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Cell \(cell.identifier) not found", file: file, line: line)
        cell.tap()
    }
    
    func waitForIdle(
        timeout: TimeInterval = 2,
        poll: TimeInterval = 0.2,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let deadline = Date().addingTimeInterval(timeout)

        XCTAssertTrue(
            wait(for: .runningForeground, timeout: timeout),
            "App is not in foreground",
            file: file,
            line: line
        )

        while Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(poll))
        }
    }
}
