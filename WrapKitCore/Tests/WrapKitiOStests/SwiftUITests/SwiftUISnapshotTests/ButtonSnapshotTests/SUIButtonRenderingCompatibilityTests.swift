#if os(iOS) && canImport(SwiftUI)
import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
@MainActor
final class SUIButtonRenderingCompatibilityTests: XCTestCase {
    func test_gradientBackground_rendersBothEndpointColors() throws {
        let view = SUIButtonView(model: .init(
            height: 60, width: 140,
            style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue])), cornerStyle: .fixed(8))
        ), isEnabled: true, fillsAvailableWidth: false, fillsAvailableHeight: false)

        let pixels = try pixelImage(render(view, named: "swiftui_gradient_horizontal"))
        let left = pixels.color(x: 20, y: 30)
        let right = pixels.color(x: 120, y: 30)

        XCTAssertGreaterThan(left.red, left.blue)
        XCTAssertGreaterThan(right.blue, right.red)
    }

    func test_imageTintColor_thenNilRestoresOriginalMulticolorArtwork() throws {
        let adapter = ButtonOutputSwiftUIAdapter()
        let artwork = makeArtwork()
        adapter.display(model: .init(
            image: artwork, isGlassEffectEnabled: false, height: 60, width: 140,
            style: .init(backgroundColor: .white, cornerStyle: .fixed(8))
        ))
        let button = SUIButton(adapter: adapter)
        let original = try pixelImage(render(button, named: "swiftui_image_original"))
        XCTAssertGreaterThan(original.saturatedCount(channel: 0), 20)
        XCTAssertGreaterThan(original.saturatedCount(channel: 2), 20)

        adapter.display(style: .init(backgroundColor: .white, imageTintColor: .green, cornerStyle: .fixed(8)))
        let tinted = try pixelImage(render(button, named: "swiftui_image_tinted_green"))
        XCTAssertGreaterThan(tinted.saturatedCount(channel: 1), 20)
        XCTAssertEqual(tinted.saturatedCount(channel: 0), 0)
        XCTAssertEqual(tinted.saturatedCount(channel: 2), 0)

        adapter.display(style: .init(backgroundColor: .white, imageTintColor: nil, cornerStyle: .fixed(8)))
        let restored = try pixelImage(render(button, named: "swiftui_image_tint_removed"))
        XCTAssertEqual(restored.bytes, original.bytes)
    }

    func test_modelContentInset_overridesViewFallbackAndContributesToIntrinsicSize() {
        let view = SUIButtonView(
            model: .init(image: makeArtwork(), contentInset: .init(all: 3), isGlassEffectEnabled: false),
            isEnabled: true, fillsAvailableWidth: false, fillsAvailableHeight: false,
            contentInsets: .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        )
        let host = UIHostingController(rootView: view)

        let size = host.sizeThatFits(in: CGSize(width: 1_000, height: 1_000))

        XCTAssertEqual(size.width, 30, accuracy: 0.01)
        XCTAssertEqual(size.height, 18, accuracy: 0.01)
    }

    func test_modelContentInset_staysInsideExplicitButtonFrame() {
        let view = SUIButtonView(model: .init(
            title: "Inset title", contentInset: .init(all: 8), isGlassEffectEnabled: false, height: 48, width: 120,
            style: .init(backgroundColor: .blue)
        ), isEnabled: true, fillsAvailableWidth: false, fillsAvailableHeight: false)
        let host = UIHostingController(rootView: view)

        let size = host.sizeThatFits(in: CGSize(width: 1_000, height: 1_000))

        XCTAssertEqual(size.width, 120, accuracy: 0.01)
        XCTAssertEqual(size.height, 48, accuracy: 0.01)
    }

    func test_glassOptOut_rendersIdenticallyToLegacyButtonWithSameStyle() throws {
        let optedOut = SUIButtonView(model: .init(
            title: "Plain", isGlassEffectEnabled: false, height: 60, width: 140,
            style: .init(backgroundColor: .red, titleColor: .white, cornerStyle: .fixed(8), glassConfiguration: .prominentGlass)
        ), isEnabled: true, fillsAvailableWidth: false, fillsAvailableHeight: false)
        let legacy = SUIButtonView(model: .init(
            title: "Plain", height: 60, width: 140,
            style: .init(backgroundColor: .red, titleColor: .white, cornerStyle: .fixed(8))
        ), isEnabled: true, fillsAvailableWidth: false, fillsAvailableHeight: false)

        let optedOutPixels = try pixelImage(render(optedOut, named: "swiftui_glass_explicitly_disabled"))
        let legacyPixels = try pixelImage(render(legacy, named: "swiftui_glass_disabled_legacy_reference"))

        XCTAssertEqual(optedOutPixels.bytes, legacyPixels.bytes)
    }

    func test_publicHeaderButton_glassOptOutRendersGradientAndExplicitImageTint() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: headerStyle,
            primeTrailingImage: .init(
                image: makeArtwork(), contentInset: .init(all: 5), isGlassEffectEnabled: false, height: 40, width: 80,
                style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue])), imageTintColor: .green,
                             cornerStyle: .fixed(8), glassConfiguration: .glass), onPress: {}
            )
        ))

        let pixels = try pixelImage(render(SUINavigationBar(adapter: adapter), named: "swiftui_header_gradient_tint_glass_disabled"))

        XCTAssertGreaterThan(pixels.saturatedCount(channel: 0), 20, "The legacy header button must draw the red gradient endpoint")
        XCTAssertGreaterThan(pixels.saturatedCount(channel: 2), 20, "The legacy header button must draw the blue gradient endpoint")
        XCTAssertGreaterThan(pixels.saturatedCount(channel: 1), 20, "Explicit green image tint must override the header's blue foreground")
    }

    func test_publicHeaderButton_gradientWithoutGlassConfigurationRendersLegacyGradient() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: headerStyle,
            primeTrailingImage: .init(
                image: makeArtwork(), contentInset: .init(all: 5), height: 40, width: 80,
                style: .init(backgroundColor: .gradient(.init(colors: [.red, .blue])), imageTintColor: .green,
                             cornerStyle: .fixed(8)), onPress: {}
            )
        ))

        let pixels = try pixelImage(render(SUINavigationBar(adapter: adapter), named: "swiftui_header_gradient_without_glass_configuration"))

        XCTAssertGreaterThan(pixels.saturatedCount(channel: 0), 20, "A gradient without a glass configuration must keep its red endpoint")
        XCTAssertGreaterThan(pixels.saturatedCount(channel: 2), 20, "A gradient without a glass configuration must keep its blue endpoint")
        XCTAssertGreaterThan(pixels.saturatedCount(channel: 1), 20)
    }

    func test_publicHeaderButton_contentInsetMovesImageWithinUnchangedFrame() throws {
        let adapter = HeaderOutputSwiftUIAdapter()
        adapter.display(model: .init(style: headerStyle, primeTrailingImage: headerButton(contentInset: .zero)))
        let header = SUINavigationBar(adapter: adapter)
        let initial = try pixelImage(render(header, named: "swiftui_header_zero_button_insets"))

        adapter.display(primeTrailingImage: headerButton(contentInset: .init(top: 0, leading: 16, bottom: 0, trailing: 0)))
        let updated = try pixelImage(render(header, named: "swiftui_header_asymmetric_button_insets"))

        let originalCenter = try XCTUnwrap(initial.saturatedCenterX(channel: 1))
        let updatedCenter = try XCTUnwrap(updated.saturatedCenterX(channel: 1))
        XCTAssertEqual(updatedCenter - originalCenter, 8, accuracy: 1, "Leading padding must affect the actual image, not just the model")
        XCTAssertEqual(initial.saturatedCount(channel: 1), updated.saturatedCount(channel: 1))
    }

    private var headerStyle: HeaderPresentableModel.Style {
        .init(backgroundColor: .white, horizontalSpacing: 8,
              primeFont: .systemFont(ofSize: 17), primeColor: .blue,
              secondaryFont: .systemFont(ofSize: 12), secondaryColor: .gray)
    }

    private func headerButton(contentInset: WrapKit.EdgeInsets) -> ButtonPresentableModel {
        .init(image: makeArtwork(), contentInset: contentInset, isGlassEffectEnabled: false, height: 40, width: 80,
              style: .init(backgroundColor: .white, imageTintColor: .green, cornerStyle: .fixed(8), glassConfiguration: .glass),
              onPress: {})
    }

    private func makeArtwork() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 24, height: 12), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
            UIColor.blue.setFill()
            context.fill(CGRect(x: 12, y: 0, width: 12, height: 12))
        }.withRenderingMode(.alwaysOriginal)
    }

    private func render<V: View>(_ view: V, named name: String) -> UIImage {
        let image = view.snapshot(for: .init(
            size: CGSize(width: 140, height: 60), safeAreaInsets: .init(), layoutMargins: .init(), colorScheme: .light, scale: 1
        ), background: .white)
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return image
    }

    private struct PixelImage {
        let bytes: [UInt8]
        let width: Int

        func color(x: Int, y: Int) -> (red: UInt8, green: UInt8, blue: UInt8) {
            let index = (y * width + x) * 4
            return (bytes[index], bytes[index + 1], bytes[index + 2])
        }

        func saturatedCount(channel: Int) -> Int {
            stride(from: 0, to: bytes.count, by: 4).filter { index in
                bytes[index + channel] > 180 && (0..<3).filter { $0 != channel }.allSatisfy { bytes[index + $0] < 80 }
            }.count
        }

        func saturatedCenterX(channel: Int) -> Double? {
            let positions = stride(from: 0, to: bytes.count, by: 4).filter { index in
                bytes[index + channel] > 180 && (0..<3).filter { $0 != channel }.allSatisfy { bytes[index + $0] < 80 }
            }.map { ($0 / 4) % width }
            guard !positions.isEmpty else { return nil }
            return Double(positions.reduce(0, +)) / Double(positions.count)
        }
    }

    private func pixelImage(_ image: UIImage) throws -> PixelImage {
        let cgImage = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: cgImage.width, height: cgImage.height,
                bitsPerComponent: 8, bytesPerRow: cgImage.width * 4,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        }
        return PixelImage(bytes: bytes, width: cgImage.width)
    }
}
#endif
