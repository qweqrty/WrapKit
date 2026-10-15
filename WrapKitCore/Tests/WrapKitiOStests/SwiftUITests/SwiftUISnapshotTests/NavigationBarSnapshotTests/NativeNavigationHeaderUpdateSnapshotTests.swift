#if os(iOS) && canImport(SwiftUI)
import SwiftUI
import UIKit
import WrapKit
import XCTest

/// Keep the same NavigationStack and native bar mounted across presentation updates.
@available(iOS 17.0, *)
@MainActor
final class NativeNavigationHeaderUpdateSnapshotTests: XCTestCase {
    func test_trailingActionsOffAndOn_matchesFreshNativeToolbarAtEachStep() throws {
        let leading = CardViewPresentableModel(
            title: .text("Back to screen"),
            leadingImage: .init(image: .asset(UIImage(systemName: "chevron.left"))),
            onPress: {}
        )
        let action = ButtonPresentableModel(image: UIImage(systemName: "xmark"), onPress: {})
        let live = makeHeader(leading: leading, trailing: action)
        let initial = try capture(live, named: "native_actions_initial", requiresAccessibleTitle: false)

        live.adapter.display(primeTrailingImage: nil)
        live.adapter.display(secondaryTrailingImage: nil)
        live.adapter.display(tertiaryTrailingImage: nil)
        let withoutActions = try capture(live, named: "native_actions_removed")
        let freshFrame: CGRect = try {
            let freshWithoutActions = makeHeader(leading: leading)
            return try capture(freshWithoutActions, named: "native_actions_removed_fresh")
        }()
        assertEqualFrames(withoutActions, freshFrame)
        let fullTitleWidth = ("Navigation title" as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]).width
        XCTAssertGreaterThanOrEqual(withoutActions.width + 0.5, ceil(fullTitleWidth))

