import UIKit
import WrapKitTestUtils
import XCTest

final class ImageDiffingTests: XCTestCase {
    func test_imageDiffing_allowsSparseOpaqueTwoStepQuantizationDifference() {
        let reference = makeImage()
        let actual = makeImage(changedPixelCount: 1, changedRed: 102)

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsSingleOpaquePixelOverColorTolerance() {
        let reference = makeImage()
        let actual = makeImage(changedPixelCount: 1, changedRed: 103)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_allowsSparseTranslucentTwoStepQuantizationDifference() {
        let reference = makeImage(alpha: 200)
        let actual = makeImage(alpha: 200, changedPixelCount: 1, changedRed: 102)

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsSingleTranslucentPixelOverColorTolerance() {
        let reference = makeImage(alpha: 200)
        let actual = makeImage(alpha: 200, changedPixelCount: 1, changedRed: 103)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_allowsSparseOneStepAlphaQuantizationDifference() {
        let reference = makeImage(alpha: 200)
        let actual = makeImage(alpha: 200, changedPixelCount: 1, changedAlpha: 199)

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsSinglePixelOverAlphaTolerance() {
        let reference = makeImage(alpha: 200)
        let actual = makeImage(alpha: 200, changedPixelCount: 1, changedAlpha: 198)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsQuantizationDifferenceOverPixelBudget() {
        let reference = makeImage()
        let actual = makeImage(changedPixelCount: 26, changedRed: 102)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_allowsQuantizationDifferenceAtPixelBudget() {
        let reference = makeImage()
        let actual = makeImage(changedPixelCount: 25, changedRed: 102)

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsUniformTwoStepColorDifference() {
        let reference = makeImage(red: 100)
        let actual = makeImage(red: 102)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsUniformOneStepAlphaDifference() {
        let reference = makeImage(alpha: 255)
        let actual = makeImage(alpha: 254)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_fullPrecisionRejectsLocalizedVisibleChange() {
        let reference = makeImage()
        let actual = makeImage(changedPixelCount: 5_000, changedRed: 200)

        XCTAssertNotNil(Diffing<UIImage>.image(precision: 1).diff(reference, actual))
    }

    func test_imageDiffing_preservesExplicitPrecisionBehavior() {
        let reference = makeImage(red: 100)
        let actual = makeImage(red: 103)

        XCTAssertNil(Diffing<UIImage>.image(precision: 0.7).diff(reference, actual))
        XCTAssertNotNil(Diffing<UIImage>.image(precision: 0.8).diff(reference, actual))
    }

    func test_imageDiffing_treatsQuantizationToleranceAsEquivalentWithExplicitPrecision() {
        let reference = makeImage()
        let actual = makeImage(changedPixelCount: 25, changedRed: 102)

        XCTAssertNil(Diffing<UIImage>.image(precision: 0.99999).diff(reference, actual))
    }
}

private extension ImageDiffingTests {
    func makeImage(
        red: UInt8 = 100,
        alpha: UInt8 = 255,
        changedPixelCount: Int = 0,
        changedRed: UInt8? = nil,
        changedAlpha: UInt8? = nil
    ) -> UIImage {
        let width = 500
        let height = 500
        let bytesPerPixel = 4
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        for pixelIndex in 0..<(width * height) {
            let byteIndex = pixelIndex * bytesPerPixel
            pixels[byteIndex] = red
            pixels[byteIndex + 1] = 50
            pixels[byteIndex + 2] = 25
            pixels[byteIndex + 3] = alpha
        }
        for pixelIndex in 0..<changedPixelCount {
            let byteIndex = pixelIndex * bytesPerPixel
            if let changedRed {
                pixels[byteIndex] = changedRed
            }
            if let changedAlpha {
                pixels[byteIndex + 3] = changedAlpha
            }
        }
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            XCTFail("The sRGB color space is unavailable.")
            return UIImage()
        }
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * bytesPerPixel,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            XCTFail("Could not create the image context.")
            return UIImage()
        }
        guard let image = context.makeImage() else {
            XCTFail("Could not create an image from the context.")
            return UIImage()
        }
        return UIImage(cgImage: image)
    }
}
