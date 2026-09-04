#if canImport(SwiftUI) && canImport(UIKit)
import CoreGraphics
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
final class SUICardViewLayoutTests: XCTestCase {
    func test_uiKitFillCard_expandsTitleBlockAndPinsTrailingImage() {
        let sut = CardView(frame: CGRect(x: 0, y: 0, width: 320, height: 56))
        sut.display(model: .init(
            style: fillCardStyle,
            title: .text("Compact"),
            trailingImage: .init(
                size: .init(width: 22, height: 22),
                image: .symbolName("checkmark.circle.fill"),
                contentModeIsFit: true
            )
        ))

        sut.layoutIfNeeded()

        XCTAssertGreaterThan(sut.titleViewsWrapperView.frame.width, 200)
        XCTAssertEqual(
            sut.trailingImageWrapperView.frame.maxX,
            sut.hStackView.bounds.width - 12,
            accuracy: 0.5
        )
    }

    func test_swiftUIFillCard_expandsTitleBlockAndPinsTrailingImage() {
        let resolution = CardFillHorizontalResolver.resolve(
            idealWidths: [80, 22],
            items: [
                .init(role: .flexibleText, leadingSpacing: nil),
                .fixed
            ],
            availableWidth: 296,
            defaultSpacing: 8
        )

        XCTAssertEqual(resolution.widths, [266, 22])
        XCTAssertEqual(resolution.origins, [0, 274])
        XCTAssertEqual(maxX(of: resolution), 296)
    }

    func test_bottomImageModel_updatesUIKitAndSwiftUIAndCanBeClearedIndependently() {
        let imageModel = ImageViewPresentableModel.systemSymbol(
            "ellipsis.rectangle.fill",
            size: .init(width: 120, height: 22),
            contentModeIsFit: true
        )
        let uiKitView = CardView()
        let adapter = CardViewOutputSwiftUIAdapter()
        let stateModel = SUICardViewStateModel(adapter: adapter)

        uiKitView.display(model: .init(bottomImage: imageModel))
        adapter.display(model: .init(bottomImage: imageModel))

        XCTAssertFalse(uiKitView.bottomImageWrapperView.isHidden)
        XCTAssertTrue(uiKitView.bottomImageView.superview === uiKitView.bottomImageWrapperView)
        XCTAssertEqual(stateModel.bottomImage, imageModel)

        uiKitView.display(bottomImage: nil)
        adapter.display(bottomImage: nil)

        XCTAssertTrue(uiKitView.bottomImageWrapperView.isHidden)
        XCTAssertNil(stateModel.bottomImage)
    }

