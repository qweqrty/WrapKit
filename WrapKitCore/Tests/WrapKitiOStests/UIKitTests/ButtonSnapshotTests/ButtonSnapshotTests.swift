//
//  ButtonSnapshotTests.swift
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

final class ButtonSnapshotTests: XCTestCase {

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
    func test_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let image = UIImage(systemName: "star.fill")
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, appearances: [.light], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, appearances: [.light], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.url
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, appearances: [.light], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.url
        sut.display(style: .init(backgroundColor: .blue))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, appearances: [.light], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.dark.url
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, appearances: [.dark], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.dark.url
        sut.display(style: .init(backgroundColor: .blue))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, appearances: [.dark], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.urlString
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, appearances: [.light], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageSnapshotFixture.light.urlString
        sut.display(style: .init(backgroundColor: .blue))
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, appearances: [.light], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let dark = ImageSnapshotFixture.dark.urlString
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, appearances: [.dark], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let dark = ImageSnapshotFixture.dark.urlString
        sut.display(style: .init(backgroundColor: .blue))
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, appearances: [.dark], reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .blue))
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: "Button.setImage is not part of ButtonOutput")
    }
    
    func test_fail_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .blue))
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: "Button.setImage is not part of ButtonOutput")
    }
    
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
    
    // TODO: - Do it
    func test_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .blue,
            pressedColor: .red,
        ))
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: "pressed state is driven by UIKit touch handling")
    }
    
    func test_fail_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .blue,
            pressedColor: .systemRed,
        ))
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: "pressed state is driven by UIKit touch handling")
    }
    
    func test_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .white,
            titleColor: .blue,
            pressedTintColor: .red,
        ))
        sut.display(title: "PRESSED TINT COLOR")
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: "pressed state is driven by UIKit touch handling")
    }
    
    func test_fail_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .white,
            titleColor: .blue,
            pressedTintColor: .systemRed,
        ))
        sut.display(title: "PRESSED TINT COLOR")
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: "pressed state is driven by UIKit touch handling")
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
    
    func test_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"
        
        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.url(nil, nil), completion: nil)
        
        // THEN
        assertUIKitOnlySnapshot(snapshot: sut, named: snapshotName, reason: "wrong-url placeholder belongs to UIKit image loading")
    }
    
    func test_fail_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"
        
        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(style: .init(backgroundColor: .blue))
        sut.setImage(.url(nil, nil), completion: nil)
        
        // THEN
        assertUIKitOnlySnapshotFail(snapshot: sut, named: snapshotName, reason: "wrong-url placeholder belongs to UIKit image loading")
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

    func test_uikitButton_accessibilityActivation_invokesOutputCallback() {
        let sut = makeSUT()
        var pressCount = 0

        sut.display(onPress: { pressCount += 1 })

        XCTAssertTrue(sut.uiKitButton.accessibilityActivate())
        XCTAssertEqual(pressCount, 1)
    }

    func test_uikitButton_disabledAccessibilityActivation_doesNotInvokeOutputCallback() {
        let sut = makeSUT()
        var pressCount = 0

        sut.display(onPress: { pressCount += 1 })
        sut.display(enabled: false)

        XCTAssertFalse(sut.uiKitButton.accessibilityActivate())
        XCTAssertEqual(pressCount, 0)
    }

    @available(iOS 17.0, *)
    func test_swiftUIButton_fixedFrame_containsContentInsets() {
        let view = SUIButtonView(
            model: .init(
                title: "Inset title",
                height: 48,
                width: 120,
                style: .init(backgroundColor: .systemBlue)
            ),
            isEnabled: true,
            fillsAvailableWidth: false,
            contentInsets: .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        )
        let hostingController = UIHostingController(rootView: view)

        let size = hostingController.sizeThatFits(
            in: CGSize(width: 1_000, height: 1_000)
        )

        XCTAssertEqual(size.width, 120, accuracy: 0.01)
        XCTAssertEqual(size.height, 48, accuracy: 0.01)
    }
}

private extension ButtonSnapshotTests {
    func makeSUT(
        height: CGFloat = 60,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> PairedButtonSnapshotSUT {
        let sut = PairedButtonSnapshotSUT(height: height)

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitButton, file: file, line: line)
        return sut
    }
}
