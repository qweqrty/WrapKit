#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import UIKit
import XCTest

@MainActor
@available(iOS 17.0, *)
final class SUIImageViewParityTests: XCTestCase {
    func test_distinctRemoteURLsFollowColorSchemeChanges() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let lightURL = server.url(path: "/image-light.png")
        let darkURL = server.url(path: "/image-dark.png")
        let lightRequest = expectation(description: "Light URL requested")
        let darkRequest = expectation(description: "Dark URL requested")
        server.observeStart { url in
            if url == lightURL {
                lightRequest.fulfill()
            } else if url == darkURL {
                darkRequest.fulfill()
            }
        }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let appearance = ImageAppearanceFixture(.light)
        let host = SwiftUIAccessibilityTestHost(
            rootView: ImageAppearanceHarness(adapter: adapter, appearance: appearance),
            size: CGSize(width: 160, height: 100)
        )

        adapter.display(image: .url(lightURL, darkURL))
        wait(for: [lightRequest], timeout: 1)

        appearance.colorScheme = .dark
        host.settle()
        wait(for: [darkRequest], timeout: 1)
    }

    func test_lightOnlyURLDoesNotFallbackInDarkAppearance() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let request = expectation(description: "No URL requested")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter)
                .environment(\.colorScheme, .dark),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Missing dark URL completed")
        adapter.display(image: .url(server.url(path: "/light-only.png"), nil)) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion, request], timeout: 0.3)
    }

    func test_lightOnlyURLStringDoesNotFallbackInDarkAppearance() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let request = expectation(description: "No URL requested")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter)
                .environment(\.colorScheme, .dark),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Missing dark URL string completed")
        adapter.display(
            image: .urlString(server.url(path: "/light-only-string.png").absoluteString, nil)
        ) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion, request], timeout: 0.3)
    }

    func test_darkOnlyURLDoesNotFallbackInLightAppearance() throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let request = expectation(description: "No URL requested")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter)
                .environment(\.colorScheme, .light),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Missing light URL completed")
        adapter.display(image: .url(nil, server.url(path: "/dark-only.png"))) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion, request], timeout: 0.3)
    }

    func test_validDataDecodesAndCompletesWithImage() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter),
            size: CGSize(width: 160, height: 100)
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let data = UIGraphicsImageRenderer(
            size: CGSize(width: 3, height: 2),
            format: format
        ).pngData { context in
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 3, height: 2))
        }
        let completion = expectation(description: "Valid data decoded")

        adapter.display(image: .data(data)) { image in
            XCTAssertEqual(image?.size, CGSize(width: 3, height: 2))
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion], timeout: 1)
    }

    func test_invalidDataClearsImageWithoutFallback() {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(
                adapter: adapter,
                fallbackView: AnyView(SwiftUI.Color.red)
            ),
            size: CGSize(width: 160, height: 100)
        )
        let completion = expectation(description: "Invalid data completed")

        adapter.display(image: .data(Data("not an image".utf8))) { image in
            XCTAssertNil(image)
            completion.fulfill()
        }

        host.settle()
        wait(for: [completion], timeout: 1)
    }
}

@MainActor
private final class ImageAppearanceFixture: ObservableObject {
    @Published var colorScheme: ColorScheme

    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
}

private struct ImageAppearanceHarness: View {
    let adapter: ImageViewOutputSwiftUIAdapter
    @ObservedObject var appearance: ImageAppearanceFixture

    var body: some View {
        SUIImageView(adapter: adapter)
            .environment(\.colorScheme, appearance.colorScheme)
    }
}
#endif
