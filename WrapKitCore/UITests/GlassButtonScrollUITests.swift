import XCTest

final class GlassButtonScrollUITests: XCTestCase {
    func test_draggingFromGlassButtonScrollsWithoutActivatingIt_thenTapActivatesOnce() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Native glass buttons require iOS 26")
        }
        continueAfterFailure = false

        for mode in ["native", "wrapKit", "wrapKitShrink"] {
            let app = XCUIApplication()
            app.launchArguments = ["--glass-button-scroll=\(mode)"]
            app.launch()
            defer { app.terminate() }

            let button = app.buttons["glassScroll.button.2"]
            XCTAssertTrue(button.waitForExistence(timeout: 5), "\(mode): \(app.debugDescription)")
            XCTAssertTrue(button.isHittable, "\(mode): \(app.debugDescription)")
            let initialY = button.frame.minY
            attachScreenshot(app: app, name: "\(mode)_before_drag")

            let start = button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let end = start.withOffset(CGVector(dx: 0, dy: -180))
            start.press(forDuration: 0.05, thenDragTo: end)

            XCTAssertLessThan(button.frame.minY, initialY - 80, "\(mode): button drag must scroll its parent")
            XCTAssertEqual(app.staticTexts["glassScroll.pressCount"].label, "Presses: 0", "\(mode): dragging must cancel the button action")
            attachScreenshot(app: app, name: "\(mode)_after_drag")

            XCTAssertTrue(button.isHittable, "\(mode): \(app.debugDescription)")
            button.tap()
            XCTAssertTrue(app.staticTexts["Presses: 1"].waitForExistence(timeout: 5), "\(mode): \(app.debugDescription)")
            XCTAssertEqual(app.staticTexts["glassScroll.pressCount"].label, "Presses: 1")
            attachScreenshot(app: app, name: "\(mode)_before_hold")
            button.press(forDuration: 1.5)
            XCTAssertTrue(app.staticTexts["Presses: 2"].waitForExistence(timeout: 5), "\(mode): \(app.debugDescription)")
            XCTAssertEqual(app.staticTexts["glassScroll.pressCount"].label, "Presses: 2")
            attachScreenshot(app: app, name: "\(mode)_after_hold")
        }
    }

    private func attachScreenshot(app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
