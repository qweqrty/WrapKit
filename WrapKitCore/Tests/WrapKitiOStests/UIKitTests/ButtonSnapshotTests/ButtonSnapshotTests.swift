#if os(iOS) || targetEnvironment(macCatalyst)
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
    @MainActor
    func test_buttonOutput_filledGlass_preservesBackgroundAfterEnabledUpdates() {
        let button = WrapKit.Button()
        button.display(model: .init(
            title: "Order details",
            height: 48,
            style: .init(
                backgroundColor: .systemGreen,
                titleColor: .white,
                font: .systemFont(ofSize: 17, weight: .semibold),
                glassConfiguration: .glass
            ),
            enabled: true,
            onPress: {}
        ))
        let host = makeGlassButtonHost(button: button)

        assertSnapshots(host, named: "BUTTON_GLASS_FILLED_ENABLED")
        button.display(enabled: false)
        assertSnapshots(host, named: "BUTTON_GLASS_FILLED_DISABLED")
        button.display(enabled: true)
        assertSnapshots(host, named: "BUTTON_GLASS_FILLED_ENABLED")
    }

    func test_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "Default")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "Default.")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: false)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "Enabled")
        sut.display(enabled: true)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        let image =  UIImage(systemName: "star.fill")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_removingImageTint_restoresLegacyImageAppearance() {
        let (sut, _) = makeSUT()
        let normalImage = UIImage(systemName: "star.fill")!.withRenderingMode(.alwaysOriginal)
        let highlightedImage = UIImage(systemName: "star")!.withRenderingMode(.alwaysOriginal)
        let originalTintColor = UIColor.systemGreen
        let originalSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)

        if #available(iOS 15.0, *) {
            sut.configuration = nil
        }
        sut.tintColor = originalTintColor
        sut.setImage(normalImage, for: .normal)
        sut.setImage(highlightedImage, for: .highlighted)
        sut.setPreferredSymbolConfiguration(originalSymbolConfiguration, forImageIn: .normal)

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .highlighted)?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === normalImage)
        XCTAssertTrue(sut.image(for: .highlighted) === highlightedImage)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysOriginal)
        XCTAssertEqual(sut.image(for: .highlighted)?.renderingMode, .alwaysOriginal)
        XCTAssertEqual(sut.tintColor, originalTintColor)
        XCTAssertEqual(
            sut.preferredSymbolConfigurationForImage(in: .normal),
            originalSymbolConfiguration
        )
    }

    func test_buttonOutput_imageTint_preservesStateSpecificImages() {
        let (sut, _) = makeSUT()
        let normalImage = makeImage(width: 11)
        let highlightedImage = makeImage(width: 12)
        let selectedImage = makeImage(width: 13)
        let disabledImage = makeImage(width: 14)

        if #available(iOS 15.0, *) {
            sut.configuration = nil
        }
        sut.setImage(normalImage, for: .normal)
        sut.setImage(highlightedImage, for: .highlighted)
        sut.setImage(selectedImage, for: .selected)
        sut.setImage(disabledImage, for: .disabled)

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.image(for: .normal)?.size, normalImage.size)
        XCTAssertEqual(sut.image(for: .highlighted)?.size, highlightedImage.size)
        XCTAssertEqual(sut.image(for: .selected)?.size, selectedImage.size)
        XCTAssertEqual(sut.image(for: .disabled)?.size, disabledImage.size)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .highlighted)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .selected)?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.image(for: .disabled)?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === normalImage)
        XCTAssertTrue(sut.image(for: .highlighted) === highlightedImage)
        XCTAssertTrue(sut.image(for: .selected) === selectedImage)
        XCTAssertTrue(sut.image(for: .disabled) === disabledImage)
    }

    @available(iOS 15.0, *)
    func test_buttonOutput_imageTint_updatesConfigurationWithStateSpecificImages() {
        let (sut, _) = makeSUT()
        let normalImage = makeImage(width: 11)
        let highlightedImage = makeImage(width: 12)
        let selectedImage = makeImage(width: 13)
        let disabledImage = makeImage(width: 14)
        var configuration = UIButton.Configuration.plain()
        configuration.image = normalImage
        sut.configuration = configuration
        sut.setImage(normalImage, for: .normal)
        sut.setImage(highlightedImage, for: .highlighted)
        sut.setImage(selectedImage, for: .selected)
        sut.setImage(disabledImage, for: .disabled)

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.configuration?.image?.size, normalImage.size)
        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysTemplate)

        sut.isHighlighted = true
        sut.updateConfiguration()
        XCTAssertEqual(sut.configuration?.image?.size, highlightedImage.size)

        sut.isHighlighted = false
        sut.isSelected = true
        sut.updateConfiguration()
        XCTAssertEqual(sut.configuration?.image?.size, selectedImage.size)

        sut.isSelected = false
        sut.isEnabled = false
        sut.updateConfiguration()
        XCTAssertEqual(sut.configuration?.image?.size, disabledImage.size)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === normalImage)
        XCTAssertTrue(sut.image(for: .highlighted) === highlightedImage)
        XCTAssertTrue(sut.image(for: .selected) === selectedImage)
        XCTAssertTrue(sut.image(for: .disabled) === disabledImage)
        XCTAssertTrue(sut.configuration?.image === normalImage)
    }

    @available(iOS 15.0, *)
    func test_buttonOutput_removingImageTint_restoresConfigurationImageAppearance() {
        let (sut, _) = makeSUT()
        let originalImage = UIImage(systemName: "star.fill")!.withRenderingMode(.alwaysOriginal)
        let originalTintColor = UIColor.systemGreen
        let originalSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let originalColorTransformer = UIConfigurationColorTransformer { _ in .systemBlue }
        var configuration = UIButton.Configuration.plain()
        configuration.image = originalImage
        configuration.imageColorTransformer = originalColorTransformer
        configuration.preferredSymbolConfigurationForImage = originalSymbolConfiguration
        sut.configuration = configuration
        sut.tintColor = originalTintColor

        sut.display(style: .init(imageTintColor: .systemRed))

        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysTemplate)
        XCTAssertEqual(sut.configuration?.imageColorTransformer?(.black), .systemRed)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.configuration?.image === originalImage)
        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysOriginal)
        XCTAssertEqual(sut.configuration?.imageColorTransformer?(.black), .systemBlue)
        XCTAssertEqual(
            sut.configuration?.preferredSymbolConfigurationForImage,
            originalSymbolConfiguration
        )
        XCTAssertEqual(sut.tintColor, originalTintColor)
    }

    func test_buttonOutput_replacingImageWhileTinted_restoresLatestOriginalImage() {
        let (sut, _) = makeSUT()
        let firstImage = UIImage(systemName: "star")!.withRenderingMode(.alwaysOriginal)
        let replacementImage = UIImage(systemName: "heart.fill")!.withRenderingMode(.alwaysOriginal)

        if #available(iOS 15.0, *) {
            sut.configuration = nil
        }
        sut.display(image: firstImage)
        sut.display(style: .init(imageTintColor: .systemRed))
        sut.display(image: replacementImage)

        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertTrue(sut.image(for: .normal) === replacementImage)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysOriginal)
    }

    func test_buttonOutput_leavingGlassStyle_restoresUnderlyingOriginalImage() throws {
        guard #available(iOS 26.0, *) else {
            throw XCTSkip("Liquid Glass is available on iOS 26 and newer")
        }
        let (sut, _) = makeSUT()
        let originalImage = UIImage(systemName: "star.fill")!.withRenderingMode(.alwaysOriginal)

        sut.configuration = nil
        sut.setImage(originalImage, for: .normal)
        sut.display(style: .init(
            imageTintColor: .systemRed,
            glassConfiguration: .glass
        ))

        XCTAssertNotNil(sut.configuration)
        XCTAssertEqual(sut.configuration?.image?.renderingMode, .alwaysTemplate)

        sut.display(style: .init(imageTintColor: nil))

        XCTAssertNil(sut.configuration)
        XCTAssertTrue(sut.image(for: .normal) === originalImage)
        XCTAssertEqual(sut.image(for: .normal)?.renderingMode, .alwaysOriginal)
    }
    
    func test_fail_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        let image =  UIImage(systemName: "star")
        sut.display(image: image)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // MARK: - Set image tests
    func test_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let image = UIImage(systemName: "star.fill")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.asset(image)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let light = ImageSnapshotFixture.light.url
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let dark = ImageSnapshotFixture.dark.url
        sut.display(style: .init(backgroundColor: .cyan))

        sut.setImage(.url(dark, dark)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let dark = ImageSnapshotFixture.dark.url
        sut.display(style: .init(backgroundColor: .cyan))

        sut.setImage(.url(dark, dark)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let light = ImageSnapshotFixture.light.url
        sut.display(style: .init(backgroundColor: .cyan))

        sut.setImage(.url(light, light)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let light = ImageSnapshotFixture.light.urlString
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let dark = ImageSnapshotFixture.dark.urlString
        sut.display(style: .init(backgroundColor: .cyan))

        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let dark = ImageSnapshotFixture.dark.urlString
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        sut.setImage(.urlString(dark, dark)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"

        // GIVEN
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for complition")

        // WHEN
        let light = ImageSnapshotFixture.light.urlString
        sut.display(style: .init(backgroundColor: .cyan))

        sut.setImage(.urlString(light, light)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            wrongUrlPlaceholderImage: UIImage(systemName: "xmark")!
        ))
        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            wrongUrlPlaceholderImage: UIImage(systemName: "xmark")!
        ))
        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .solid(.blue)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 50,
            style: .init(backgroundColor: .solid(.red))
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH SPACING",
            image: UIImage(systemName: "star"),
            spacing: 40,
            style: .init(backgroundColor: .solid(.red))
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_onPress() {
        let snapshotName = "BUTTON_WITH_TAP"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .cyan))
        let onPress: () -> Void = { [weak sut] in
            sut?.display(style: .init(backgroundColor: .red))
        }
        sut.display(onPress: onPress)
        onPress()

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_onPress() {
        let snapshotName = "BUTTON_WITH_TAP"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .cyan))
        let onPress: () -> Void = { [weak sut] in
            sut?.display(style: .init(backgroundColor: .systemRed))
        }
        sut.display(onPress: onPress)
        onPress()

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH height",
            image: UIImage(systemName: "star"),
            spacing: 50,
            height: 100,
            style: .init(backgroundColor: .solid(.red)),
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(model: .init(
            title: "BUTTON WITH height",
            image: UIImage(systemName: "star"),
            spacing: 50,
            height: 0,
            style: .init(backgroundColor: .solid(.red)),
        ))
        sut.display(style: .init(backgroundColor: .solid(.cyan)))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.display(isHidden: false)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .solid(.cyan)))
        sut.display(isHidden: true)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // MARK: - ButtonStyle tests
    func test_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.systemRed)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.red)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(backgroundColor: .solid(.cyan), titleColor: .red))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(backgroundColor: .cyan, titleColor: .blue))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.cyan),
            borderWidth: 4.0,
            borderColor: .red
        ))

        sut.display(title: "BUTTON WITH BORDER")

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.cyan),
            borderWidth: 5.0,
            borderColor: .red
        ))

        sut.display(title: "BUTTON WITH BORDER")

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.blue),
            pressedColor: .red,
        ))

        sut.touchesBegan([UITouch()], with: nil)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.blue),
            pressedColor: .systemRed,
        ))

        sut.touchesBegan([UITouch()], with: nil)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.white),
            titleColor: .blue,
            pressedTintColor: .red,
        ))
        sut.display(title: "PRESSED TINT COLOR")

        sut.touchesBegan([UITouch()], with: nil)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .solid(.white),
            titleColor: .blue,
            pressedTintColor: .systemRed,
        ))
        sut.display(title: "PRESSED TINT COLOR")

        sut.touchesBegan([UITouch()], with: nil)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.cyan), font: .systemFont(ofSize: 24, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .solid(.cyan), font: .systemFont(ofSize: 25, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"

        // GIVEN
        let (sut, container) = makeSUT(height: 100)

        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .solid(.cyan), cornerRadius: 40))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"

        // GIVEN
        let (sut, container) = makeSUT(height: 100)

        // WHEN
        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .solid(.cyan), cornerRadius: 41))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            wrongUrlPlaceholderImage: UIImage(systemName: "xmark")!
        ))
        sut.setImage(.url(nil, nil), completion: nil)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .cyan,
            wrongUrlPlaceholderImage: UIImage(systemName: "xmark.circle")!
        ))
        sut.setImage(.url(nil, nil), completion: nil)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        let style = ButtonStyle(
            backgroundColor: .solid(.systemBlue),
            loadingIndicatorColor: .red
        )

        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: true)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        let style = ButtonStyle(
            backgroundColor: .solid(.systemBlue),
            loadingIndicatorColor: .red
        )

        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: false)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_isLoading_state_false() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE_FALSE"

        // GIVEN
        let (sut, container) = makeSUT()

        // WHEN
        let style = ButtonStyle(
            backgroundColor: .solid(.systemBlue),
            loadingIndicatorColor: .red
        )

        sut.display(title: "Button title")
        sut.display(style: style)
        sut.display(isLoading: false)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_uikitButton_accessibilityActivation_invokesOutputCallback() {
        let button = WrapKit.Button()
        var pressCount = 0

        button.display(onPress: { pressCount += 1 })

        XCTAssertTrue(button.accessibilityActivate())
        XCTAssertEqual(pressCount, 1)
    }

    func test_uikitButton_disabledAccessibilityActivation_doesNotInvokeOutputCallback() {
        let button = WrapKit.Button()
        var pressCount = 0

        button.display(onPress: { pressCount += 1 })
        button.display(enabled: false)

        XCTAssertFalse(button.accessibilityActivate())
        XCTAssertEqual(pressCount, 0)
    }

    func test_uikitButton_displayHeight_addsConstraintToExistingStorage() {
        let button = WrapKit.Button()
        button.anchoredConstraints = button.anchor(.width(1))

        button.display(height: 44)

        XCTAssertEqual(button.anchoredConstraints?.height?.constant, 44)
        XCTAssertTrue(button.anchoredConstraints?.height?.isActive == true)
    }

    func test_uikitButton_displayModel_clearsStaleAccessibilityLabel() {
        let button = WrapKit.Button()
        button.display(model: .init(
            accessibility: .init(label: "Initial label", hint: "Initial hint"),
            title: "Title"
        ))

        XCTAssertEqual(button.accessibilityLabel, "Initial label")
        XCTAssertEqual(button.accessibilityHint, "Initial hint")

        button.display(model: .init(title: "Updated title"))

        XCTAssertEqual(button.accessibilityLabel, "Updated title")
        XCTAssertNotEqual(button.accessibilityLabel, "Initial label")
        XCTAssertNil(button.accessibilityHint)
    }

    func test_uikitButton_displayNilModel_hidesButtonAndClearsAccessibility() {
        let button = WrapKit.Button()
        button.display(model: .init(
            accessibility: .init(label: "Initial label", hint: "Initial hint"),
            title: "Title"
        ))

        button.display(model: nil)

        XCTAssertTrue(button.isHidden)
        XCTAssertNil(button.accessibilityLabel)
        XCTAssertNil(button.accessibilityHint)
    }

    func test_uikitButton_automaticCornerStyle_tracksBoundsHeight() {
        let button = WrapKit.Button()
        button.bounds = CGRect(x: 0, y: 0, width: 200, height: 60)
        button.display(style: .init(cornerStyle: .automatic))

        button.bounds.size.height = 100
        button.setNeedsLayout()
        button.layoutIfNeeded()

        XCTAssertEqual(button.layer.cornerRadius, 50, accuracy: 0.01)
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

    @available(iOS 17.0, *)
    func test_swiftUIButton_zeroHeight_remainsZero() {
        let view = SUIButtonView(
            model: .init(title: "Hidden-height title", height: 0, width: 120),
            isEnabled: true,
            fillsAvailableWidth: false
        )
        let hostingController = UIHostingController(rootView: view)

        let size = hostingController.sizeThatFits(
            in: CGSize(width: 1_000, height: 1_000)
        )

        XCTAssertEqual(size.width, 120, accuracy: 0.01)
        XCTAssertEqual(size.height, 0, accuracy: 0.01)
    }
}