    func test_uiKitCard_bottomImageUsesItsContentHeight() {
        let sut = CardView()
        sut.display(bottomImage: .systemSymbol(
            "ellipsis.rectangle.fill",
            size: .init(width: 120, height: 22),
            contentModeIsFit: true
        ))

        let size = sut.systemLayoutSizeFitting(
            CGSize(width: 200, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        XCTAssertEqual(size.height, 22, accuracy: 0.5)
    }

    func test_iOS26_nativeSwitchUsesItsRealIntrinsicSize() {
        guard #available(iOS 26.0, *) else { return }

        let view = SUISwitchControlView(
            isOn: false,
            style: .init(
                tintColor: .systemBlue,
                thumbTintColor: .white,
                backgroundColor: .systemGray5,
                cornerRadius: 16
            )
        )
        let host = UIHostingController(rootView: view.fixedSize())
        host.loadViewIfNeeded()
        let size = host.sizeThatFits(in: CGSize(width: 1_000, height: 1_000))

        XCTAssertEqual(size.width, 61, accuracy: 0.001)
        XCTAssertEqual(size.height, 28, accuracy: 0.001)
    }

    func test_iOS26_nativeSwitchPreservesPhysicalFrameAroundIntrinsicAlignmentRect() throws {
        guard #available(iOS 26.0, *) else { return }

        let host = CardFillLayoutTestHost(
            rootView: SUISwitchControlView(isOn: false).fixedSize(),
            size: .init(width: 80, height: 44)
        )

        let nativeSwitch = try XCTUnwrap(host.nativeSwitch())
        let container = try XCTUnwrap(nativeSwitch.superview)
        let alignmentRect = nativeSwitch.alignmentRect(forFrame: nativeSwitch.frame)

        XCTAssertEqual(container.bounds.size.width, 61, accuracy: 0.001)
        XCTAssertEqual(container.bounds.size.height, 28, accuracy: 0.001)
        XCTAssertEqual(nativeSwitch.bounds.size.width, 63, accuracy: 0.001)
        XCTAssertEqual(nativeSwitch.bounds.size.height, 28, accuracy: 0.001)
        XCTAssertEqual(alignmentRect.minX, container.bounds.minX, accuracy: 0.001)
        XCTAssertEqual(alignmentRect.maxX, container.bounds.maxX, accuracy: 0.001)
        XCTAssertEqual(alignmentRect.minY, container.bounds.minY, accuracy: 0.001)
        XCTAssertEqual(alignmentRect.maxY, container.bounds.maxY, accuracy: 0.001)
    }

    func test_iOS26_nativeSwitchConsumesEveryOutputStyleColor() throws {
        guard #available(iOS 26.0, *) else { return }

        let view = SUISwitchControlView(
            isOn: true,
            style: .init(
                tintColor: .systemPurple,
                thumbTintColor: .systemYellow,
                backgroundColor: .systemGreen,
                cornerRadius: 9
            )
        )
        let host = CardFillLayoutTestHost(
            rootView: view.fixedSize(),
            size: .init(width: 80, height: 44)
        )

        let nativeSwitch = try XCTUnwrap(host.nativeSwitch())
        XCTAssertEqual(nativeSwitch.onTintColor, .systemPurple)
        XCTAssertEqual(nativeSwitch.thumbTintColor, .systemYellow)
        XCTAssertEqual(nativeSwitch.backgroundColor, .systemGreen)
        XCTAssertEqual(nativeSwitch.cornerRadiusValue(), 9, accuracy: 0.001)
        XCTAssertFalse(nativeSwitch.clipsToBounds)
    }

    func test_iOS26_adjacentNativeSwitchesKeepIndependentStylesAcrossUpdates() throws {
        guard #available(iOS 26.0, *) else { return }

        let firstAdapter = SwitchCotrolOutputSwiftUIAdapter()
        let secondAdapter = SwitchCotrolOutputSwiftUIAdapter()
        firstAdapter.display(model: .init(
            accessibilityIdentifier: "first-switch",
            isOn: true,
            style: .init(
                tintColor: .systemRed,
                thumbTintColor: .systemYellow,
                backgroundColor: .systemGreen,
                cornerRadius: 7
            )
        ))
        secondAdapter.display(model: .init(
            accessibilityIdentifier: "second-switch",
            isOn: true,
            style: .init(
                tintColor: .systemPurple,
                thumbTintColor: .white,
                backgroundColor: .systemOrange,
                cornerRadius: 13
            )
        ))
        let host = CardFillLayoutTestHost(
            rootView: HStack(spacing: 12) {
                SUISwitchControl(adapter: firstAdapter)
                SUISwitchControl(adapter: secondAdapter)
            }
            .fixedSize(),
            size: .init(width: 160, height: 44)
        )

        assertNativeSwitch(
            in: host,
            identifier: "first-switch",
            tintColor: .systemRed,
            thumbTintColor: .systemYellow,
            backgroundColor: .systemGreen,
            cornerRadius: 7
        )
        assertNativeSwitch(
            in: host,
            identifier: "second-switch",
            tintColor: .systemPurple,
            thumbTintColor: .white,
            backgroundColor: .systemOrange,
            cornerRadius: 13
        )

        firstAdapter.display(style: .init(
            tintColor: .systemBlue,
            thumbTintColor: .black,
            backgroundColor: .systemGray4,
            cornerRadius: 4
        ))
        secondAdapter.display(style: .init(
            tintColor: .systemGreen,
            thumbTintColor: .systemPink,
            backgroundColor: .systemIndigo,
            cornerRadius: 10
        ))
        host.settle()

        assertNativeSwitch(
            in: host,
            identifier: "first-switch",
            tintColor: .systemBlue,
            thumbTintColor: .black,
            backgroundColor: .systemGray4,
            cornerRadius: 4
        )
        assertNativeSwitch(
            in: host,
            identifier: "second-switch",
            tintColor: .systemGreen,
            thumbTintColor: .systemPink,
            backgroundColor: .systemIndigo,
            cornerRadius: 10
        )
    }

    func test_fillLayout_compressesTextBeforeFixedAccessories() {
        let resolution = CardFillHorizontalResolver.resolve(
            idealWidths: [72, 28, 120, 150, 20, 51, 64],
            items: [
                .init(role: .flexibleText, leadingSpacing: nil),
                .fixed,
                .init(role: .flexibleText, leadingSpacing: nil),
                .init(role: .subtitle, leadingSpacing: nil),
                .fixed,
                .fixed,
                .init(role: .flexibleText, leadingSpacing: nil)
            ],
            availableWidth: 318,
            defaultSpacing: 8
        )

        XCTAssertEqual(resolution.widths[1], 28)
        XCTAssertEqual(resolution.widths[4], 20)
        XCTAssertEqual(resolution.widths[5], 51)
        XCTAssertLessThanOrEqual(maxX(of: resolution), 318.001)
    }

    func test_fillLayout_neverPlacesContentBeyondExceptionallyNarrowProposal() {
        let resolution = CardFillHorizontalResolver.resolve(
            idealWidths: [44, 28, 51, 32],
            items: [.fixed, .fixed, .fixed, .fixed],
            availableWidth: 24,
            defaultSpacing: 8
        )

        XCTAssertTrue(resolution.widths.allSatisfy { $0 >= 0 })
        XCTAssertLessThanOrEqual(maxX(of: resolution), 24.001)
    }

    func test_fillLayout_preservesAllEnabledCardSwitchVisualWidth() {
        let resolution = CardFillHorizontalResolver.resolve(
            idealWidths: [92, 28, 20, 86, 124, 20, 16, 63, 48],
            items: [
                .init(role: .flexibleText, leadingSpacing: nil),
                .fixed,
                .fixed,
                .init(role: .flexibleText, leadingSpacing: nil),
                .init(role: .subtitle, leadingSpacing: nil),
                .fixed,
                .fixed,
                .fixed,
                .init(role: .flexibleText, leadingSpacing: nil)
            ],
            availableWidth: 349,
            defaultSpacing: 6
        )

        XCTAssertEqual(resolution.widths[7], 63, accuracy: 0.001)
        XCTAssertLessThanOrEqual(maxX(of: resolution), 349.001)
    }

    func test_iOS26_tightCardWithLongTitle_rendersWholeSwitchInLTRAndRTL() {
        guard #available(iOS 26.0, *) else { return }

        let adapter = CardViewOutputSwiftUIAdapter()
        adapter.display(model: .init(
            id: "catalog.controls.refresh.setting.directCallbacks",
            accessibilityIdentifier: "catalog.controls.refresh.setting.directCallbacks",
            accessibility: .init(label: "Configure actions through public onRefresh"),
            style: .init(
                backgroundColor: .secondarySystemGroupedBackground,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .init(horizontal: 12, vertical: 8),
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .label,
                titleKeyTextColor: .label,
                trailingTitleKeyTextColor: .label,
                titleValueTextColor: .secondaryLabel,
                subTitleTextColor: .secondaryLabel,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 15),
                titleKeyLabelFont: .systemFont(ofSize: 15),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 15),
                titleValueLabelFont: .systemFont(ofSize: 12),
                subTitleLabelFont: .systemFont(ofSize: 12),
                subtitleNumberOfLines: 2,
                cornerRadius: 12,
                stackSpace: 2,
                hStackViewSpacing: 8,
                titleKeyNumberOfLines: 2,
                titleValueNumberOfLines: 2,
                borderColor: .separator,
                borderWidth: 0.5,
                trailingImageLeadingSpacing: 6
            ),
            title: .text("Configure actions through public onRefresh"),
            switchControl: .init(
                accessibilityIdentifier: "catalog.controls.refresh.setting.directCallbacks.switch",
                isOn: true,
                isEnabled: true,
                style: .init(
                    tintColor: .systemBlue,
                    thumbTintColor: .white,
                    backgroundColor: .systemGray5,
                    cornerRadius: 16
                )
            ),
            isUserInteractionEnabled: true
        ))
        let width: CGFloat = 220
        for interfaceStyle in [UIUserInterfaceStyle.light, .dark] {
            let colorScheme: ColorScheme = interfaceStyle == .dark ? .dark : .light
            let referencePixels = nativeSwitchReferenceBlueBounds(interfaceStyle: interfaceStyle)
            for layoutDirection in [LayoutDirection.leftToRight, .rightToLeft] {
                let rootView = SUICardView(adapter: adapter)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .frame(width: width)
                    .environment(\.layoutDirection, layoutDirection)
                    .environment(\.colorScheme, colorScheme)
                    .ignoresSafeArea()
                let sizingHost = UIHostingController(rootView: rootView)
                sizingHost.overrideUserInterfaceStyle = interfaceStyle
                sizingHost.loadViewIfNeeded()
                let measuredSize = sizingHost.sizeThatFits(
                    in: CGSize(width: width, height: 1_000)
                )
                let size = CGSize(width: width, height: ceil(measuredSize.height))
                let host = CardFillLayoutTestHost(
                    rootView: rootView,
                    size: size,
                    interfaceStyle: interfaceStyle
                )

                let image = host.renderedImage()
                let attachment = XCTAttachment(image: image)
                attachment.name = "Tight card \(interfaceStyle) \(layoutDirection)"
                attachment.lifetime = .keepAlways
                add(attachment)
                let switchPixels = image.rgbaPixels.dominantBlueBounds(pixelWidth: Int(size.width))
                guard let switchFrame = host.nativeSwitchAlignmentFrame(),
                      let physicalSwitchFrame = host.nativeSwitchPhysicalFrame() else {
                    XCTFail("Expected the card to host a native UISwitch")
                    continue
                }
                let semanticInset = layoutDirection == .leftToRight
                    ? size.width - switchFrame.maxX
                    : switchFrame.minX

                XCTAssertGreaterThan(measuredSize.height, 0)
                XCTAssertEqual(switchPixels?.height, referencePixels?.height)
                if let switchPixelWidth = switchPixels?.width,
                   let referencePixelWidth = referencePixels?.width {
                    // UIKit can place the physical iOS 26 switch on a half-pixel
                    // while the card layout lands it on an integral pixel. The
                    // integral placement may render one additional edge pixel,
                    // but must never clip below the standalone reference width.
                    XCTAssertGreaterThanOrEqual(switchPixelWidth, referencePixelWidth)
                    XCTAssertLessThanOrEqual(switchPixelWidth - referencePixelWidth, 1)
                } else {
                    XCTFail("Expected visible switch pixels")
                }
                XCTAssertEqual(switchFrame.width, 61, accuracy: 0.001)
                XCTAssertEqual(switchFrame.height, 28, accuracy: 0.001)
                XCTAssertEqual(physicalSwitchFrame.width, 63, accuracy: 0.001)
                XCTAssertLessThanOrEqual(physicalSwitchFrame.minX, switchFrame.minX)
                XCTAssertGreaterThanOrEqual(physicalSwitchFrame.maxX, switchFrame.maxX)
                XCTAssertEqual(
                    physicalSwitchFrame.width - switchFrame.width,
                    2,
                    accuracy: 0.001
                )
                XCTAssertEqual(semanticInset, 12, accuracy: 0.001)
                XCTAssertGreaterThanOrEqual(physicalSwitchFrame.minX, 0)
                XCTAssertGreaterThanOrEqual(physicalSwitchFrame.minY, 0)
                XCTAssertLessThanOrEqual(physicalSwitchFrame.maxX, size.width)
                XCTAssertLessThanOrEqual(physicalSwitchFrame.maxY, size.height)
            }
        }
    }

