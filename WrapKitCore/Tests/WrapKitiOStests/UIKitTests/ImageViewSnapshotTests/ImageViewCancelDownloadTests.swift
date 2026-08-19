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
    case first = "https://wrapkit.test/image-1.png"
    case second = "https://wrapkit.test/image-2.png"

    var url: URL {
        URL(string: rawValue)!
    }
}

private final class ImageViewURLProtocolStub: URLProtocol {
    private static let lock = NSLock()
    private static var _startedURLs: [URL] = []
    private static var _stoppedURLs: [URL] = []
    private static var onStart: ((URL) -> Void)?
    private static var onStop: ((URL) -> Void)?

    static var startedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return _startedURLs
    }

    static var stoppedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return _stoppedURLs
    }

    static func reset() {
        lock.lock()
        _startedURLs = []
        _stoppedURLs = []
        onStart = nil
        onStop = nil
        lock.unlock()
    }

    static func observeStart(_ observer: @escaping (URL) -> Void) {
        lock.lock()
        onStart = observer
        lock.unlock()
    }

    static func observeStop(_ observer: @escaping (URL) -> Void) {
        lock.lock()
        onStop = observer
        lock.unlock()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        ImageViewTestLink(rawValue: request.url?.absoluteString ?? "") != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else { return }

        let observer: ((URL) -> Void)?
        Self.lock.lock()
        Self._startedURLs.append(url)
        observer = Self.onStart
        Self.lock.unlock()

        observer?(url)
    }

    override func stopLoading() {
        guard let url = request.url else { return }

        let observer: ((URL) -> Void)?
        Self.lock.lock()
        Self._stoppedURLs.append(url)
        observer = Self.onStop
        Self.lock.unlock()

        observer?(url)
    }
}

final class ImageViewCancelDownloadTests: XCTestCase {
    override func setUp() {
        super.setUp()

        ImageViewURLProtocolStub.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageViewURLProtocolStub.self]
        ImageView.imageLoadingSessionConfigurationOverride = configuration
    }

    override func tearDown() {
        ImageView.resetImageLoadingSessionConfigurationOverride()
        ImageViewURLProtocolStub.reset()

        super.tearDown()
    }

    func test_imageView_setImageToNil_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

        // WHEN
        sut.display(image: nil)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.currentImageEnum)
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
    }

    func test_imageView_setImagePropertyToNil_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

        // WHEN
        sut.image = nil

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
    }

    func test_imageView_setImageEnumToNone_cancelsDownloadTask() {
        // GIVEN
        let sut = makeSUT()
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

        // WHEN
        sut.display(image: .none)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.currentImageEnum)
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
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
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)
        let secondStartExpectation = expectRequestStart(for: ImageViewTestLink.second.url)

        // WHEN
        sut.display(image: .url(ImageViewTestLink.second.url, ImageViewTestLink.second.url))

        // THEN
        wait(for: [stopExpectation, secondStartExpectation], timeout: 1.0)
        XCTAssertEqual(ImageViewURLProtocolStub.startedURLs, [
            ImageViewTestLink.first.url,
            ImageViewTestLink.second.url
        ])
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
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
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

        // WHEN
        sut.display(image: .urlString(nil, nil))

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
    }

    func test_imageView_cancelDownload_doesNotLeakMemory() {
        // GIVEN
        var sut: ImageView? = makeSUT()
        weak var weakSUT = sut
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

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
        startLoading(ImageViewTestLink.first.url, in: sut)
        XCTAssertEqual(sut.viewWhileLoadingView?.isHidden, false)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

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
        XCTAssertTrue(ImageViewURLProtocolStub.startedURLs.isEmpty)
        XCTAssertNotNil(sut.image)
    }

    func test_imageView_displayModelWithNilImage_clearsImage() {
        // GIVEN
        let sut = makeSUT()
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)
        let model = ImageViewPresentableModel(image: nil)

        // WHEN
        sut.display(model: model)

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.currentImageEnum)
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
    }

    func test_imageView_imagePropertySetter_cancelsDownloadWhenSetToNil() {
        // GIVEN
        let sut = makeSUT()
        startLoading(ImageViewTestLink.first.url, in: sut)
        let stopExpectation = expectRequestStop(for: ImageViewTestLink.first.url)

        // WHEN
        sut.image = nil

        // THEN
        wait(for: [stopExpectation], timeout: 1.0)
        XCTAssertNil(sut.image)
        XCTAssertEqual(ImageViewURLProtocolStub.stoppedURLs, [ImageViewTestLink.first.url])
    }
}

private extension ImageViewCancelDownloadTests {
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

        ImageViewURLProtocolStub.observeStart { startedURL in
            guard startedURL == url else { return }
            expectation.fulfill()
        }

        return expectation
    }

    func expectRequestStop(for url: URL) -> XCTestExpectation {
        let expectation = expectation(description: "Request stopped: \(url.absoluteString)")
        expectation.assertForOverFulfill = false

        ImageViewURLProtocolStub.observeStop { stoppedURL in
            guard stoppedURL == url else { return }
            expectation.fulfill()
        }

        return expectation
    }
}
