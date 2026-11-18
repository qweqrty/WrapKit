#if os(iOS) && canImport(SwiftUI)
import SwiftUI
import UIKit
import XCTest
@testable import WrapKit

@MainActor
@available(iOS 17.0, *)
final class SUIImageViewAssetTintTests: XCTestCase {
    func test_tintedOriginalAsset_preservesNativePixels() async throws {
        let asset = makeAsset()
        let image = asset.image(with: .init(userInterfaceStyle: .light))
            .withTintColor(UIColor(white: 74 / 255, alpha: 1))
            .withRenderingMode(.alwaysOriginal)
        try await assertNativePixels(image, named: "tinted_original")
        withExtendedLifetime(asset) {}
    }

    func test_rawBitmap_preservesNativePixelsWithoutCatalogResolution() async throws {
        let rendered = UIGraphicsImageRenderer(size: .init(width: 24, height: 24)).image { context in
            UIColor.systemGreen.setFill()
            context.fill(.init(x: 0, y: 0, width: 24, height: 24))
        }
        let image = UIImage(
            cgImage: try XCTUnwrap(rendered.cgImage),
            scale: rendered.scale,
            orientation: rendered.imageOrientation
        ).withRenderingMode(.alwaysOriginal)
        try await assertNativePixels(image, named: "raw_bitmap")
    }

    func test_distinctTintsOfSameAsset_doNotShareCachedPixels() async throws {
        let asset = makeAsset()
        for (index, color) in [UIColor.systemRed, .systemBlue].enumerated() {
            let image = asset.image(with: .init(userInterfaceStyle: .light))
                .withTintColor(color).withRenderingMode(.alwaysOriginal)
            try await assertNativePixels(image, named: "distinct_tint_\(index)")
        }
    }

    func test_templateAsset_keepsNativeTintBehavior() async throws {
        let image = makeAsset().image(with: .init(userInterfaceStyle: .light))
            .withRenderingMode(.alwaysTemplate)
        try await assertNativePixels(image, tint: .systemRed, named: "template_tint")
    }

    func test_dynamicAsset_doesNotReuseLightRasterInDarkEnvironment() async throws {
        let asset = makeAsset()
        let image = asset.image(with: .init(userInterfaceStyle: .light))
        var nativePixels: [[Double]] = []
        for (style, scheme) in [(UIUserInterfaceStyle.light, ColorScheme.light), (.dark, .dark), (.light, .light)] {
            nativePixels.append(try await assertNativePixels(
                image, style: style, scheme: scheme, named: "dynamic_\(style.rawValue)"
            ))
        }
        XCTAssertNotEqual(nativePixels[0], nativePixels[1], "The native fixture must really resolve distinct light/dark variants.")
        XCTAssertEqual(nativePixels[0], nativePixels[2], "Returning to light restores the initial native variant.")
        withExtendedLifetime(asset) {}
    }

    private func makeAsset() -> UIImageAsset {
        let asset = UIImageAsset()
        for (style, color) in [(UIUserInterfaceStyle.light, UIColor.lightGray), (.dark, .systemBlue)] {
            let image = UIGraphicsImageRenderer(size: .init(width: 24, height: 24)).image { context in
                color.setFill()
                context.fill(.init(x: 0, y: 0, width: 24, height: 24))
            }
            asset.register(image.withRenderingMode(.alwaysOriginal), with: .init(userInterfaceStyle: style))
        }
        return asset
    }

    @discardableResult
    private func assertNativePixels(
        _ image: UIImage,
        tint: UIColor = .black,
        style: UIUserInterfaceStyle = .light,
        scheme: ColorScheme = .light,
        named name: String
    ) async throws -> [Double] {
        let size = CGSize(width: 24, height: 24)
        let native = ImageView(tintColor: tint)
        let controller = UIViewController()
        controller.view = native
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.windowScene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        window.overrideUserInterfaceStyle = style
        window.rootViewController = controller
        window.makeKeyAndVisible()
        native.display(model: .init(size: size, image: .asset(image)))
        window.layoutIfNeeded()
        try await Task.sleep(nanoseconds: 400_000_000)
        let expected = snapshot(native, named: "\(name)_native")
        window.isHidden = true
        window.rootViewController = nil

        let adapter = ImageViewOutputSwiftUIAdapter()
        adapter.display(model: .init(size: size, image: .asset(image)))
        let hostSize = CGSize(width: 96, height: 96)
        let host = UIHostingController(rootView:
            SUIImageView(adapter: adapter)
                .accentColor(SwiftUI.Color(uiColor: tint))
                .environment(\.colorScheme, scheme)
                .frame(width: size.width, height: size.height)
                .frame(width: hostSize.width, height: hostSize.height)
        )
        host.safeAreaRegions = []
        let swiftUIWindow = UIWindow(frame: CGRect(origin: .zero, size: hostSize))
        swiftUIWindow.windowScene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        swiftUIWindow.overrideUserInterfaceStyle = style
        swiftUIWindow.rootViewController = host
        host.view.frame = swiftUIWindow.bounds
        swiftUIWindow.makeKeyAndVisible()
        defer { swiftUIWindow.isHidden = true; swiftUIWindow.rootViewController = nil }
        swiftUIWindow.layoutIfNeeded()
        try await Task.sleep(nanoseconds: 400_000_000)
        swiftUIWindow.layoutIfNeeded()
        XCTAssertEqual(host.view.bounds.size, hostSize)
        let actual = snapshot(host.view, named: "\(name)_swiftui")
        let expectedPixel = try centerPixel(expected)
        let actualPixel = try centerPixel(actual)
        for channel in 0..<4 {
            XCTAssertEqual(actualPixel[channel], expectedPixel[channel], accuracy: 3, name)
        }
        return expectedPixel
    }

    private func snapshot(_ view: UIView, named name: String) -> UIImage {
        let image = UIGraphicsImageRenderer(bounds: view.bounds).image { _ in
            XCTAssertTrue(view.drawHierarchy(in: view.bounds, afterScreenUpdates: true), name)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return image
    }

    private func centerPixel(_ image: UIImage) throws -> [Double] {
        let image = try XCTUnwrap(image.cgImage)
        var pixel = [UInt8](repeating: 0, count: 4)
        try pixel.withUnsafeMutableBytes { bytes in
            let context = try XCTUnwrap(CGContext(
                data: bytes.baseAddress, width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.translateBy(x: -CGFloat(image.width / 2), y: -CGFloat(image.height / 2))
            context.draw(image, in: .init(x: 0, y: 0, width: image.width, height: image.height))
        }
        return pixel.map(Double.init)
    }
}
#endif
