import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class RendererParityRegressionTests: XCTestCase {
    @available(iOS 26.0, *)
    func test_swiftUIParity_matchesUICornerConfigurationAndSwiftUIContinuousShape() {
        let snapshotSize = SnapshotConfiguration.size
        let componentSize = CGSize(width: snapshotSize.width, height: 200)
        let cornerRadius: CGFloat = 16
        let borderWidth: CGFloat = 4
        let container = UIView(frame: CGRect(origin: .zero, size: snapshotSize))
        container.backgroundColor = .clear
        let component = UIView(frame: CGRect(origin: .zero, size: componentSize))
        component.backgroundColor = .systemRed
        component.layer.borderColor = UIColor.systemGreen.cgColor
        component.layer.borderWidth = borderWidth
        component.cornerConfiguration = .corners(radius: .fixed(cornerRadius))
        component.clipsToBounds = true
        container.addSubview(component)

        let defaultConfiguration = SnapshotConfiguration.iPhone(style: .light)
        let uiKitConfiguration = SnapshotConfiguration(
            size: snapshotSize,
            safeAreaInsets: .zero,
            layoutMargins: .zero,
            traitCollection: defaultConfiguration.traitCollection
        )
        let uiKit = container.snapshot(for: uiKitConfiguration)
        let swiftUIConfiguration = SUISnapshotConfiguration(
            size: snapshotSize,
            safeAreaInsets: EdgeInsets(),
            layoutMargins: EdgeInsets(),
            colorScheme: .light
        )
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let swiftUI = shape
            .fill(SwiftUI.Color(uiColor: .systemRed))
            .overlay(
                shape.strokeBorder(
                    SwiftUI.Color(uiColor: .systemGreen),
                    lineWidth: borderWidth
                )
            )
            .frame(width: componentSize.width, height: componentSize.height)
            .frame(
                width: snapshotSize.width,
                height: snapshotSize.height,
                alignment: .topLeading
            )
            .snapshot(
                for: swiftUIConfiguration,
                background: .clear,
                useUIKit: true
            )

        assertRendererParity(uiKit, swiftUI)
    }

    func test_swiftUIParity_rejectsOnePhysicalPixelShiftOfCurvedContentAt3x() {
        assertRendererMutation(
            makeEllipseImage(originX: 4),
            makeEllipseImage(originX: 4 + 1 / 3)
        )
    }

    func test_swiftUIParity_rejectsOnePointResizeOfCurvedContentAt3x() {
        assertRendererMutation(
            makeEllipseImage(width: 20),
            makeEllipseImage(width: 21)
        )
    }
}

@available(iOS 17.0, *)
private extension RendererParityRegressionTests {
    func assertRendererParity(
        _ lhs: UIImage,
        _ rhs: UIImage,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let forwardDifference = Diffing<UIImage>.swiftUIParity.diff(lhs, rhs)
        let reverseDifference = Diffing<UIImage>.swiftUIParity.diff(rhs, lhs)
        attachImagesIfNeeded(
            lhs,
            rhs,
            forwardDifference: forwardDifference,
            reverseDifference: reverseDifference
        )
        // Renderer implementations can become byte-identical on a newer OS.
        // Exact equality is still valid parity; the mutation tests below keep
        // proving that the comparator rejects physical geometry changes.
        XCTAssertNil(forwardDifference, file: file, line: line)
        XCTAssertNil(
            reverseDifference,
            "Renderer parity must be symmetric.",
            file: file,
            line: line
        )
    }

    func assertRendererMutation(
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
            "Renderer parity must reject the mutation in both directions.",
            file: file,
            line: line
        )
    }

    func attachImagesIfNeeded(
        _ lhs: UIImage,
        _ rhs: UIImage,
        forwardDifference: Any?,
        reverseDifference: Any?
    ) {
        guard forwardDifference != nil || reverseDifference != nil else { return }
        let reference = XCTAttachment(image: lhs)
        reference.name = "Renderer parity reference"
        reference.lifetime = .keepAlways
        add(reference)
        let actual = XCTAttachment(image: rhs)
        actual.name = "Renderer parity actual"
        actual.lifetime = .keepAlways
        add(actual)
    }

    func makeEllipseImage(
        originX: CGFloat = 4,
        width: CGFloat = 20
    ) -> UIImage {
        let size = CGSize(width: 32, height: 24)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = false
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.clear(CGRect(origin: .zero, size: size))
            UIColor.systemBlue.setFill()
            context.cgContext.fillEllipse(
                in: CGRect(x: originX, y: 4, width: width, height: 16)
            )
        }
    }

}
