//
//  SUIImageViewSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import SwiftUI
import UIKit
import XCTest
import WrapKitTestUtils
import Kingfisher

@available(iOS 17.0, *)
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

    func test_publicImageView_exposesConfiguredAccessibilityActions() throws {
        let adapter = ImageViewOutputSwiftUIAdapter()
        var pressCount = 0
        var longPressCount = 0
        adapter.display(model: .systemSymbol(
            "star.fill",
            accessibilityIdentifier: "image.action",
            accessibility: .init(label: "Action image", hint: "Runs image action"),
            size: CGSize(width: 44, height: 44),
            onPress: { pressCount += 1 },
            onLongPress: { longPressCount += 1 }
        ))

        let host = SwiftUIAccessibilityTestHost(
            rootView: SUIImageView(adapter: adapter),
            size: CGSize(width: 100, height: 100)
        )
        host.settle()

        let image = try XCTUnwrap(host.element(withLabel: "Action image"))
        XCTAssertEqual(image.accessibilityHint, "Runs image action")
        XCTAssertTrue(image.accessibilityActivate())
        XCTAssertEqual(pressCount, 1)

        let longPress = try XCTUnwrap(
            image.accessibilityCustomActions?.first { $0.name == "Long press" }
        )
        XCTAssertTrue(host.perform(longPress))
        XCTAssertEqual(longPressCount, 1)
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"

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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"

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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!
        // WHEN
        sut.display(image: .urlString(nil, nil))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark.circle")!
        // WHEN
        sut.display(image: .urlString(nil, nil))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let url = URL(string: dark)!
        sut.display(image: .url(url, url)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")!

        // WHEN
        sut.display(image: .url(nil, nil))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"

        // GIVEN
        let sut = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark.circle")!

        // WHEN
        sut.display(image: .url(nil, nil))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_viewWhileLoadingView() throws {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        let server = try HangingHTTPServer()
        defer { server.stop() }

        let sut = makeSUT()
        sut.configureLoadingView(color: .red)

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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"

        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        // WHEN
        let url = URL(string: light)!

        sut.display(image: .url(url, url)) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(borderWidth: 2.0)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(borderWidth: 3.0)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
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
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
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
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(cornerRadius: 50)
        sut.backgroundColor = .cyan

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(cornerRadius: 51)
        sut.backgroundColor = .cyan

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(alpha: 0.3)
        sut.backgroundColor = .cyan

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(alpha: 0.4)
        sut.backgroundColor = .cyan

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(isHidden: false)
        sut.backgroundColor = .cyan

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(isHidden: true)
        sut.backgroundColor = .cyan

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    // MARK: - Interactive appearance

    func test_imageView_onPress_releasedVisualState() {
        let releasedSnapshotName = "IMAGE_VIEW_ONPRESS_RELEASED"

        // GIVEN
        let sut = makeSUT()
        let imageLoaded = expectation(description: "Image loaded")

        // WHEN
        sut.display(alpha: 0.3)
        sut.display(onPress: {})
        let image = UIImage(systemName: "star.fill")
        sut.display(image: .asset(image)) { _ in imageLoaded.fulfill() }

        wait(for: [imageLoaded], timeout: 1)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(releasedSnapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(releasedSnapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(releasedSnapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(releasedSnapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_onPress_releasedVisualState() {
        let releasedSnapshotName = "IMAGE_VIEW_ONPRESS_RELEASED"

        // GIVEN
        let sut = makeSUT()
        let imageLoaded = expectation(description: "Mutation image loaded")

        // WHEN
        sut.display(alpha: 0.4)
        sut.display(onPress: {})
        let image = UIImage(systemName: "star.fill")
        sut.display(image: .asset(image)) { _ in imageLoaded.fulfill() }

        wait(for: [imageLoaded], timeout: 1)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(releasedSnapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(releasedSnapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(releasedSnapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(releasedSnapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    // MARK: - Completion calling directly
    func test_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let imageLoaded = expectation(description: "Image loaded")

        // WHEN
        sut.display(image: .asset(UIImage(systemName: "star.fill"))) { _ in
            imageLoaded.fulfill()
        }
        wait(for: [imageLoaded], timeout: 1.0)
        var pressCount = 0
        let onPress: () -> Void = { [weak sut] in
            pressCount += 1
            sut?.display(alpha: 0.3)
        }
        sut.display(onPress: onPress)
        onPress()
        XCTAssertEqual(pressCount, 1)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let imageLoaded = expectation(description: "Image loaded")

        // WHEN
        sut.display(image: .asset(UIImage(systemName: "star.fill"))) { _ in
            imageLoaded.fulfill()
        }
        wait(for: [imageLoaded], timeout: 1.0)
        var pressCount = 0
        let onPress: () -> Void = { [weak sut] in
            pressCount += 1
            sut?.display(alpha: 0.4)
        }
        sut.display(onPress: onPress)
        onPress()
        XCTAssertEqual(pressCount, 1)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let initialImageLoaded = expectation(description: "Initial image loaded")
        let finalImageLoaded = expectation(description: "Final image loaded")

        // WHEN
        sut.display(image: .asset(UIImage(systemName: "star.fill"))) { _ in
            initialImageLoaded.fulfill()
        }
        wait(for: [initialImageLoaded], timeout: 1.0)
        var longPressCount = 0
        let onLongPress: () -> Void = { [weak sut] in
            longPressCount += 1
            sut?.display(image: .asset(UIImage(systemName: "heart.fill"))) { _ in
                finalImageLoaded.fulfill()
            }
        }
        sut.display(onLongPress: onLongPress)
        onLongPress()
        wait(for: [finalImageLoaded], timeout: 1.0)
        XCTAssertEqual(longPressCount, 1)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"

        // GIVEN
        let sut = makeSUT()
        let initialImageLoaded = expectation(description: "Initial image loaded")
        let finalImageLoaded = expectation(description: "Final image loaded")

        // WHEN
        sut.display(image: .asset(UIImage(systemName: "star.fill"))) { _ in
            initialImageLoaded.fulfill()
        }
        wait(for: [initialImageLoaded], timeout: 1.0)
        var longPressCount = 0
        let onLongPress: () -> Void = { [weak sut] in
            longPressCount += 1
            sut?.display(image: .asset(UIImage(systemName: "circle.fill"))) { _ in
                finalImageLoaded.fulfill()
            }
        }
        sut.display(onLongPress: onLongPress)
        onLongPress()
        wait(for: [finalImageLoaded], timeout: 1.0)
        XCTAssertEqual(longPressCount, 1)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

}

@available(iOS 17.0, *)
private extension SUIImageViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUIImageViewSnapshotSUT {
        let sut = SwiftUIImageViewSnapshotSUT()
        checkForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
