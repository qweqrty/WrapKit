//
//  ButtonSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 5/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

private enum ImageTestLinks: String {
    case light = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
    case dark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"
}

class ButtonSnapshotTests: XCTestCase {
    func test_buttonOutput_default_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(title: "Default")
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_DEFAULT_STATE_DARK")
    }
    
    func test_buttonOutput_enabled_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: false)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_ENABLED_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_ENABLED_STATE_DARK")
    }
    
    func test_buttonOutput_image_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let image =  UIImage(systemName: "star.fill")
        sut.display(image: image)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_STATE_DARK")
    }
    
    // MARK: - Set image tests
    func test_buttonOutput_image_assets() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let image = UIImage(systemName: "star.fill")
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_ASSET_LIGHT")
    }
    
    func test_buttonOutput_imageURL_state_light() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = URL(string: ImageTestLinks.light.rawValue)
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_URL_STATE_LIGHT")
    }
    
    func test_buttonOutput_imageURL_state_dark() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = URL(string: ImageTestLinks.dark.rawValue)
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_URL_STATE_DARK")
    }
    
    func test_buttonOutput_imageURLString_state_light() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageTestLinks.light.rawValue
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_URLSTRING_STATE_LIGHT")
    }
    
    func test_buttonOutput_imageURLString_state_dark() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let dark = ImageTestLinks.dark.rawValue
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_URLSTRING_STATE_DARK")
    }
    
    func test_buttonOutput_noUrl() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_NOURL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_NOURL_DARK")
    }
    
    func test_buttonOutput_noURLString() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_NOURSTRINGL_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_NOURLSTRING_DARK")
    }
    
    func test_buttonOutput_with_spacing() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 50,
            style: .init(backgroundColor: .red)
        ))

        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_WITH_SPACING_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_WITH_SPACING_STATE_DARK")
    }
    
    func test_buttonOutput_with_onPress() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON WITH TAP")
        sut.display { [weak sut] in
            sut?.backgroundColor = .red
        }

        sut.onPress?()
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_WITH_TAP_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_WITH_TAP_STATE_DARK")
    }
    
    func test_buttonOutput_with_height() {
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

        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_WITH_HEIGHT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_WITH_HEIGHT_STATE_DARK")
    }
    
    func test_buttonOutput_isHidden() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(isHidden: false)

        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_ISHIDDEN_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_ISHIDDEN_STATE_DARK")
    }
    
    // MARK: - ButtonStyle tests
    func test_buttonOutput_style_backgroundColor() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_BACKGROUN_DCOLOR_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_BACKGROUN_DCOLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_titleColor() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(titleColor: .red))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_TITLE_COLOR_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_TITLE_COLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_borderWidth() {
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_BORDER_WIDTH_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_BORDER_WIDTH_STATE_DARK")
    }
    
    // TODO: - Do it
    func test_buttonOutput_style_pressedColor() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .blue,
            pressedColor: .red,
        ))
        
        sut.touchesBegan([UITouch()], with: nil)
        
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_PRESSED_COLOR_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_PRESSED_COLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_pressedTintColor() {
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
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_font() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(font: .systemFont(ofSize: 24, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_FONT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_FONT_STATE_DARK")
    }
    
    func test_buttonOutput_style_cornerRadius() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .cyan, cornerRadius: 40))

        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_CORNER_RADIUS_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_CORNER_RADIUS_STATE_DARK")
    }
}

extension ButtonSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Button {
        let sut = Button()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        return sut
    }
}
