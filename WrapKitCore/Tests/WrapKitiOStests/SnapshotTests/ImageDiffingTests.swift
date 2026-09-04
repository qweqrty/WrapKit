import SwiftUI
import UIKit
import WrapKitTestUtils
import XCTest

final class LegacyImageDiffingTests: XCTestCase {
    func test_imageDiffing_allowsSparseOpaqueTwoStepQuantizationDifference() {
        let reference = makeImage()
        let actual = makeImage(changedPixelIndices: [0], changedRed: 102)

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsSingleOpaquePixelOverColorTolerance() {
        let reference = makeImage()
        let actual = makeImage(changedPixelIndices: [0], changedRed: 103)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_allowsSparseTranslucentTwoStepQuantizationDifference() {
        let reference = makeImage(alpha: 200)
        let actual = makeImage(alpha: 200, changedPixelIndices: [0], changedRed: 102)

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsSinglePixelOverAlphaTolerance() {
        let reference = makeImage(alpha: 200)
        let actual = makeImage(alpha: 200, changedPixelIndices: [0], changedAlpha: 198)

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_allowsQuantizationDifferenceAtPixelBudget() {
        let reference = makeImage()
        let actual = makeImage(
            changedPixelIndices: Array(0..<25),
            changedRed: 102
        )

        XCTAssertNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsQuantizationDifferenceOverPixelBudget() {
        let reference = makeImage()
        let actual = makeImage(
            changedPixelIndices: Array(0..<26),
            changedRed: 102
        )

        XCTAssertNotNil(Diffing<UIImage>.image.diff(reference, actual))
    }

    func test_imageDiffing_rejectsUniformTwoStepColorDifference() {
        XCTAssertNotNil(
            Diffing<UIImage>.image.diff(
                makeImage(red: 100),
                makeImage(red: 102)
            )
        )
    }

    func test_imageDiffing_rejectsUniformOneStepAlphaDifference() {
        XCTAssertNotNil(
            Diffing<UIImage>.image.diff(
                makeImage(alpha: 255),
                makeImage(alpha: 254)
            )
        )
    }

    func test_imageDiffing_preservesExplicitPrecisionBehavior() {
        let reference = makeImage(red: 100)
        let actual = makeImage(red: 103)

        XCTAssertNil(Diffing<UIImage>.image(precision: 0.7).diff(reference, actual))
        XCTAssertNotNil(Diffing<UIImage>.image(precision: 0.8).diff(reference, actual))
    }
}

final class ImageDiffingTests: XCTestCase {
    func test_strictImageDiffing_allowsFinalOneStepQuantizationDifference() {
        let reference = makeImage()
        let actual = makeImage(changedPixelIndices: [0], changedRed: 101)

        XCTAssertNil(Diffing<UIImage>.strictImage.diff(reference, actual))
    }

    func test_strictImageDiffing_rejectsUniformTwoStepColorDifference() {
        XCTAssertNotNil(
            Diffing<UIImage>.strictImage.diff(
                makeImage(red: 100),
                makeImage(red: 102)
            )
        )
    }

    func test_strictImageDiffing_rejectsOnePhysicalPixelPositionDifference() {
        let reference = makeRenderedRectangleImage(originX: 4)
        let shifted = makeRenderedRectangleImage(originX: 4 + 1.0 / 3.0)

        XCTAssertNotNil(Diffing<UIImage>.strictImage.diff(reference, shifted))
    }

    func test_strictImageDiffing_normalizesEquivalentExtendedP3AndStandardSRGB() throws {
        let extended = makeRendererRangeRoundedImage(
            preferredRange: .extended,
            color: .systemBlue
        )
        let standard = makeRendererRangeRoundedImage(
            preferredRange: .standard,
            color: .systemBlue
        )
        let persistedExtended = try XCTUnwrap(
            UIImage(data: try XCTUnwrap(extended.pngData()), scale: extended.scale)
        )

        try requireExtendedRangeSupport(persistedExtended)
        XCTAssertEqual(persistedExtended.cgImage?.colorSpace?.name, CGColorSpace.displayP3)
        XCTAssertEqual(standard.cgImage?.colorSpace?.name, CGColorSpace.sRGB)
        XCTAssertNil(Diffing<UIImage>.strictImage.diff(extended, standard))
    }

    func test_strictAndParity_rejectExtendedP3ColorMutation() throws {
        let reference = makeRendererRangeRoundedImage(
            preferredRange: .extended,
            color: .systemBlue
        )
        let wrongColor = makeRendererRangeRoundedImage(
            preferredRange: .standard,
            color: .systemIndigo
        )
        let persistedReference = try XCTUnwrap(
            UIImage(data: try XCTUnwrap(reference.pngData()), scale: reference.scale)
        )

        try requireExtendedRangeSupport(persistedReference)
        XCTAssertNotNil(Diffing<UIImage>.strictImage.diff(reference, wrongColor))
        assertParityRejects(reference, wrongColor)
    }

    func test_swiftUIParity_rejectsOnePhysicalPixelOpaqueEdgeShift() {
        assertParityRejects(
            makeVerticalEdgeImage(edgeX: 16),
            makeVerticalEdgeImage(edgeX: 17)
        )
    }

    func test_swiftUIParity_rejectsOnePhysicalPixelTransparentEdgeShift() {
        assertParityRejects(
            makeVerticalEdgeImage(edgeX: 16, transparentLeading: true),
            makeVerticalEdgeImage(edgeX: 17, transparentLeading: true)
        )
    }

    func test_swiftUIParity_allowsLocalEdgeCoverageRedistribution() {
        assertParityAllows(
            makeVerticalEdgeImage(edgeX: 16, intermediate: (140, 130, 50, 255)),
            makeVerticalEdgeImage(edgeX: 16, intermediate: (148, 122, 52, 255))
        )
    }

    func test_swiftUIParity_allowsNestedTransparentEdgeCoverageRedistribution() {
        assertParityAllows(
            makeNestedTransparentEdgeImage(usesUIKitCoverage: true),
            makeNestedTransparentEdgeImage(usesUIKitCoverage: false)
        )
    }

    @available(iOS 17.0, *)
    func test_swiftUIParity_matchesRealUIKitAndSwiftUIEllipse() {
        let size = CGSize(width: 32, height: 32)
        let configuration = makeSwiftUISnapshotConfiguration(size: size)
        let swiftUI = Circle()
            .fill(Color(uiColor: .systemBlue))
            .padding(4)
            .snapshot(for: configuration, background: .clear)
        let uiKit = makeUIKitEllipseImage(size: size)

        assertStrictAndParityMatch(uiKit, swiftUI)
    }

    func test_swiftUIParity_rejectsUniformFourStepColorChange() {
        assertParityRejects(
            makeImage(width: 32, height: 32, red: 100),
            makeImage(width: 32, height: 32, red: 104)
        )
    }

    func test_swiftUIParity_rejectsUniformEightStepBlueChange() {
        assertParityRejects(
            makeImage(width: 32, height: 32, blue: 25),
            makeImage(width: 32, height: 32, blue: 33)
        )
    }

    func test_swiftUIParity_rejectsUniformFourStepAlphaChange() {
        assertParityRejects(
            makeImage(width: 32, height: 32, red: 0, green: 0, blue: 0, alpha: 255),
            makeImage(width: 32, height: 32, red: 0, green: 0, blue: 0, alpha: 251)
        )
    }

    func test_swiftUIParity_rejectsOffSegmentEdgeColor() {
        assertParityRejects(
            makeVerticalEdgeImage(edgeX: 16, intermediate: (140, 130, 50, 255)),
            makeVerticalEdgeImage(edgeX: 16, intermediate: (140, 130, 90, 255))
        )
    }

    func test_swiftUIParity_rejectsOppositeOffSegmentResiduals() {
        assertParityRejects(
            makeVerticalEdgeImage(edgeX: 16, intermediate: (140, 130, 47, 255)),
            makeVerticalEdgeImage(edgeX: 16, intermediate: (140, 130, 53, 255))
        )
    }

    func test_swiftUIParity_rejectsGrossEdgeCoverageChange() {
        assertParityRejects(
            makeTwoPixelCoverageEdgeImage(
                firstIntermediate: (220, 58, 42, 255),
                secondIntermediate: (200, 76, 44, 255)
            ),
            makeTwoPixelCoverageEdgeImage(
                firstIntermediate: (80, 184, 56, 255),
                secondIntermediate: (60, 202, 58, 255)
            )
        )
    }

    func test_swiftUIParity_rejectsReorderedIntermediateCoverage() {
        assertParityRejects(
            makeTwoPixelCoverageEdgeImage(
                firstIntermediate: (190, 85, 45, 255),
                secondIntermediate: (90, 175, 55, 255)
            ),
            makeTwoPixelCoverageEdgeImage(
                firstIntermediate: (90, 175, 55, 255),
                secondIntermediate: (190, 85, 45, 255)
            )
        )
    }

    func test_swiftUIParity_rejectsCoverageDifferenceOverFivePercent() {
        assertParityRejects(
            makeVerticalEdgeImage(edgeX: 16, intermediate: (140, 130, 50, 255)),
            makeVerticalEdgeImage(edgeX: 16, intermediate: (128, 141, 51, 255))
        )
    }

    func test_swiftUIParity_rejectsCropBoundaryCoverageMutation() {
        assertParityRejects(
            makeCropBoundaryCoverageImage(coverage: (4, 22, 6, 26)),
            makeCropBoundaryCoverageImage(coverage: (3, 15, 4, 18))
        )
    }

    func test_swiftUIParity_rejectsSinglePixelNotchInsideExistingEdge() {
        assertParityRejects(
            makeNotchedVerticalEdgeImage(intrusionRows: []),
            makeNotchedVerticalEdgeImage(intrusionRows: [8])
        )
    }

    func test_swiftUIParity_rejectsSameCoverageAtDifferentEdgePositions() {
        assertParityRejects(
            makeNotchedVerticalEdgeImage(intrusionRows: [5]),
            makeNotchedVerticalEdgeImage(intrusionRows: [10])
        )
    }

    func test_swiftUIParity_rejectsOnePixelLinePositionDifference() {
        assertParityRejects(
            makeOnePixelLineImage(x: 15),
            makeOnePixelLineImage(x: 16)
        )
    }

    func test_swiftUIParity_rejectsMissingSinglePixelContent() {
        assertParityRejects(
            makeSparseContentImage(indices: [16 * 32 + 16]),
            makeSparseContentImage(indices: [])
        )
    }

    func test_swiftUIParity_rejectsMissingConnectedEightPixelContent() {
        let indices = [
            15 * 32 + 15, 15 * 32 + 16, 15 * 32 + 17, 15 * 32 + 18,
            16 * 32 + 15, 16 * 32 + 16, 16 * 32 + 17, 16 * 32 + 18
        ]
        assertParityRejects(
            makeSparseContentImage(indices: indices),
            makeSparseContentImage(indices: [])
        )
    }

    func test_swiftUIParity_rejectsMissingScatteredEightPixelContent() {
        let indices = [99, 227, 355, 483, 611, 739, 867, 995]
        assertParityRejects(
            makeSparseContentImage(indices: indices),
            makeSparseContentImage(indices: [])
        )
    }

    func test_swiftUIParity_rejectsOnePointComponentPositionDifferenceAt3x() {
        assertParityRejects(
            makeRenderedRectangleImage(originX: 4),
            makeRenderedRectangleImage(originX: 5)
        )
    }

    func test_swiftUIParity_rejectsOnePointVerticalPositionDifferenceAt3x() {
        assertParityRejects(
            makeRenderedRectangleImage(originY: 4),
            makeRenderedRectangleImage(originY: 5)
        )
    }

    func test_swiftUIParity_rejectsOnePointTinyComponentPositionDifferenceAt3x() {
        assertParityRejects(
            makeRenderedRectangleImage(originX: 4, originY: 4, width: 2, height: 2),
            makeRenderedRectangleImage(originX: 5, originY: 4, width: 2, height: 2)
        )
    }

    func test_swiftUIParity_rejectsOnePointComponentResizeAt3x() {
        assertParityRejects(
            makeRenderedRectangleImage(width: 20),
            makeRenderedRectangleImage(width: 21)
        )
    }

    func test_swiftUIParity_rejectsOnePointComponentHeightDifferenceAt3x() {
        assertParityRejects(
            makeRenderedRectangleImage(height: 16),
            makeRenderedRectangleImage(height: 17)
        )
    }

    func test_swiftUIParity_rejectsGradientBandMutation() {
        assertParityRejects(
            makeGradientImage(),
            makeGradientImage(mutatingBand: true)
        )
    }

    func test_swiftUIParity_rejectsDifferentText() {
        assertParityRejects(
            makeTextImage(text: "Default", color: .white),
            makeTextImage(text: "Continue", color: .white)
        )
    }

    func test_swiftUIParity_rejectsWrongTextColor() {
        assertParityRejects(
            makeTextImage(text: "Default", color: .white),
            makeTextImage(text: "Default", color: .lightGray)
        )
    }

    func test_swiftUIParity_rejectsSamePixelsWithDifferentScale() throws {
        let image = makeImage(width: 32, height: 32)
        let cgImage = try XCTUnwrap(image.cgImage)
        let at2x = UIImage(cgImage: cgImage, scale: 2, orientation: .up)
        let at3x = UIImage(cgImage: cgImage, scale: 3, orientation: .up)

        assertParityRejects(at2x, at3x)
    }

    func test_swiftUIParity_rejectsDifferentPixelDimensions() {
        let reference = makeImage(width: 32, height: 32)
        let wrongSize = makeImage(width: 33, height: 32)

        assertParityRejects(reference, wrongSize)
        let difference = Diffing<UIImage>.swiftUIParity.diff(reference, wrongSize)

        XCTAssertNotNil(difference)
        XCTAssertEqual(difference?.artifacts.diff.cgImage?.width, 33)
        XCTAssertEqual(difference?.artifacts.diff.cgImage?.height, 32)
    }
}

@available(iOS 17.0, *)
final class SwiftUISnapshotSizingTests: XCTestCase {
    func test_swiftUISnapshot_usesRequestedImageRendererSize() {
        let configuration = makeSwiftUISnapshotConfiguration(size: CGSize(width: 123, height: 77))

        let snapshot = SwiftUI.Color.red.snapshot(for: configuration)

        XCTAssertEqual(snapshot.size.width, 123, accuracy: 0.001)
        XCTAssertEqual(snapshot.size.height, 77, accuracy: 0.001)
        XCTAssertEqual(snapshot.cgImage?.width, Int(123 * UIScreen.main.scale))
        XCTAssertEqual(snapshot.cgImage?.height, Int(77 * UIScreen.main.scale))
    }

    func test_swiftUISnapshot_usesRequestedUIKitHostSize() {
        let configuration = makeSwiftUISnapshotConfiguration(size: CGSize(width: 123, height: 77))

        let snapshot = SwiftUI.Color.red.snapshot(for: configuration, useUIKit: true)

        XCTAssertEqual(snapshot.size.width, 123, accuracy: 0.001)
        XCTAssertEqual(snapshot.size.height, 77, accuracy: 0.001)
        XCTAssertEqual(snapshot.cgImage?.width, Int(123 * UIScreen.main.scale))
        XCTAssertEqual(snapshot.cgImage?.height, Int(77 * UIScreen.main.scale))
    }
}

private extension XCTestCase {
    func assertStrictAndParityMatch(
        _ lhs: UIImage,
        _ rhs: UIImage,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let strictDifference = Diffing<UIImage>.strictImage.diff(lhs, rhs)
        let forwardDifference = Diffing<UIImage>.swiftUIParity.diff(lhs, rhs)
        let reverseDifference = Diffing<UIImage>.swiftUIParity.diff(rhs, lhs)

        attachParityImagesIfNeeded(
            lhs,
            rhs,
            forwardDifference: forwardDifference,
            reverseDifference: reverseDifference
        )
        XCTAssertNil(strictDifference, file: file, line: line)
        XCTAssertNil(forwardDifference, file: file, line: line)
        XCTAssertNil(
            reverseDifference,
            "Parity must be symmetric.",
            file: file,
            line: line
        )
    }

    func assertParityAllows(
        _ lhs: UIImage,
        _ rhs: UIImage,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let strictDifference = Diffing<UIImage>.strictImage.diff(lhs, rhs)
        let forwardDifference = Diffing<UIImage>.swiftUIParity.diff(lhs, rhs)
        let reverseDifference = Diffing<UIImage>.swiftUIParity.diff(rhs, lhs)

        attachParityImagesIfNeeded(
            lhs,
            rhs,
            forwardDifference: forwardDifference,
            reverseDifference: reverseDifference
        )

        XCTAssertNotNil(
            strictDifference,
            "The positive parity fixture must exercise the AA allowance.",
            file: file,
            line: line
        )
        XCTAssertNil(
            forwardDifference,
            file: file,
            line: line
        )
        XCTAssertNil(
            reverseDifference,
            "Parity must be symmetric.",
            file: file,
            line: line
        )
    }

    func attachParityImagesIfNeeded(
        _ lhs: UIImage,
        _ rhs: UIImage,
        forwardDifference: Any?,
        reverseDifference: Any?
    ) {
        guard forwardDifference != nil || reverseDifference != nil else { return }

        let reference = XCTAttachment(image: lhs)
        reference.name = "Parity reference"
        reference.lifetime = .keepAlways
        add(reference)

        let actual = XCTAttachment(image: rhs)
        actual.name = "Parity actual"
        actual.lifetime = .keepAlways
        add(actual)
    }

    func assertParityRejects(
        _ lhs: UIImage,
        _ rhs: UIImage,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNotNil(
            Diffing<UIImage>.swiftUIParity.diff(lhs, rhs),
            file: file,
            line: line
        )
        XCTAssertNotNil(
            Diffing<UIImage>.swiftUIParity.diff(rhs, lhs),
            "Parity must reject the mutation in both directions.",
            file: file,
            line: line
        )
    }

    func requireExtendedRangeSupport(_ image: UIImage) throws {
        guard (image.cgImage?.bitsPerComponent ?? 0) > 8 else {
            throw XCTSkip("The selected simulator does not expose an extended-range renderer.")
        }
    }

    func makeImage(
        width: Int = 500,
        height: Int = 500,
        red: UInt8 = 100,
        green: UInt8 = 50,
        blue: UInt8 = 25,
        alpha: UInt8 = 255,
        changedPixelIndices: [Int] = [],
        changedRed: UInt8? = nil,
        changedAlpha: UInt8? = nil
    ) -> UIImage {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for pixelIndex in 0..<(width * height) {
            let byteIndex = pixelIndex * 4
            pixels[byteIndex] = red
            pixels[byteIndex + 1] = green
            pixels[byteIndex + 2] = blue
            pixels[byteIndex + 3] = alpha
        }
        for pixelIndex in changedPixelIndices {
            let byteIndex = pixelIndex * 4
            if let changedRed {
                pixels[byteIndex] = changedRed
            }
            if let changedAlpha {
                pixels[byteIndex + 3] = changedAlpha
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeSparseContentImage(indices: [Int]) -> UIImage {
        let width = 32
        let height = 32
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for pixelIndex in indices {
            let byteIndex = pixelIndex * 4
            pixels[byteIndex] = 80
            pixels[byteIndex + 1] = 160
            pixels[byteIndex + 2] = 240
            pixels[byteIndex + 3] = 255
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeVerticalEdgeImage(
        edgeX: Int,
        transparentLeading: Bool = false,
        intermediate: (UInt8, UInt8, UInt8, UInt8)? = nil
    ) -> UIImage {
        let width = 32
        let height = 16
        let leading: (UInt8, UInt8, UInt8, UInt8) = transparentLeading
            ? (0, 0, 0, 0)
            : (240, 40, 40, 255)
        let trailing: (UInt8, UInt8, UInt8, UInt8) = (40, 220, 60, 255)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let color: (UInt8, UInt8, UInt8, UInt8)
                if let intermediate, x == edgeX {
                    color = intermediate
                } else {
                    color = x < edgeX ? leading : trailing
                }
                let byteIndex = (y * width + x) * 4
                pixels[byteIndex] = color.0
                pixels[byteIndex + 1] = color.1
                pixels[byteIndex + 2] = color.2
                pixels[byteIndex + 3] = color.3
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeNestedTransparentEdgeImage(usesUIKitCoverage: Bool) -> UIImage {
        let width = 32
        let height = 16
        let transparent: (UInt8, UInt8, UInt8, UInt8) = (0, 0, 0, 0)
        let border: (UInt8, UInt8, UInt8, UInt8) = (40, 220, 60, 255)
        let fill: (UInt8, UInt8, UInt8, UInt8) = (240, 40, 40, 255)
        let outerCoverage: (UInt8, UInt8, UInt8, UInt8) = usesUIKitCoverage
            ? (10, 9, 3, 17)
            : (1, 8, 2, 9)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let color: (UInt8, UInt8, UInt8, UInt8)
                switch x {
                case ..<8:
                    color = transparent
                case 8:
                    color = outerCoverage
                case 9..<12:
                    color = border
                default:
                    color = fill
                }
                let byteIndex = (y * width + x) * 4
                pixels[byteIndex] = color.0
                pixels[byteIndex + 1] = color.1
                pixels[byteIndex + 2] = color.2
                pixels[byteIndex + 3] = color.3
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeTwoPixelCoverageEdgeImage(
        firstIntermediate: (UInt8, UInt8, UInt8, UInt8),
        secondIntermediate: (UInt8, UInt8, UInt8, UInt8)
    ) -> UIImage {
        let width = 32
        let height = 16
        let leading: (UInt8, UInt8, UInt8, UInt8) = (240, 40, 40, 255)
        let trailing: (UInt8, UInt8, UInt8, UInt8) = (40, 220, 60, 255)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let color: (UInt8, UInt8, UInt8, UInt8)
                switch x {
                case ..<16:
                    color = leading
                case 16:
                    color = firstIntermediate
                case 17:
                    color = secondIntermediate
                default:
                    color = trailing
                }
                let byteIndex = (y * width + x) * 4
                pixels[byteIndex] = color.0
                pixels[byteIndex + 1] = color.1
                pixels[byteIndex + 2] = color.2
                pixels[byteIndex + 3] = color.3
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeNotchedVerticalEdgeImage(intrusionRows: Set<Int>) -> UIImage {
        let width = 32
        let height = 16
        let leading: (UInt8, UInt8, UInt8, UInt8) = (240, 40, 40, 255)
        let trailing: (UInt8, UInt8, UInt8, UInt8) = (40, 220, 60, 255)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let isIntrusion = x == 15 && intrusionRows.contains(y)
                let color = x < 16 && !isIntrusion ? leading : trailing
                let byteIndex = (y * width + x) * 4
                pixels[byteIndex] = color.0
                pixels[byteIndex + 1] = color.1
                pixels[byteIndex + 2] = color.2
                pixels[byteIndex + 3] = color.3
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeOnePixelLineImage(x lineX: Int) -> UIImage {
        let width = 32
        let height = 16
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {
            let byteIndex = (y * width + lineX) * 4
            pixels[byteIndex] = 40
            pixels[byteIndex + 1] = 120
            pixels[byteIndex + 2] = 240
            pixels[byteIndex + 3] = 255
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeCropBoundaryCoverageImage(
        coverage: (UInt8, UInt8, UInt8, UInt8)
    ) -> UIImage {
        let width = 32
        let height = 16
        let solid: (UInt8, UInt8, UInt8, UInt8) = (40, 220, 60, 255)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let color = x == 0 ? coverage : solid
                let byteIndex = (y * width + x) * 4
                pixels[byteIndex] = color.0
                pixels[byteIndex + 1] = color.1
                pixels[byteIndex + 2] = color.2
                pixels[byteIndex + 3] = color.3
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeRGBAImage(
        pixels: inout [UInt8],
        width: Int,
        height: Int,
        scale: CGFloat = 1
    ) -> UIImage {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                  data: &pixels,
                  width: width,
                  height: height,
                  bitsPerComponent: 8,
                  bytesPerRow: width * 4,
                  space: colorSpace,
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ),
              let image = context.makeImage() else {
            XCTFail("Could not create the RGBA fixture.")
            return UIImage()
        }
        return UIImage(cgImage: image, scale: scale, orientation: .up)
    }

    func makeRenderedRectangleImage(
        originX: CGFloat = 4,
        originY: CGFloat = 4,
        width: CGFloat = 20,
        height: CGFloat = 16
    ) -> UIImage {
        let size = CGSize(width: 40, height: 24)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = false
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: size))
            UIColor.systemBlue.setFill()
            context.cgContext.fill(CGRect(x: originX, y: originY, width: width, height: height))
        }
    }

    func makeGradientImage(mutatingBand: Bool = false) -> UIImage {
        let width = 32
        let height = 32
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let byteIndex = (y * width + x) * 4
                pixels[byteIndex] = UInt8(x * 7)
                pixels[byteIndex + 1] = UInt8(y * 7)
                pixels[byteIndex + 2] = UInt8((x + y) * 3)
                pixels[byteIndex + 3] = 255
                if mutatingBand, (12...19).contains(x) {
                    pixels[byteIndex + 2] += 16
                }
            }
        }
        return makeRGBAImage(pixels: &pixels, width: width, height: height)
    }

    func makeTextImage(text: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 160, height: 48)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = false
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: size))
            NSAttributedString(
                string: text,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                    .foregroundColor: color
                ]
            ).draw(at: CGPoint(x: 4, y: 12))
        }
    }

    func makeUIKitEllipseImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: size))
            UIColor.systemBlue
                .resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                .setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size).insetBy(dx: 4, dy: 4))
        }
    }

    func makeRendererRangeRoundedImage(
        preferredRange: UIGraphicsImageRendererFormat.Range,
        color: UIColor
    ) -> UIImage {
        let size = CGSize(width: 96, height: 48)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = false
        format.preferredRange = preferredRange
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: size))
            color.setFill()
            UIBezierPath(
                roundedRect: CGRect(x: 4, y: 4, width: 88, height: 40),
                cornerRadius: 12
            ).fill()
        }
    }

    func makeSwiftUISnapshotConfiguration(size: CGSize) -> SUISnapshotConfiguration {
        SUISnapshotConfiguration(
            size: size,
            safeAreaInsets: EdgeInsets(),
            layoutMargins: EdgeInsets(),
            colorScheme: .light
        )
    }
}
