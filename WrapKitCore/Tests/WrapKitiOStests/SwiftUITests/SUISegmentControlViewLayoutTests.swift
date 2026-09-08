#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
final class SUISegmentControlViewLayoutTests: XCTestCase {
    @available(iOS 26.0, *)
    func test_nativeLabelsRenderInsideEveryEqualWidthSegment() {
        let width: CGFloat = 390
        let adapter = SegmentedControlOutputSwiftUIAdapter()
        let appearance = SegmentedControlAppearance(
            colors: .init(
                textColor: .systemRed,
                backgroundColor: .systemGray5,
                selectedBackgroundColor: .white
            ),
            font: .systemFont(ofSize: 18, weight: .semibold),
            cornerRadius: 10
        )
        adapter.display(segments: [
            .init(title: "One", index: 0),
            .init(title: "Two", index: 1),
            .init(title: "Three", index: 2)
        ])
        let host = SegmentedControlRenderHost(
            rootView: SUISegmentControlView(
                adapter: adapter,
                appearance: appearance
            )
            .frame(width: width, height: 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(),
            size: CGSize(width: width, height: 140)
        )

        let redPixelCounts = host.renderedImage().rgbaPixels
            .dominantRedPixelCounts(pixelWidth: Int(width), columnCount: 3)

        XCTAssertEqual(redPixelCounts.count, 3)
        redPixelCounts.enumerated().forEach { index, pixelCount in
            XCTAssertGreaterThan(
                pixelCount,
                10,
                "Expected visible label pixels inside segment \(index)"
            )
        }
    }
}

@MainActor
private final class SegmentedControlRenderHost {
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow

    init(rootView: some View, size: CGSize) {
        hostingController = UIHostingController(rootView: AnyView(rootView))
        window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.backgroundColor = .clear
        window.rootViewController = hostingController
        hostingController.view.frame = window.bounds
        hostingController.view.backgroundColor = .clear
        window.makeKeyAndVisible()
        settle()
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

    private func settle() {
        window.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }
}

private extension Array where Element == UInt8 {
    func dominantRedPixelCounts(pixelWidth: Int, columnCount: Int) -> [Int] {
        guard pixelWidth > 0, columnCount > 0 else { return [] }
        var counts = [Int](repeating: 0, count: columnCount)

        for index in stride(from: 0, to: count, by: 4) {
            let red = self[index]
            let green = self[index + 1]
            let blue = self[index + 2]
            let alpha = self[index + 3]
            guard alpha > 32,
                  Int(red) > Int(green) + 40,
                  Int(red) > Int(blue) + 40 else {
                continue
            }

            let pixelX = (index / 4) % pixelWidth
            let column = Swift.min(pixelX * columnCount / pixelWidth, columnCount - 1)
            counts[column] += 1
        }

        return counts
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
