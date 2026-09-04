//
//  SUIImageViewSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils
import Kingfisher

final class SUIImageViewSnapshotTests: XCTestCase {
    private let light = ImageSnapshotFixture.light.urlString
    private let dark = ImageSnapshotFixture.dark.urlString

    override class func setUp() {
        super.setUp()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearCache()
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredCache()
        KingfisherManager.shared.cache.cleanExpiredMemoryCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }

    func test_imageView_defaultState() {
        let snapshotName = "IMAGE_VIEW_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

//        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image), completion: { _ in
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_defaultState() {
        let snapshotName = "IMAGE_VIEW_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

//        // WHEN
        let image = UIImage(systemName: "star.fill")
        sut.display(image: .asset(image), completion: { _ in
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // TODO: Re-enable the cached-image transition snapshots once that lifecycle can be driven
    // through the public paired API without mutating either renderer directly.

    func test_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assert(snapshot: sut, named: snapshotName, appearances: [.light])
    }

    func test_fail_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { [weak sut] _ in
            sut?.display(alpha: 0.5)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName, appearances: [.light])
    }

    func test_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let urlString = dark
        sut.display(image: .urlString(urlString, urlString)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assert(snapshot: sut, named: snapshotName, appearances: [.dark])
    }

    func test_fail_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let urlString = light
        sut.display(image: .urlString(urlString, urlString)) { [weak sut] _ in
            sut?.display(alpha: 0.5)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName, appearances: [.dark])
    }

    func test_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        // WHEN
        sut.display(image: .urlString(nil, nil))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark.circle")!
        // WHEN
        sut.display(image: .urlString(nil, nil))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let url = URL(string: light)!
        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assert(snapshot: sut, named: snapshotName, appearances: [.light])
    }

    func test_fail_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let url = URL(string: light)!
        sut.display(image: .url(url, url)) { [weak sut] _ in
            sut?.display(alpha: 0.5)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName, appearances: [.light])
    }

    func test_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!

        // WHEN
        sut.display(image: .url(nil, nil))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark.circle")!

        // WHEN
        sut.display(image: .url(nil, nil))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ImageView_viewWhileLoadingView() throws {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        let server = try HangingHTTPServer()
        defer { server.stop() }

        let sut = makeSUT()
        sut.configureLoadingView(color: .blue)

        // WHEN
        let url = server.url(path: "/image-view-loading.png")
        let requestStarted = expectation(description: "Loading request started")
        requestStarted.assertForOverFulfill = false
        server.observeStart { startedURL in
            guard startedURL == url else { return }
            requestStarted.fulfill()
        }
        sut.display(image: .url(url, url))
        defer { sut.display(image: nil) }
        wait(for: [requestStarted], timeout: 1)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ImageView_viewWhileLoadingView() throws {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        let server = try HangingHTTPServer()
        defer { server.stop() }

        let sut = makeSUT()
        sut.configureLoadingView(color: .red)

        // WHEN
        let url = server.url(path: "/image-view-loading-fail.png")
        let requestStarted = expectation(description: "Loading request started")
        requestStarted.assertForOverFulfill = false
        server.observeStart { startedURL in
            guard startedURL == url else { return }
            requestStarted.fulfill()
        }
        sut.display(image: .url(url, url))
        defer { sut.display(image: nil) }
        wait(for: [requestStarted], timeout: 1)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ImageView_fallbackView() {
        let snapshotName = "IMAGE_VIEW_FALLBACKVIEW"

        // GIVEN
        let sut = makeSUT()
        sut.configureFallbackView(color: .red)

        // WHEN
        let url = URL(string: "wrong url")!
        sut.display(image: .url(url, url))

        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ImageView_fallbackView() {
        let snapshotName = "IMAGE_VIEW_FALLBACKVIEW"

        // GIVEN
        let sut = makeSUT()
        sut.configureFallbackView(color: .systemRed)

        // WHEN
        let url = URL(string: "wrong url")!
        sut.display(image: .url(url, url))

        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let url = URL(string: dark)!

        sut.display(image: .url(url, url)) { image in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assert(snapshot: sut, named: snapshotName, appearances: [.dark])
    }

    func test_fail_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let url = URL(string: light)!

        sut.display(image: .url(url, url)) { [weak sut] _ in
            sut?.display(alpha: 0.5)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName, appearances: [.dark])
    }

    func test_imageView_contentMode_is_fit() {
        let snapshotName = "IMAGE_VIEW_FITCONTENTMODE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image))
        sut.display(contentModeIsFit: true)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_contentMode_is_fit() {
        let snapshotName = "IMAGE_VIEW_FITCONTENTMODE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        let image = UIImage(systemName: "star")
        sut.display(image: .asset(image))
        sut.display(contentModeIsFit: false)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(borderWidth: 2.0)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(borderWidth: 3.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_imageView_with_borderColor() {
        let snapshotName = "IMAGE_VIEW_BORDERCOLOR"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(borderColor: .red)
        sut.display(borderWidth: 2.0)
        sut.backgroundColor = .cyan

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_with_borderColor() {
        let snapshotName = "IMAGE_VIEW_BORDERCOLOR"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(borderColor: .systemRed)
        sut.display(borderWidth: 2.0)
        sut.backgroundColor = .cyan

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(cornerRadius: 50)
        sut.backgroundColor = .cyan

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(cornerRadius: 51)
        sut.backgroundColor = .cyan

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(alpha: 0.3)
        sut.backgroundColor = .cyan

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(alpha: 0.4)
        sut.backgroundColor = .cyan

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(isHidden: false)
        sut.backgroundColor = .cyan

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(isHidden: true)
        sut.backgroundColor = .cyan

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    //MARK: - touches simulation


    // MARK: - Completion calling directly
    func test_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for animation completion")

        // WHEN
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .red
            exp.fulfill()
        })

        sut.onPress?()

        wait(for: [exp], timeout: 1.0)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for animation completion")

        // WHEN
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .systemRed
            exp.fulfill()
        })

        sut.onPress?()

        wait(for: [exp], timeout: 1.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for onLongPress")

        // WHEN
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .systemYellow
            exp.fulfill()
        })

        sut.onLongPress?()

        wait(for: [exp], timeout: 1.0)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for onLongPress")

        // WHEN
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .yellow
            exp.fulfill()
        })

        sut.onLongPress?()

        wait(for: [exp], timeout: 1.0)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

}

private extension SUIImageViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUIImageViewSnapshotSUT {
        let sut = SwiftUIImageViewSnapshotSUT()
        checkForMemoryLeaks(sut.uiKitImageView, file: file, line: line)
        return sut
    }
}
