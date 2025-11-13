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

final class ButtonSnapshotTests: XCTestCase {
    func test_buttonOutput_default_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "Default")
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_DEFAULT_STATE_DARK")
    }
    
    func test_buttonOutput_enabled_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: false)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_ENABLED_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_ENABLED_STATE_DARK")
    }
    
    func test_buttonOutput_image_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image =  UIImage(systemName: "star.fill")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_STATE_DARK")
    }
    
    // MARK: - Set image tests
    func test_buttonOutput_image_assets() {
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let image = UIImage(systemName: "star.fill")
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_ASSET_LIGHT")
    }
    
    func test_buttonOutput_imageURL_state_light() {
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = URL(string: ImageTestLinks.light.rawValue)
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_URL_STATE_LIGHT")
    }
    
    func test_buttonOutput_imageURL_state_dark() {
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = URL(string: ImageTestLinks.dark.rawValue)
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_URL_STATE_DARK")
    }
    
    func test_buttonOutput_imageURLString_state_light() {
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let light = ImageTestLinks.light.rawValue
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_URLSTRING_STATE_LIGHT")
    }
    
    func test_buttonOutput_imageURLString_state_dark() {
        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        // WHEN
        let dark = ImageTestLinks.dark.rawValue
        sut.display(style: .init(backgroundColor: .cyan))
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_URLSTRING_STATE_DARK")
    }
    
    func test_buttonOutput_noUrl() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_NOURL_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_NOURL_DARK")
    }
    
    func test_buttonOutput_noURLString() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .cyan))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_IMAGE_NOURSTRINGL_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_IMAGE_NOURLSTRING_DARK")
    }
    
    func test_buttonOutput_with_spacing() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 50,
            style: .init(backgroundColor: .red)
        ))
        sut.display(style: .init(backgroundColor: .cyan))

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_WITH_SPACING_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_WITH_SPACING_STATE_DARK")
    }
    
    func test_buttonOutput_with_onPress() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display { [weak sut] in
            sut?.backgroundColor = .red
        }

        sut.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_WITH_TAP_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_WITH_TAP_STATE_DARK")
    }
    
    func test_buttonOutput_with_height() {
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_WITH_HEIGHT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_WITH_HEIGHT_STATE_DARK")
    }
    
    func test_buttonOutput_isHidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display(isHidden: false)

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_ISHIDDEN_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_ISHIDDEN_STATE_DARK")
    }
    
    // MARK: - ButtonStyle tests
    func test_buttonOutput_style_backgroundColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_BACKGROUN_DCOLOR_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_BACKGROUN_DCOLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_titleColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(backgroundColor: .cyan, titleColor: .red))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_TITLE_COLOR_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_TITLE_COLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_borderWidth() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            borderWidth: 4.0,
            borderColor: .red
        ))
        
        sut.display(title: "BUTTON WITH BORDER")
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_BORDER_WIDTH_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_BORDER_WIDTH_STATE_DARK")
    }
    
    // TODO: - Do it
    func test_buttonOutput_style_pressedColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .blue,
            pressedColor: .red,
        ))
        
        sut.touchesBegan([UITouch()], with: nil)
        
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_PRESSED_COLOR_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_PRESSED_COLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_pressedTintColor() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .white,
            titleColor: .blue,
            pressedTintColor: .red,
        ))
        sut.display(title: "PRESSED TINT COLOR")
        
        sut.touchesBegan([UITouch()], with: nil)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE_DARK")
    }
    
    func test_buttonOutput_style_font() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .cyan, font: .systemFont(ofSize: 24, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_FONT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_FONT_STATE_DARK")
    }
    
    func test_buttonOutput_style_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .cyan, cornerRadius: 40))

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_STYLE_CORNER_RADIUS_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_STYLE_CORNER_RADIUS_STATE_DARK")
    }
    
    func test_buttonOutput_with_no_url() {
        // GIVEN
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        
        // WHEN
        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.url(nil, nil), completion: nil)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "BUTTON_OUTPUT_NO_URL_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "BUTTON_OUTPUT_NO_URL_DARK")
    }
}

extension ButtonSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: Button, container: UIView) {
        let sut = Button()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(60, priority: .required)
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
            let container = UIView()
            container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
            container.backgroundColor = .clear
            return container
        }
}
