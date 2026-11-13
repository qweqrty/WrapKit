import XCTest

final class KeyboardAccessoryUITests: XCTestCase {
    func test_textFieldAccessory_keepsCompactButtonStyleAndState_thenDoneDismissesKeyboard() throws {
        try verifyAccessory(mode: "textField")
    }

    func test_textViewAccessory_keepsCompactButtonStyleAndState_thenDoneDismissesKeyboard() throws {
        try verifyAccessory(mode: "textView")
    }

    func test_unstyledTextFieldAccessory_keepsReadableSemanticTitleAndState_thenDoneDismissesKeyboard() throws {
        try verifyAccessory(mode: "textFieldUnstyled")
    }

    private func verifyAccessory(mode: String) throws {
        guard #available(iOS 16.0, *) else {
            throw XCTSkip("Keyboard accessory fixture requires iOS 16")
        }
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--keyboard-accessory=\(mode)"]
        app.launch()
        defer { app.terminate() }

        let input = mode == "textView"
            ? app.textViews["keyboardAccessory.input"].firstMatch
            : app.textFields["keyboardAccessory.input"].firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 5), app.debugDescription)
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5), app.debugDescription)

        let done = app.buttons["keyboardAccessory.done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(done.isEnabled)
        XCTAssertTrue(done.isHittable)
        XCTAssertEqual(done.frame.width, 80, accuracy: 2)
        XCTAssertEqual(done.frame.height, 36, accuracy: 2)
        XCTAssertGreaterThan(done.frame.minX, app.frame.midX)
        attachScreenshot(app: app, name: "\(mode)_keyboard_accessory_enabled")

        app.buttons["keyboardAccessory.disable"].tap()
        expectation(for: NSPredicate(format: "enabled == false"), evaluatedWith: done)
        waitForExpectations(timeout: 5)
        XCTAssertEqual(app.staticTexts["keyboardAccessory.pressCount"].label, "Presses: 0")
        attachScreenshot(app: app, name: "\(mode)_keyboard_accessory_disabled")

        app.buttons["keyboardAccessory.enable"].tap()
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: done)
        waitForExpectations(timeout: 5)
        done.tap()
        let pressedOnce = NSPredicate(format: "label == %@", "Presses: 1")
        expectation(for: pressedOnce, evaluatedWith: app.staticTexts["keyboardAccessory.pressCount"])
        waitForExpectations(timeout: 5)
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        attachScreenshot(app: app, name: "\(mode)_keyboard_accessory_dismissed")
    }

    private func attachScreenshot(app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
