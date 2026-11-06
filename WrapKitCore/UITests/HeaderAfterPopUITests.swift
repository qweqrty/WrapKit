import XCTest

final class HeaderAfterPopUITests: XCTestCase {
    func test_primaryHeaderActionWorksBeforeAndAfterUIKitPushPop() throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("Native navigationHeader requires iOS 16")
        }
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--header-after-pop"]
        app.launch()
        defer { app.terminate() }

        let search = app.buttons["headerAfterPop.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(search.isEnabled)
        XCTAssertTrue(search.isHittable)
        search.tap()
        XCTAssertTrue(app.staticTexts["Presses: 1"].waitForExistence(timeout: 5), app.debugDescription)
        attachScreenshot(app: app, name: "header_primary_before_push")

        for expectedPressCount in 2...6 {
            app.buttons["headerAfterPop.push"].tap()
            XCTAssertTrue(app.staticTexts["headerAfterPop.child"].waitForExistence(timeout: 5), app.debugDescription)
            app.buttons["headerAfterPop.back"].tap()
            XCTAssertTrue(app.staticTexts["headerAfterPop.root"].waitForExistence(timeout: 5), app.debugDescription)
            XCTAssertTrue(search.isEnabled)
            XCTAssertTrue(search.isHittable)
            search.tap()
            XCTAssertTrue(
                app.staticTexts["Presses: \(expectedPressCount)"].waitForExistence(timeout: 5),
                app.debugDescription
            )
            attachScreenshot(app: app, name: "header_primary_after_pop_\(expectedPressCount - 1)")
        }
    }

    private func attachScreenshot(app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