    private func nativeSwitchReferenceBlueBounds(
        interfaceStyle: UIUserInterfaceStyle
    ) -> CGRect? {
        let size = CGSize(width: 100, height: 60)
        let viewController = UIViewController()
        viewController.overrideUserInterfaceStyle = interfaceStyle
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = viewController
        let nativeSwitch = UISwitch(frame: .zero)
        nativeSwitch.onTintColor = .systemBlue
        nativeSwitch.thumbTintColor = .white
        nativeSwitch.backgroundColor = .systemGray5
        nativeSwitch.applyCornerStyle(.fixed(16))
        nativeSwitch.setOn(true, animated: false)
        viewController.view.addSubview(nativeSwitch)
        let alignmentSize = nativeSwitch.intrinsicContentSize
        nativeSwitch.frame = nativeSwitch.frame(forAlignmentRect: CGRect(
            x: (size.width - alignmentSize.width) / 2,
            y: (size.height - alignmentSize.height) / 2,
            width: alignmentSize.width,
            height: alignmentSize.height
        ))
        window.makeKeyAndVisible()
        viewController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        defer { window.isHidden = true }

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let image = UIGraphicsImageRenderer(
            bounds: CGRect(origin: .zero, size: size),
            format: format
        ).image { _ in
            viewController.view.drawHierarchy(
                in: viewController.view.bounds,
                afterScreenUpdates: true
            )
        }
        return image.rgbaPixels.dominantBlueBounds(pixelWidth: Int(size.width))
    }

