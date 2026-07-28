//
//  ImageViewCancelDownloadTests.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 16/12/25.
//

@testable import WrapKit
import XCTest
import WrapKitTestUtils

private enum ImageViewTestLink: String {
    case first = "/image-1.png"
    case second = "/image-2.png"
}

final class ImageViewCancelDownloadTests: XCTestCase {
    private var server: HangingHTTPServer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        server = try HangingHTTPServer()
    }

    override func tearDownWithError() throws {
        server.stop()
        server = nil
        try super.tearDownWithError()
    }

    func test_imageView_setImageToNil_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut.display(image: nil)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.currentImageEnum)
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
    }

    func test_imageView_setImagePropertyToNil_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut.image = nil

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
    }

    func test_imageView_setImageEnumToNone_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut.display(image: .none)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.currentImageEnum)
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
    }

    func test_imageView_setImageToNil_cancelsCurrentAnimation() {
        // GIVEN
        let sut = makeSUT()
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image))
        XCTAssertNotNil(sut.currentAnimator)

        // WHEN
        sut.display(image: nil)

        // THEN
        XCTAssertNil(sut.currentAnimator)
        XCTAssertNil(sut.currentImageEnum)
    }

    func test_imageView_switchingImages_cancelsPreviousDownload() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)
        let secondStartExpectation = expectRequestStart(for: secondURL)

        // WHEN
        sut.display(image: .url(secondURL, secondURL))

        // THEN
        wait(for: [stopExpectation, secondStartExpectation], timeout: 1.0)
        XCTAssertEqual(server.startedURLs, [
            firstURL,
            secondURL
        ])
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
        sut.display(image: nil)
    }

    func test_imageView_setImageToNil_callsCompletionWithNil() {
        // GIVEN
        let sut = makeSUT()
        let expectation = expectation(description: "Completion called")
        var receivedImage: Image?

        // WHEN
        sut.display(image: nil) { image in
            receivedImage = image
            expectation.fulfill()
        }

        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(receivedImage)
    }

    func test_imageView_setNilUrlString_clearsImage() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut.display(image: .urlString(nil, nil))

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
    }

    func test_imageView_cancelDownload_doesNotLeakMemory() {
        // GIVEN
        var sut: ImageView? = makeSUT()
        weak var weakSUT = sut
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut?.display(image: nil)
        wait(for: [stopExpectation], timeout: 1.0)
        sut = nil

        // THEN
        XCTAssertNil(weakSUT)
    }

    func test_imageView_cancelDownload_hidesLoadingView() {
        // GIVEN
        let sut = makeSUT()
        sut.viewWhileLoadingView = ViewUIKit()
        startLoading(firstURL, in: sut)
        XCTAssertEqual(sut.viewWhileLoadingView?.isHidden, false)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut.display(image: nil)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertEqual(sut.viewWhileLoadingView?.isHidden, true)
    }

    func test_imageView_setAssetImage_doesNotCreateDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        let image = UIImage(systemName: "star")

        // WHEN
        sut.display(image: .asset(image))

        // THEN
        XCTAssertTrue(server.startedURLs.isEmpty)
        XCTAssertNotNil(sut.image)
    }

    func test_imageView_displayModelWithNilImage_clearsImage() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)
        let model = ImageViewPresentableModel(image: nil)

        // WHEN
        sut.display(model: model)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.currentImageEnum)
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
    }

    func test_imageView_imagePropertySetter_cancelsDownloadWhenSetToNil() {
        // GIVEN
        let sut = makeSUT()
        startLoading(firstURL, in: sut)
        let stopExpectation = expectRequestStop(for: firstURL)

        // WHEN
        sut.image = nil

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertEqual(server.disconnectedURLs, [firstURL])
    }
}

private extension ImageViewCancelDownloadTests {
    var firstURL: URL {
        server.url(path: ImageViewTestLink.first.rawValue)
    }

    var secondURL: URL {
        server.url(path: ImageViewTestLink.second.rawValue)
    }

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> ImageView {
        let sut = ImageView()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func startLoading(_ url: URL, in sut: ImageView?) {
        let startExpectation = expectRequestStart(for: url)
        sut?.display(image: .url(url, url))
        wait(for: [startExpectation], timeout: 1.0)
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
}
