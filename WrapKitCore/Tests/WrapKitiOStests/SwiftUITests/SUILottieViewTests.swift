#if canImport(SwiftUI) && canImport(UIKit)
import Combine
import Lottie
import SwiftUI
import UIKit
import WrapKit
import XCTest

@MainActor
final class SUILottieViewTests: XCTestCase {
    private var server: HangingHTTPServer!

    override func tearDownWithError() throws {
        server?.stop()
        server = nil
        try super.tearDownWithError()
    }

    func test_adapter_preservesDisplayModelAndCurrentAnimationName() {
        let adapter = LottieViewOutputSwiftUIAdapter()
        let model = makeLocalModel(animationSpeed: 1.75, loopMode: .loop)

        adapter.display(model: model)
        adapter.currentAnimationName = model.fileName

        XCTAssertEqual(adapter.displayModelState?.model, model)
        XCTAssertEqual(adapter.currentAnimationName, model.fileName)
    }

    func test_localAsset_rendersPixelsAndReplaysSameModel() {
        let adapter = LottieViewOutputSwiftUIAdapter()
        let host = SUILottieTestHost(rootView: SUILottieView(adapter: adapter))
        let model = makeLocalModel(animationSpeed: 1.75, loopMode: .loop)
        let emptyRendering = host.renderedPixels()

        adapter.display(model: model)

        XCTAssertTrue(
            waitUntil { adapter.currentAnimationName == model.fileName },
            "Local Lottie asset is not loaded"
        )
        XCTAssertTrue(
            waitUntil {
                let renderedPixels = host.renderedPixels()
                return renderedPixels != emptyRendering && renderedPixels.containsFixtureColorPixel
            },
            "Lottie produced no fixture-colored pixels. View tree: \(host.viewTreeTypeNames.joined(separator: ", "))"
        )

        let replayed = expectation(description: "Same model is loaded again")
        var cancellable: AnyCancellable?
        cancellable = adapter.$currentAnimationName
            .dropFirst()
            .filter { $0 == model.fileName }
            .sink { _ in replayed.fulfill() }

        adapter.display(model: model)

        wait(for: [replayed], timeout: 1)
        withExtendedLifetime(cancellable) {}
    }

    func test_remoteDisplay_cancelsPreviousRequestAndKeepsLatestName() throws {
        server = try HangingHTTPServer()
        let adapter = LottieViewOutputSwiftUIAdapter()
        let host = SUILottieTestHost(rootView: SUILottieView(adapter: adapter))
        let firstURL = server.url(path: "/first.json")
        let secondURL = server.url(path: "/second.json")
        let firstStarted = expectRequestStart(for: firstURL)

        adapter.display(model: makeRemoteModel(url: firstURL))
        wait(for: [firstStarted], timeout: 1)

        let firstStopped = expectRequestStop(for: firstURL)
        let secondStarted = expectRequestStart(for: secondURL)
        adapter.display(model: makeRemoteModel(url: secondURL))

        wait(for: [firstStopped, secondStarted], timeout: 1)
        XCTAssertEqual(adapter.currentAnimationName, secondURL.absoluteString)
        XCTAssertEqual(server.startedURLs, [firstURL, secondURL])
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
        withExtendedLifetime(host) {}
    }
}

private extension SUILottieViewTests {
    func makeLocalModel(
        animationSpeed: CGFloat = 1.2,
        loopMode: LottieLoopMode = .playOnce
    ) -> LottieViewPresentableModel {
        .init(
            fileName: "WrapKitTestAnimation",
            animationSpeed: animationSpeed,
            loopMode: loopMode,
            bundle: LottieTestFixture.bundle
        )
    }

    func makeRemoteModel(url: URL) -> LottieViewPresentableModel {
        .init(url: url, animationSpeed: 1.2, loopMode: .loop)
    }

    func expectRequestStart(for url: URL) -> XCTestExpectation {
        let expectation = expectation(description: "Request started: \(url.absoluteString)")
        expectation.assertForOverFulfill = false
        server.observeStart { startedURL in
            guard startedURL == url else { return }
            expectation.fulfill()
        }
        return expectation
    }

    func expectRequestStop(for url: URL) -> XCTestExpectation {
        let expectation = expectation(description: "Request stopped: \(url.absoluteString)")
        expectation.assertForOverFulfill = false
        server.observeDisconnect { disconnectedURL in
            guard disconnectedURL == url else { return }
            expectation.fulfill()
        }
        return expectation
    }

    func waitUntil(timeout: TimeInterval = 1, condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() {
                return true
            }
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        return condition()
    }
}

@MainActor
private final class SUILottieTestHost {
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow

    init(rootView: some View) {
        hostingController = UIHostingController(rootView: AnyView(rootView))
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
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

    var viewTreeTypeNames: [String] {
        flattenedViews(from: hostingController.view).map { String(reflecting: type(of: $0)) }
    }

    func renderedPixels() -> [UInt8] {
        settle()
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let image = UIGraphicsImageRenderer(bounds: hostingController.view.bounds, format: format).image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        return image.rgbaPixels
    }

    private func settle() {
        window.layoutIfNeeded()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }

    private func flattenedViews(from view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap { flattenedViews(from: $0) }
    }
}

private extension Array where Element == UInt8 {
    var containsFixtureColorPixel: Bool {
        stride(from: 0, to: count, by: 4).contains { index in
            let red = self[index]
            let green = self[index + 1]
            let blue = self[index + 2]
            let alpha = self[index + 3]
            return alpha > 32
                && Int(blue) > Int(green) + 20
                && Int(blue) > Int(red) + 20
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

private enum LottieTestFixture {
    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        Bundle.module
        #else
        Bundle(for: BundleToken.self)
        #endif
    }

    private final class BundleToken {}
}
#endif
