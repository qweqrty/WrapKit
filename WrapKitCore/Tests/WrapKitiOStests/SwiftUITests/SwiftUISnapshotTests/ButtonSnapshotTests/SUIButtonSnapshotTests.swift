//
//  SUIButtonSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 5/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

#if canImport(SwiftUI)
import class SwiftUI.UIHostingController
#endif

final class SUIButtonSnapshotTests: XCTestCase {

    func test_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "Default")
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "Default.")
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: false)
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: true)
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let image =  UIImage(systemName: "star.fill")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let image =  UIImage(systemName: "star")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - Set image tests














    func test_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 50,
            style: .init(backgroundColor: .red)
        ))
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 40,
            style: .init(backgroundColor: .red)
        ))
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_postCallback_visualState() {
        let snapshotName = "BUTTON_WITH_TAP"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let onPress: () -> Void = { [weak sut] in
            sut?.display(style: .init(backgroundColor: .red))
        }
        sut.display(model: .init(
            title: "BUTTON WITH TAP",
            onPress: onPress
        ))
        sut.display(style: .init(backgroundColor: .cyan))
        // This snapshot verifies the presentation emitted after a callback. It is
        // intentionally not presented as proof of a synthesized SwiftUI hit.
        onPress()

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_postCallback_visualState() {
        let snapshotName = "BUTTON_WITH_TAP"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let onPress: () -> Void = { [weak sut] in
            sut?.display(style: .init(backgroundColor: .systemRed))
        }
        sut.display(model: .init(
            title: "BUTTON WITH TAP",
            onPress: onPress
        ))
        sut.display(style: .init(backgroundColor: .cyan))
        // This deliberately drives a different callback result and verifies that
        // the paired snapshot catches it; it does not claim SwiftUI hit testing.
        onPress()

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH height",
            image: UIImage(systemName: "star"),
            spacing: 50,
            height: 100,
            style: .init(backgroundColor: .red),
        ))
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH height",
            image: UIImage(systemName: "star"),
            spacing: 50,
            height: 0,
            style: .init(backgroundColor: .red),
        ))
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display(isHidden: false)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display(isHidden: true)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - ButtonStyle tests
    func test_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .red))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(backgroundColor: .cyan, titleColor: .red))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(title: "TITLE WITH COLOR.")
        sut.display(style: .init(backgroundColor: .cyan, titleColor: .red))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            borderWidth: 4.0,
            borderColor: .red
        ))

        sut.display(title: "BUTTON WITH BORDER")

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }


    func test_fail_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            borderWidth: 5.0,
            borderColor: .red
        ))

        sut.display(title: "BUTTON WITH BORDER")

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }





    func test_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .cyan, font: .systemFont(ofSize: 24, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .cyan, font: .systemFont(ofSize: 25, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"

        // GIVEN
        let sut = makeSUT(height: 100)

        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .cyan, cornerRadius: 40))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"

        // GIVEN
        let sut = makeSUT(height: 100)

        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .cyan, cornerRadius: 41))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }



    func test_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let style = ButtonStyle(
            backgroundColor: .systemBlue,
            loadingIndicatorColor: .red
        )

        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: true)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let style = ButtonStyle(
            backgroundColor: .systemBlue,
            loadingIndicatorColor: .red
        )

        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: false)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_buttonOutput_isLoading_state_false() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE_FALSE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let style = ButtonStyle(
            backgroundColor: .systemBlue,
            loadingIndicatorColor: .red
        )

        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: false)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

}

private extension SUIButtonSnapshotTests {
    func makeSUT(
        height: CGFloat = 60,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SwiftUIButtonSnapshotSUT {
        let sut = SwiftUIButtonSnapshotSUT(height: height)

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitButton, file: file, line: line)
        return sut
    }
}