extension ButtonSnapshotTests {
    func makeImage(width: CGFloat) -> UIImage {
        UIGraphicsImageRenderer(size: .init(width: width, height: 10)).image { context in
            UIColor.black.setFill()
            context.fill(.init(x: 0, y: 0, width: width, height: 10))
        }
        .withRenderingMode(.alwaysOriginal)
    }

    func makeSUT(
        height: CGFloat = 60,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: Button, container: UIView) {
        let sut = Button()
        let container = makeContainer()

        container.addSubview(sut)
        sut.anchoredConstraints = sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(height, priority: .required)
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

private extension ButtonSnapshotTests {
    @MainActor
    func makeGlassButtonHost(button: WrapKit.Button) -> UIViewController {
        let host = UIViewController()
        host.view.backgroundColor = .systemBackground
        host.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: host.view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: host.view.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: host.view.centerYAnchor)
        ])
        return host
    }

    @MainActor
    func assertSnapshots(
        _ host: UIViewController,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for appearance in [SnapshotAppearance.light, .dark, .light] {
            let configuration = SnapshotConfiguration(
                size: CGSize(width: 320, height: 120),
                safeAreaInsets: .zero,
                layoutMargins: .zero,
                traitCollection: UITraitCollection(traitsFrom: [
                    SnapshotConfiguration.iPhone(style: appearance.userInterfaceStyle).traitCollection,
                    UITraitCollection(activeAppearance: .active)
                ])
            )
            host.loadViewIfNeeded()
            host.overrideUserInterfaceStyle = appearance.userInterfaceStyle
            host.view.frame = CGRect(origin: .zero, size: configuration.size)
            RunLoop.main.run(until: Date().addingTimeInterval(0.3))
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            let image = host.snapshot(for: configuration)
            let os = isAvailableOS26 ? "iOS26" : "iOS18.5"
            let theme = appearance == .light ? "LIGHT" : "DARK"
            assert(
                snapshot: image,
                named: "\(os)_\(name)_\(theme)",
                precision: SwiftUISnapshotPrecision.standard,
                // Native glass varies by a few channel steps on antialiased edges.
                // Every pixel must still match within DeltaE 1, with no spatial tolerance
                // or permitted fraction of mismatching pixels.
                perceptualPrecision: isAvailableOS26 ? 0.99 : 1,
                file: file,
                line: line
            )
        }
    }
}
#endif
