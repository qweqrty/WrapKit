#if canImport(SwiftUI) && canImport(UIKit)
import Kingfisher
import SwiftUI
import UIKit
import WrapKit
import XCTest

@MainActor
@available(iOS 17.0, *)
final class SUIImageViewCacheTests: XCTestCase {
    func test_displaySameURLAfterClearingCache_requestsImageAgain() async throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let url = server.url(path: "/\(UUID().uuidString).png")
        let image = makeImage()
        await store(image, for: url)
        let (adapter, host) = makeSUT()
        await assertCachedImage(image, at: url, adapter: adapter, host: host)

        await clearCache(for: url)

        await assertRequestsFreshImage(at: url, server: server) { completion in
            adapter.display(image: .url(url, url), completion: completion)
            host.settle()
        }
        await stopLoading(adapter: adapter, host: host)
    }

    func test_newMountAfterClearingCache_doesNotReusePreviouslyLoadedImage() async throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let url = server.url(path: "/\(UUID().uuidString).png")
        let image = makeImage()
        await store(image, for: url)
        do {
            let (adapter, host) = makeSUT()
            await assertCachedImage(image, at: url, adapter: adapter, host: host)
            await stopLoading(adapter: adapter, host: host)
        }

        await clearCache(for: url)

        let (adapter, host) = makeSUT()
        await assertRequestsFreshImage(at: url, server: server) { completion in
            adapter.display(image: .url(url, url), completion: completion)
            host.settle()
        }
        await stopLoading(adapter: adapter, host: host)
    }

    func test_repeatedDisplayAndNewMountWithoutClearingCache_doNotRequestImageAgain() async throws {
        let server = try HangingHTTPServer()
        defer { server.stop() }
        let url = server.url(path: "/\(UUID().uuidString).png")
        let image = makeImage()
        await store(image, for: url)
        let request = expectation(description: "Cached image does not need a network request")
        request.isInverted = true
        server.observeStart { _ in request.fulfill() }

        do {
            let (adapter, host) = makeSUT()
            await assertCachedImage(image, at: url, adapter: adapter, host: host)
            await assertCachedImage(image, at: url, adapter: adapter, host: host)
            await stopLoading(adapter: adapter, host: host)
        }
        let (adapter, host) = makeSUT()
        await assertCachedImage(image, at: url, adapter: adapter, host: host)

        await fulfillment(of: [request], timeout: 0.3)
        XCTAssertEqual(server.startedURLs, [])
        await stopLoading(adapter: adapter, host: host)
        await clearCache(for: url)
    }

    private func makeSUT() -> (ImageViewOutputSwiftUIAdapter, SwiftUIAccessibilityTestHost) {
        let adapter = ImageViewOutputSwiftUIAdapter()
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter).environment(\.colorScheme, .light),
            size: CGSize(width: 160, height: 100)
        )
        return (adapter, host)
    }

    private func assertCachedImage(
        _ expected: UIImage,
        at url: URL,
        adapter: ImageViewOutputSwiftUIAdapter,
        host: SwiftUIAccessibilityTestHost,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let loaded = expectation(description: "Mounted image completes with the cached image")
        adapter.display(image: .url(url, url)) { image in
            XCTAssertEqual(image?.pngData(), expected.pngData(), file: file, line: line)
            loaded.fulfill()
        }
        host.settle()
        await fulfillment(of: [loaded], timeout: 1)
    }

    private func assertRequestsFreshImage(
        at url: URL,
        server: HangingHTTPServer,
        file: StaticString = #filePath,
        line: UInt = #line,
        display: (@escaping (UIImage?) -> Void) -> Void
    ) async {
        let requested = expectation(description: "Cleared image cache requires a new HTTP request")
        let staleCompletion = expectation(description: "Old successful image is not reused after cache clearing")
        staleCompletion.isInverted = true
        server.observeStart { requestedURL in
            guard requestedURL == url else { return }
            requested.fulfill()
        }

        // This server intentionally leaves the response pending. A successful completion
        // before it responds can only have come from an incorrectly retained image.
        display { image in
            if image != nil { staleCompletion.fulfill() }
        }

        await fulfillment(of: [requested, staleCompletion], timeout: 1)
        XCTAssertEqual(server.startedURLs, [url], file: file, line: line)
    }

    private func stopLoading(adapter: ImageViewOutputSwiftUIAdapter, host: SwiftUIAccessibilityTestHost) async {
        // Wait until the mounted view consumes the nil output before hiding its window
        // or clearing shared caches. Otherwise a queued render may start a late request.
        let stopped = expectation(description: "Mounted image stops loading before unmount")
        adapter.display(image: nil) { image in
            XCTAssertNil(image)
            stopped.fulfill()
        }
        host.settle()
        await fulfillment(of: [stopped], timeout: 1)
    }

    private func store(_ image: UIImage, for url: URL) async {
        let stored = expectation(description: "Image is cached in memory and on disk")
        KingfisherManager.shared.cache.store(
            image,
            forKey: url.absoluteString,
            callbackQueue: .mainCurrentOrAsync
        ) { result in
            if case .failure(let error) = result.diskCacheResult {
                XCTFail("Could not prepare image cache: \(error)")
            }
            stored.fulfill()
        }
        await fulfillment(of: [stored], timeout: 1)
        XCTAssertTrue(KingfisherManager.shared.cache.isCached(forKey: url.absoluteString))
    }

    private func clearCache(for url: URL) async {
        let cleared = expectation(description: "Kingfisher memory and disk caches are cleared")
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        cache.clearDiskCache { cleared.fulfill() }
        await fulfillment(of: [cleared], timeout: 1)
        XCTAssertFalse(cache.isCached(forKey: url.absoluteString))
    }

    private func makeImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 3, height: 2), format: format).image { context in
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 3, height: 2))
        }
    }
}
#endif