    func test_scrollableContent_appliesSymmetricHorizontalInsetsInsideViewport() {
        let width: CGFloat = 402
        let horizontalInset: CGFloat = 12
        let host = CardFillLayoutTestHost(
            rootView: SUIScrollableContentView(
                contentInset: .init(
                    top: 0,
                    leading: horizontalInset,
                    bottom: 0,
                    trailing: horizontalInset
                )
            ) {
                SwiftUI.Color.red
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            },
            size: .init(width: width, height: 100)
        )

        let pixels = host.renderedPixels()
        guard let redBounds = pixels.dominantRedBounds(pixelWidth: Int(width)) else {
            XCTFail("Expected the scroll content fixture to render")
            return
        }

        XCTAssertEqual(redBounds.minX, horizontalInset, accuracy: 0.001)
        XCTAssertEqual(redBounds.maxX, width - horizontalInset, accuracy: 0.001)
    }

    func test_scrollableContent_doesNotClipTrailingCardBorder() {
        let width: CGFloat = 402
        let horizontalInset: CGFloat = 12
        let adapter = CardViewOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: .init(
                backgroundColor: .systemGreen,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .init(horizontal: 12, vertical: 8),
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .label,
                titleKeyTextColor: .label,
                trailingTitleKeyTextColor: .label,
                titleValueTextColor: .secondaryLabel,
                subTitleTextColor: .secondaryLabel,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 15),
                titleKeyLabelFont: .systemFont(ofSize: 15),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 15),
                titleValueLabelFont: .systemFont(ofSize: 12),
                subTitleLabelFont: .systemFont(ofSize: 12),
                cornerRadius: 12,
                stackSpace: 2,
                hStackViewSpacing: 8,
                titleKeyNumberOfLines: 2,
                titleValueNumberOfLines: 2,
                borderColor: .systemRed,
                borderWidth: 2
            ),
            title: .text("Refresh setting")
        ))
        let host = CardFillLayoutTestHost(
            rootView: SUIScrollableContentView(
                contentInset: .init(
                    top: 0,
                    leading: horizontalInset,
                    bottom: 0,
                    trailing: horizontalInset
                )
            ) {
                SUICardView(adapter: adapter)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
            },
            size: .init(width: width, height: 100)
        )

        let pixels = host.renderedPixels()
        guard let borderBounds = pixels.dominantRedBounds(pixelWidth: Int(width)) else {
            XCTFail("Expected the card border to render")
            return
        }

        XCTAssertEqual(borderBounds.minX, horizontalInset, accuracy: 0.001)
        XCTAssertEqual(borderBounds.maxX, width - horizontalInset, accuracy: 0.001)
    }

    func test_fillLayout_clipsFixedContentToItsResolvedViewport() {
        guard #available(iOS 16.0, *) else { return }

        let host = CardFillLayoutTestHost(
            rootView: CardFillFixedViewportFixture(),
            size: CGSize(width: 100, height: 100)
        )
        let pixels = host.renderedPixels()

        XCTAssertEqual(pixels.dominantRedPixelCount, 0)
        XCTAssertGreaterThan(pixels.dominantGreenPixelCount, 0)
        XCTAssertGreaterThan(pixels.dominantBluePixelCount, 0)
    }

    func test_flexibleViewport_usesWrappedHeightAtResolvedWidth() {
        guard #available(iOS 16.0, *) else { return }

        let wrapped = CardFillViewportLayout(measuresContentAtProposedWidth: true) {
            Text("Configure actions through public onRefresh")
                .font(.system(size: 17))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        let host = UIHostingController(
            rootView: wrapped.fixedSize(horizontal: false, vertical: true)
        )
        host.loadViewIfNeeded()

        let size = host.sizeThatFits(in: CGSize(width: 180, height: 1_000))

        XCTAssertGreaterThan(size.height, 30)
        XCTAssertLessThan(size.height, 50)
    }

    private func maxX(of resolution: CardFillHorizontalResolution) -> CGFloat {
        zip(resolution.origins, resolution.widths)
            .map { $0 + $1 }
            .max() ?? 0
    }

    private var fillCardStyle: CardViewPresentableModel.Style {
        .init(
            backgroundColor: .systemBackground,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .init(horizontal: 12, vertical: 0),
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .label,
            titleKeyTextColor: .label,
            trailingTitleKeyTextColor: .label,
            titleValueTextColor: .secondaryLabel,
            subTitleTextColor: .secondaryLabel,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 16),
            titleKeyLabelFont: .systemFont(ofSize: 16),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 16),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14),
            cornerRadius: 0,
            stackSpace: 0,
            hStackViewSpacing: 8,
            titleKeyNumberOfLines: 1,
            titleValueNumberOfLines: 1
        )
    }

    private func assertNativeSwitch(
        in host: CardFillLayoutTestHost,
        identifier: String,
        tintColor: UIColor,
        thumbTintColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CGFloat,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let nativeSwitch = host.nativeSwitch(identifier: identifier) else {
            XCTFail("Missing native switch \(identifier)", file: file, line: line)
            return
        }
        XCTAssertEqual(nativeSwitch.onTintColor, tintColor, file: file, line: line)
        XCTAssertEqual(nativeSwitch.thumbTintColor, thumbTintColor, file: file, line: line)
        XCTAssertEqual(nativeSwitch.backgroundColor, backgroundColor, file: file, line: line)
        XCTAssertEqual(
            nativeSwitch.cornerRadiusValue(),
            cornerRadius,
            accuracy: 0.001,
            file: file,
            line: line
        )
    }
}

