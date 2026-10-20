#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
import WrapKit
import XCTest

extension ButtonSnapshotTests {
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
    
    private func makeImage(width: CGFloat) -> UIImage {
        UIGraphicsImageRenderer(size: .init(width: width, height: 10)).image { context in
            UIColor.black.setFill()
            context.fill(.init(x: 0, y: 0, width: width, height: 10))
        }
        .withRenderingMode(.alwaysOriginal)
    }
}
#endif
