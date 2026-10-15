#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
final class SUIImageExternalFrameLayoutTests: XCTestCase {
    func test_imageWithoutModelSize_keepsBorderInsideExternalViewportAndFadesItWithImage() throws {
        let data = try XCTUnwrap(UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600)).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 600))
        }.pngData())
        let adapter = ImageViewOutputSwiftUIAdapter()
        adapter.display(image: .data(data))
        adapter.display(contentModeIsFit: false)
        let host = UIHostingController(rootView:
            SUIImageView(adapter: adapter)
                .frame(width: 354, height: 100)
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(15)
                .ignoresSafeArea()
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 384, height: 130))
        window.backgroundColor = .white
        window.rootViewController = host
        host.view.backgroundColor = .white
        host.view.frame = window.bounds
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        settle(window: window, host: host)

        adapter.display(borderColor: .magenta)
        adapter.display(borderWidth: 5)
        let bordered = render(window: window, host: host)
        attach(bordered, name: "Externally constrained image border")
        let full = try pixel(in: bordered, x: 192, y: 17)
        XCTAssertGreaterThan(full.red, 240)
        XCTAssertGreaterThan(full.blue, 240)
        XCTAssertLessThan(full.green, 20, "The border must be drawn at the 100pt viewport edge")

        adapter.display(alpha: 0.5)
        let translucent = render(window: window, host: host)
        attach(translucent, name: "Externally constrained image border alpha")
        let faded = try pixel(in: translucent, x: 192, y: 17)
        XCTAssertGreaterThan(faded.red, 240)
        XCTAssertGreaterThan(faded.blue, 240)
        XCTAssertEqual(Double(faded.green), 128, accuracy: 12, "Border and image must share one opacity")
    }

    private func settle(window: UIWindow, host: UIViewController) {
        window.layoutIfNeeded()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    private func render(window: UIWindow, host: UIViewController) -> UIImage {
        settle(window: window, host: host)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(bounds: host.view.bounds, format: format).image { _ in
            host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
        }
    }

    private func attach(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func pixel(in image: UIImage, x: Int, y: Int) throws -> (red: UInt8, green: UInt8, blue: UInt8) {
        let image = try XCTUnwrap(image.cgImage)
        var bytes = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let context = try XCTUnwrap(CGContext(
            data: &bytes,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let offset = (y * image.width + x) * 4
        return (bytes[offset], bytes[offset + 1], bytes[offset + 2])
    }
}
#endif