@available(iOS 16.0, *)
private struct CardFillFixedViewportFixture: View {
    var body: some View {
        CardFillHorizontalLayout(defaultSpacing: 8) {
            fixedViewport(color: .red)
            fixedViewport(color: .green)
            fixedViewport(color: .blue)
        }
        .frame(width: 100, height: 20)
        .background(SwiftUI.Color.black)
    }

    private func fixedViewport(color: SwiftUI.Color) -> some View {
        CardFillViewportLayout {
            color
                .frame(width: 80, height: 20)
                .fixedSize(horizontal: true, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .clipped()
    }
}

@MainActor
private final class CardFillLayoutTestHost {
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow

    init(
        rootView: some View,
        size: CGSize,
        interfaceStyle: UIUserInterfaceStyle = .unspecified
    ) {
        hostingController = UIHostingController(rootView: AnyView(rootView))
        hostingController.overrideUserInterfaceStyle = interfaceStyle
        window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.backgroundColor = .clear
        window.rootViewController = hostingController
        hostingController.view.frame = window.bounds
        hostingController.view.backgroundColor = .clear
        window.makeKeyAndVisible()
        settle()
    }

    deinit {
        window.isHidden = true
    }

    func renderedPixels() -> [UInt8] {
        renderedImage().rgbaPixels
    }

    func renderedImage() -> UIImage {
        settle()
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        return UIGraphicsImageRenderer(bounds: hostingController.view.bounds, format: format).image { _ in
            hostingController.view.drawHierarchy(
                in: hostingController.view.bounds,
                afterScreenUpdates: true
            )
        }
    }

    func nativeSwitchAlignmentFrame() -> CGRect? {
        guard let nativeSwitch = nativeSwitch() else { return nil }
        let alignmentFrame = nativeSwitch.alignmentRect(forFrame: nativeSwitch.frame)
        return nativeSwitch.superview?.convert(alignmentFrame, to: hostingController.view)
    }

    func nativeSwitchPhysicalFrame() -> CGRect? {
        guard let nativeSwitch = nativeSwitch() else { return nil }
        return nativeSwitch.superview?.convert(nativeSwitch.frame, to: hostingController.view)
    }

    func nativeSwitch() -> UISwitch? {
        nativeSwitches().first
    }

    func nativeSwitch(identifier: String) -> UISwitch? {
        nativeSwitches().first { $0.accessibilityIdentifier == identifier }
    }

    func nativeSwitches() -> [UISwitch] {
        hostingController.view.allSubviews.compactMap { $0 as? UISwitch }
    }

    func settle() {
        window.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }
}

private extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap(\.allSubviews)
    }
}