        live.adapter.display(primeTrailingImage: action)
        live.adapter.display(secondaryTrailingImage: action)
        live.adapter.display(tertiaryTrailingImage: action)
        let restored = try capture(live, named: "native_actions_restored", requiresAccessibleTitle: false)
        assertEqualFrames(restored, initial)
    }

    func test_customLeadingImage_fitsNativeToolbarBeforeAndAfterReplacement() throws {
        let logo = UIGraphicsImageRenderer(size: CGSize(width: 48, height: 48)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 48, height: 48))
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 48, height: 4))
            UIColor.green.setFill()
            context.fill(CGRect(x: 0, y: 44, width: 48, height: 4))
        }.withRenderingMode(.alwaysOriginal)
        let image = ImageViewPresentableModel(
            accessibilityIdentifier: "native.header.custom-image",
            image: .asset(logo)
        )
        let leading = CardViewPresentableModel(title: .text("Back"), secondaryLeadingImage: image, onPress: {})
        let live = makeHeader(leading: leading)

        for index in 0..<2 {
            _ = try capture(live, named: "native_custom_image_\(index)")
            let bar = try XCTUnwrap(live.host.firstSubview(of: UINavigationBar.self))
            let element = try XCTUnwrap(live.host.element(withIdentifier: "native.header.custom-image"))
            let barFrame = bar.convert(bar.bounds, to: nil)
            let imageFrame = element.accessibilityFrame
            XCTAssertGreaterThan(imageFrame.height, 0)
            XCTAssertGreaterThanOrEqual(imageFrame.minY, barFrame.minY - 0.5)
            XCTAssertLessThanOrEqual(imageFrame.maxY, barFrame.maxY + 0.5)
            let rendered = try render(bar)
            XCTAssertGreaterThan(try saturatedPixels(in: rendered, channel: 1), 20, "Bottom green stripe must remain visible, not clipped")
            XCTAssertGreaterThan(try saturatedPixels(in: rendered, channel: 2), 20, "Top blue stripe must remain visible, not clipped")
            live.adapter.display(leadingCard: nil)
            _ = try capture(live, named: "native_custom_image_removed_\(index)")
            live.adapter.display(leadingCard: leading)
        }
    }

    private struct LiveHeader {
        let adapter: HeaderOutputSwiftUIAdapter
        let host: SwiftUIAccessibilityTestHost
    }

    private func makeHeader(
        leading: CardViewPresentableModel?,
        trailing: ButtonPresentableModel? = nil
    ) -> LiveHeader {
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: .init(
                backgroundColor: .systemGroupedBackground,
                horizontalSpacing: 8,
                primeFont: .systemFont(ofSize: 17, weight: .semibold),
                primeColor: .label,
                secondaryFont: .systemFont(ofSize: 12),
                secondaryColor: .secondaryLabel
            ),
            centerView: .keyValue(.init(.text(accessibilityIdentifier: "native.header.title", "Navigation title"), nil)),
            leadingCard: leading,
            primeTrailingImage: trailing,
            secondaryTrailingImage: trailing,
            tertiaryTrailingImage: trailing
        ))
        let host = SwiftUIAccessibilityTestHost(
            rootView: NavigationStack {
                SwiftUI.Color(uiColor: .systemGroupedBackground)
                    .navigationHeader(adapter: adapter)
            },
            size: CGSize(width: 390, height: 300)
        )
        return LiveHeader(adapter: adapter, host: host)
    }

    @discardableResult
    private func capture(_ live: LiveHeader, named name: String, requiresAccessibleTitle: Bool = true) throws -> CGRect {
        // Allow native toolbar measurement and geometry preferences to finish in the same window.
        for _ in 0..<3 { live.host.settle() }
        let bar = try XCTUnwrap(live.host.firstSubview(of: UINavigationBar.self))
        let attachment = XCTAttachment(image: try render(bar))
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        if let title = live.host.element(withIdentifier: "native.header.title") {
            return title.accessibilityFrame
        }
        XCTAssertFalse(requiresAccessibleTitle, "The title must be accessible when the native bar has room for it")
        let titleView = try XCTUnwrap(bar.topItem?.titleView, "The native principal title host must remain mounted")
        let frame = titleView.convert(titleView.bounds, to: nil)
        let visibleFrame = frame.intersection(bar.convert(bar.bounds, to: nil))
        let hasNoVisibleArea = visibleFrame.isNull || visibleFrame.width <= 0.5 || visibleFrame.height <= 0.5
        XCTAssertTrue(hasNoVisibleArea || isHiddenInHierarchy(titleView, through: bar),
                      "A visible native title must retain its accessibility element")
        let geometry = XCTAttachment(string:
            "Native principal host: \(type(of: titleView)), frame=\(frame), hidden=\(titleView.isHidden), alpha=\(titleView.alpha)"
        )
        geometry.name = "\(name)_native_title_geometry"
        geometry.lifetime = .keepAlways
        add(geometry)
        return frame
    }

    private func isHiddenInHierarchy(_ view: UIView, through ancestor: UIView) -> Bool {
        var current: UIView? = view
        while let candidate = current {
            if candidate.isHidden || candidate.alpha <= 0.01 { return true }
            if candidate === ancestor { return false }
            current = candidate.superview
        }
        return false
    }

    private func assertEqualFrames(_ actual: CGRect, _ expected: CGRect, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.minX, expected.minX, accuracy: 0.5, file: file, line: line)
        XCTAssertEqual(actual.width, expected.width, accuracy: 0.5, file: file, line: line)
        XCTAssertEqual(actual.midY, expected.midY, accuracy: 0.5, file: file, line: line)
    }

    private func render(_ view: UIView) throws -> UIImage {
        XCTAssertGreaterThan(view.bounds.width, 0)
        XCTAssertGreaterThan(view.bounds.height, 0)
        return UIGraphicsImageRenderer(bounds: view.bounds).image { _ in
            XCTAssertTrue(view.drawHierarchy(in: view.bounds, afterScreenUpdates: true))
        }
    }

    private func saturatedPixels(in image: UIImage, channel: Int) throws -> Int {
        let cgImage = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: 8,
                bytesPerRow: cgImage.width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        }
        return stride(from: 0, to: bytes.count, by: 4).filter { offset in
            bytes[offset + channel] > 120 && bytes[offset + 3] > 200 &&
                (0..<3).filter { $0 != channel }.allSatisfy { bytes[offset + $0] < 80 }
        }.count
    }
}
#endif

