#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
final class SUINavigationBarParityTests: XCTestCase {
    private let containerWidth: CGFloat = 390

    @available(iOS 17.0, *)
    func test_titledImage_usesVerticalFourPointLayoutAndModelImageSize() throws {
        let imageModel = ImageViewPresentableModel.systemSymbol(
            "star.fill",
            accessibilityIdentifier: "header.center.image",
            accessibility: .init(label: "Featured image"),
            size: .init(width: 24, height: 24),
            onPress: {}
        )
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: makeStyle(),
            centerView: .titledImage(.init(
                imageModel,
                .text(
                    accessibilityIdentifier: "header.center.title",
                    accessibility: .init(label: "Featured title"),
                    "Featured"
                )
            ))
        ))
        let host = makeHost(adapter: adapter)

        let imageFrame = try frame(ofLabel: "Featured image", in: host)
        let titleFrame = try frame(ofLabel: "Featured title", in: host)

        XCTAssertEqual(SUINavigationBarCenterLayoutMetrics.spacing, 4)
        XCTAssertEqual(
            SUINavigationBarCenterLayoutMetrics.resolvedImageSize(for: imageModel),
            CGSize(width: 24, height: 24)
        )
        XCTAssertGreaterThan(imageFrame.width, 0)
        XCTAssertGreaterThan(imageFrame.height, 0)
        XCTAssertLessThanOrEqual(imageFrame.width, 24)
        XCTAssertLessThanOrEqual(imageFrame.height, 24)
        XCTAssertEqual(imageFrame.midX, titleFrame.midX, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(titleFrame.minY - imageFrame.maxY, 4)
        XCTAssertLessThan(imageFrame.minY, titleFrame.minY)
    }

    @available(iOS 17.0, *)
    func test_keyValue_usesUIKitFourPointVerticalSpacing() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: makeStyle(),
            centerView: .keyValue(.init(
                .text(
                    accessibilityIdentifier: "header.center.key",
                    accessibility: .init(label: "Header key"),
                    "Overview"
                ),
                .text(
                    accessibilityIdentifier: "header.center.value",
                    accessibility: .init(label: "Header value"),
                    "Online"
                )
            ))
        ))
        let host = makeHost(adapter: adapter)

        let keyFrame = try frame(ofLabel: "Header key", in: host)
        let valueFrame = try frame(ofLabel: "Header value", in: host)

        XCTAssertEqual(SUINavigationBarCenterLayoutMetrics.spacing, 4)
        XCTAssertGreaterThanOrEqual(valueFrame.minY - keyFrame.maxY, 4)
        XCTAssertEqual(keyFrame.midX, valueFrame.midX, accuracy: 0.001)
    }

    @available(iOS 17.0, *)
    func test_threeCatalogTrailingButtons_keepExactModelGeometryAndCallbacks() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        var callbacks: [String] = []
        adapter.display(model: .init(
            style: makeStyle(horizontalSpacing: 12),
            primeTrailingImage: makeButton(
                id: "header.trailing.help",
                label: "Help",
                systemName: "questionmark.circle",
                onPress: { callbacks.append("help") }
            ),
            secondaryTrailingImage: makeButton(
                id: "header.trailing.notifications",
                label: "Notifications",
                systemName: "bell",
                onPress: { callbacks.append("notifications") }
            ),
            tertiaryTrailingImage: makeButton(
                id: "header.trailing.profile",
                label: "Profile",
                systemName: "person.crop.circle",
                onPress: { callbacks.append("profile") }
            )
        ))
        let host = makeHost(adapter: adapter)

        let buttons = try ["Help", "Notifications", "Profile"].map { label -> NSObject in
            try XCTUnwrap(host.element(withLabel: label))
        }
        let frames = buttons.map(\.accessibilityFrame)

        frames.forEach { frame in
            XCTAssertEqual(frame.width, 32, accuracy: 0.001)
            XCTAssertEqual(frame.height, 32, accuracy: 0.001)
            XCTAssertEqual(frame.midY, frames[0].midY, accuracy: 0.001)
        }
        XCTAssertEqual(frames[1].minX - frames[0].maxX, 18, accuracy: 0.001)
        XCTAssertEqual(frames[2].minX - frames[1].maxX, 18, accuracy: 0.001)
        XCTAssertEqual(
            host.frame.maxX - frames[2].maxX,
            expectedHorizontalInset,
            accuracy: 0.001
        )

        buttons.forEach { XCTAssertTrue($0.accessibilityActivate()) }
        XCTAssertEqual(callbacks, ["help", "notifications", "profile"])
    }

    func test_sideWidthResolver_prefersEqualityButContainsImpossibleOverflow() {
        let equal = SUINavigationBarSideWidthResolver.resolvedSideWidths(
            availableWidth: 358,
            mainStackSpacing: 8,
            leadingIdealWidth: 44,
            trailingIdealWidth: 132
        )
        XCTAssertEqual(equal.leading, 171, accuracy: 0.001)
        XCTAssertEqual(equal.trailing, 171, accuracy: 0.001)

        let brokenEquality = SUINavigationBarSideWidthResolver.resolvedSideWidths(
            availableWidth: 358,
            mainStackSpacing: 8,
            leadingIdealWidth: 44,
            trailingIdealWidth: 200
        )
        XCTAssertEqual(brokenEquality.leading, 44, accuracy: 0.001)
        XCTAssertEqual(brokenEquality.trailing, 200, accuracy: 0.001)

        let overflow = SUINavigationBarSideWidthResolver.resolvedSideWidths(
            availableWidth: 100,
            mainStackSpacing: 8,
            leadingIdealWidth: 60,
            trailingIdealWidth: 120
        )
        XCTAssertEqual(overflow.leading + overflow.trailing, 84, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(overflow.leading, 0)
        XCTAssertGreaterThanOrEqual(overflow.trailing, 0)
    }
}

private extension SUINavigationBarParityTests {
    @available(iOS 17.0, *)
    func makeHost(adapter: HeaderOutputSwiftUIAdapter) -> SwiftUIAccessibilityTestHost {
        SwiftUIAccessibilityTestHost(
            rootView: SUINavigationBar(adapter: adapter)
                .frame(width: containerWidth, alignment: .top)
                .ignoresSafeArea(),
            size: CGSize(width: containerWidth, height: 80)
        )
    }

    @available(iOS 17.0, *)
    func frame(
        ofLabel accessibilityLabel: String,
        in host: SwiftUIAccessibilityTestHost
    ) throws -> CGRect {
        try XCTUnwrap(
            host.element(withLabel: accessibilityLabel)
        ).accessibilityFrame
    }

    func makeStyle(horizontalSpacing: CGFloat = 8) -> HeaderPresentableModel.Style {
        .init(
            backgroundColor: .systemGroupedBackground,
            horizontalSpacing: horizontalSpacing,
            primeFont: .systemFont(ofSize: 17, weight: .semibold),
            primeColor: .label,
            secondaryFont: .systemFont(ofSize: 12),
            secondaryColor: .secondaryLabel,
            numberOfLines: 1
        )
    }

    func makeButton(
        id: String,
        label: String,
        systemName: String,
        onPress: @escaping () -> Void
    ) -> ButtonPresentableModel {
        .init(
            accessibilityIdentifier: id,
            accessibility: .init(label: label),
            image: ImageFactory.systemImage(named: systemName),
            height: 32,
            width: 32,
            onPress: onPress
        )
    }

    var expectedHorizontalInset: CGFloat {
        if #available(iOS 26, *), isLiquidGlassEnabled {
            return 16
        }
        return 8
    }
}
#endif