private extension Array where Element == UInt8 {
    func dominantRedBounds(pixelWidth: Int) -> CGRect? {
        dominantBounds(pixelWidth: pixelWidth) { red, green, blue in
            Int(red) > Int(green) + 40 && Int(red) > Int(blue) + 40
        }
    }

    func dominantBlueBounds(pixelWidth: Int) -> CGRect? {
        dominantBounds(pixelWidth: pixelWidth) { red, green, blue in
            Int(blue) > Int(red) + 40 && Int(blue) > Int(green) + 40
        }
    }

    func dominantBounds(
        pixelWidth: Int,
        where isDominant: (UInt8, UInt8, UInt8) -> Bool
    ) -> CGRect? {
        var minimumX = Int.max
        var maximumX = Int.min
        var minimumY = Int.max
        var maximumY = Int.min

        for index in stride(from: 0, to: count, by: 4) {
            let red = self[index]
            let green = self[index + 1]
            let blue = self[index + 2]
            let alpha = self[index + 3]
            guard alpha > 32, isDominant(red, green, blue) else { continue }

            let pixelIndex = index / 4
            let pixelX = pixelIndex % pixelWidth
            let pixelY = pixelIndex / pixelWidth
            minimumX = Swift.min(minimumX, pixelX)
            maximumX = Swift.max(maximumX, pixelX)
            minimumY = Swift.min(minimumY, pixelY)
            maximumY = Swift.max(maximumY, pixelY)
        }

        guard minimumX != .max else { return nil }
        return CGRect(
            x: minimumX,
            y: minimumY,
            width: maximumX - minimumX + 1,
            height: maximumY - minimumY + 1
        )
    }

    var dominantRedPixelCount: Int {
        dominantPixelCount { red, green, blue in
            Int(red) > Int(green) + 40 && Int(red) > Int(blue) + 40
        }
    }

    var dominantGreenPixelCount: Int {
        dominantPixelCount { red, green, blue in
            Int(green) > Int(red) + 40 && Int(green) > Int(blue) + 40
        }
    }

    var dominantBluePixelCount: Int {
        dominantPixelCount { red, green, blue in
            Int(blue) > Int(red) + 40 && Int(blue) > Int(green) + 40
        }
    }

    func dominantPixelCount(
        where isDominant: (UInt8, UInt8, UInt8) -> Bool
    ) -> Int {
        stride(from: 0, to: count, by: 4).reduce(into: 0) { result, index in
            let alpha = self[index + 3]
            if alpha > 32, isDominant(self[index], self[index + 1], self[index + 2]) {
                result += 1
            }
        }
    }
}

private extension UIImage {
    var rgbaPixels: [UInt8] {
        guard let cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return []
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }
}
#endif
