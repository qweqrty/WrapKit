import WrapKit
import XCTest
import WrapKitTestUtils
import Kingfisher
import SwiftUI

@available(iOS 17, *)
final class SUIImageViewSnapshotTests: XCTestCase {
    private let light = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
    private let dark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"

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
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(image: ImageEnum.asset(UIImage(systemName: "star"))) { _ in
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 1.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }

        sut.display(image: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    func test_fail_imageView_defaultState() {
        let snapshotName = "IMAGE_VIEW_DEFAULT_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(image: ImageEnum.asset(UIImage(systemName: "star.fill"))) { _ in
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 1.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }

    }

    func test_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(image: ImageEnum.urlString(light, light)) { _ in
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_ImageView_from_urlString_light() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_LIGHT"
        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for completion")

        sut.display(image: ImageEnum.urlString(light, light)) { _ in
            backgroundState.color = SwiftUIColor.red
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(image: ImageEnum.urlString(dark, dark)) { _ in
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_ImageView_from_urlString_dark() {
        let snapshotName = "IMAGE_VIEW_URLSTRING_DARK"
        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for completion")

        sut.display(image: ImageEnum.urlString(light, light)) { _ in
            backgroundState.color = SwiftUIColor.red
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"
        let (sut, container) = makeSUT(wrongUrlPlaceholderImage: UIImage(systemName: "xmark"))

        sut.display(image: ImageEnum.urlString(nil, nil))
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_ImageView_with_no_urlString() {
        let snapshotName = "IMAGE_VIEW_NO_URLSTRING"
        let (sut, container) = makeSUT(
            wrongUrlPlaceholderImage: UIImage(systemName: "xmark.circle")
        )

        sut.display(image: ImageEnum.urlString(nil, nil))
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        guard let url = URL(string: light) else {
            XCTFail("Invalid test URL: \(light)")
            return
        }
        sut.display(image: ImageEnum.url(url, url)) { _ in
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_ImageView_from_url_light() {
        let snapshotName = "IMAGE_VIEW_URL_LIGHT"
        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for completion")

        guard let url = URL(string: light) else {
            XCTFail("Invalid test URL: \(light)")
            return
        }
        sut.display(image: ImageEnum.url(url, url)) { _ in
            backgroundState.color = SwiftUIColor.red
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"
        let (sut, container) = makeSUT(wrongUrlPlaceholderImage: UIImage(systemName: "xmark"))

        sut.display(image: ImageEnum.url(nil, nil))
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_ImageView_with_no_url() {
        let snapshotName = "IMAGE_VIEW_NO_URL"
        let (sut, container) = makeSUT(
            wrongUrlPlaceholderImage: UIImage(systemName: "xmark.circle")
        )

        sut.display(image: ImageEnum.url(nil, nil))
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_ImageView_viewWhileLoadingView() {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        let loading = AnyView(SwiftUIColor.blue)
        let (sut, container) = makeSUT(viewWhileLoadingView: loading)
        let exp = expectation(description: "Wait for completion")
        exp.assertForOverFulfill = false

        guard let url = URL(string: light) else {
            XCTFail("Invalid test URL: \(light)")
            return
        }
        sut.display(image: ImageEnum.url(url, url)) { _ in
            exp.fulfill()
        }

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        waitForCompletion(exp, in: container, timeout: 5.0)
        sut.display(image: nil)
        KingfisherManager.shared.downloader.cancelAll()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    func test_fail_ImageView_viewWhileLoadingView() {
        let snapshotName = "IMAGE_VIEW_VIEWWHILELOADINGVIEW"
        let loading = AnyView(SwiftUIColor.cyan)
        let (sut, container) = makeSUT(viewWhileLoadingView: loading)
        let exp = expectation(description: "Wait for completion")
        exp.assertForOverFulfill = false

        guard let url = URL(string: light) else {
            XCTFail("Invalid test URL: \(light)")
            return
        }
        sut.display(image: ImageEnum.url(url, url)) { _ in
            exp.fulfill()
        }

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        waitForCompletion(exp, in: container, timeout: 5.0)
        sut.display(image: nil)
        KingfisherManager.shared.downloader.cancelAll()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
    }

    func test_ImageView_fallbackView() {
        let snapshotName = "IMAGE_VIEW_FALLBACKVIEW"
        let fallback = AnyView(SwiftUIColor.red)
        let (sut, container) = makeSUT(fallbackView: fallback)

        guard let url = URL(string: "https://example.invalid/wrong.png") else {
            XCTFail("Invalid test URL")
            return
        }
        sut.display(image: ImageEnum.url(url, url))
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_ImageView_fallbackView() {
        let snapshotName = "IMAGE_VIEW_FALLBACKVIEW"
        let fallback = AnyView(SwiftUIColor.orange)
        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState, fallbackView: fallback)

        guard let url = URL(string: "https://example.invalid/wrong.png") else {
            XCTFail("Invalid test URL")
            return
        }
        sut.display(image: ImageEnum.url(url, url))
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        backgroundState.color = SwiftUIColor.black

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        guard let url = URL(string: dark) else {
            XCTFail("Invalid test URL: \(dark)")
            return
        }
        sut.display(image: ImageEnum.url(url, url)) { _ in
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_ImageView_from_url_dark() {
        let snapshotName = "IMAGE_VIEW_URl_DARK"
        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for completion")

        guard let url = URL(string: light) else {
            XCTFail("Invalid test URL: \(light)")
            return
        }
        sut.display(image: ImageEnum.url(url, url)) { _ in
            backgroundState.color = SwiftUIColor.red
            exp.fulfill()
        }

        waitForCompletion(exp, in: container, timeout: 5.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_contentMode_is_fit() {
        let snapshotName = "IMAGE_VIEW_FITCONTENTMODE"
        let (sut, container) = makeSUT()

        sut.display(image: ImageEnum.asset(UIImage(systemName: "star")))
        sut.display(contentModeIsFit: true)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_contentMode_is_fit() {
        let snapshotName = "IMAGE_VIEW_FITCONTENTMODE"
        let (sut, container) = makeSUT()

        sut.display(image: ImageEnum.asset(UIImage(systemName: "star")))
        sut.display(contentModeIsFit: false)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"
        let (sut, container) = makeSUT()

        sut.display(borderWidth: 2)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_with_borderdWidth() {
        let snapshotName = "IMAGE_VIEW_BORDERWIDTH"
        let (sut, container) = makeSUT()

        sut.display(borderWidth: 3)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_with_borderColor() {
        let snapshotName = "IMAGE_VIEW_BORDERCOLOR"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(borderColor: WrapKit.Color.red)
        sut.display(borderWidth: 2)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_with_borderColor() {
        let snapshotName = "IMAGE_VIEW_BORDERCOLOR"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(borderColor: WrapKit.Color.systemRed)
        sut.display(borderWidth: 2)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(cornerRadius: 50)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_with_cornerRadius() {
        let snapshotName = "IMAGE_VIEW_CORNERRADIUS"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(cornerRadius: 51)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(alpha: 0.3)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_with_alpha() {
        let snapshotName = "IMAGE_VIEW_ALPHA"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(alpha: 0.4)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(isHidden: false)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_with_hidden() {
        let snapshotName = "IMAGE_VIEW_HIDDEN"
        let (sut, container) = makeSUT(backgroundColor: WrapKit.Color.cyan)

        sut.display(isHidden: true)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_onPress_visualState() {
        let snapshotName = "IMAGE_VIEW_ONPRESS"
        let releasedSnapshotName = "IMAGE_VIEW_ONPRESS_RELEASED"

        let (sut, container) = makeSUT()

        let onPress = { [weak sut] in
            guard let sut else { return }
            sut.display(alpha: 1)
        }
        sut.display(onPress: onPress)
        sut.display(image: ImageEnum.asset(UIImage(systemName: "star.fill")))
        sut.display(alpha: 0.5)
        render(container)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }

        onPress()
        render(container)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(releasedSnapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(releasedSnapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(releasedSnapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(releasedSnapshotName)_DARK")
        }
    }

    func test_fail_imageView_onPress_visualState() {
        let snapshotName = "IMAGE_VIEW_ONPRESS"
        let releasedSnapshotName = "IMAGE_VIEW_ONPRESS_RELEASED"

        let (sut, container) = makeSUT()

        let onPress = { [weak sut] in
            guard let sut else { return }
            sut.display(alpha: 1)
        }
        sut.display(onPress: onPress)
        sut.display(image: ImageEnum.asset(UIImage(systemName: "star")))
        sut.display(alpha: 0.5)
        render(container)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }

        onPress()
        render(container)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(releasedSnapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(releasedSnapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(releasedSnapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(releasedSnapshotName)_DARK")
        }
    }

    func test_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"

        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for animation completion")

        let onPress = {
            backgroundState.color = .red
            exp.fulfill()
        }

        sut.display(onPress: onPress)
        onPress()

        wait(for: [exp], timeout: 1.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_direct_onPress() {
        let snapshotName = "IMAGE_VIEW_ONPRESS_DIRECT"

        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for animation completion")

        let onPress = {
            backgroundState.color = SwiftUIColor.blue
            exp.fulfill()
        }

        sut.display(onPress: onPress)
        onPress()

        wait(for: [exp], timeout: 1.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"

        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for onLongPress")

        let onLongPress = {
            backgroundState.color = SwiftUIColor(UIColor.systemYellow)
            exp.fulfill()
        }

        sut.display(onLongPress: onLongPress)
        onLongPress()

        wait(for: [exp], timeout: 1.0)
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_imageView_direct_onLongPress() {
        let snapshotName = "IMAGE_VIEW_ONLONGPRESS_DIRECT"

        let backgroundState = SnapshotBackgroundState()
        let (sut, container) = makeSUT(backgroundState: backgroundState)
        let exp = expectation(description: "Wait for onLongPress")

        let onLongPress = {
            backgroundState.color = .purple
            exp.fulfill()
        }

        sut.display(onLongPress: onLongPress)
        onLongPress()

        wait(for: [exp], timeout: 1.0)
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

@available(iOS 17, *)
extension SUIImageViewSnapshotTests {
    func makeSUT(
        backgroundColor: WrapKit.Color? = nil,
        backgroundState: SnapshotBackgroundState? = nil,
        viewWhileLoadingView: AnyView? = nil,
        fallbackView: AnyView? = nil,
        wrongUrlPlaceholderImage: UIImage? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ImageViewOutput, container: AnyView) {
        let adapter = ImageViewOutputSwiftUIAdapter()

        let baseImageView = SUIImageView(
            adapter: adapter,
            viewWhileLoadingView: viewWhileLoadingView,
            fallbackView: fallbackView,
            wrongUrlPlaceholderImage: wrongUrlPlaceholderImage,
            backgroundColor: backgroundColor.map(SwiftUIColor.init)
        )
        .frame(height: 150, alignment: .center)
        .frame(maxWidth: .infinity, alignment: .leading)
        let imageView = AnyView(
            Group {
                if let backgroundState {
                    DynamicBackgroundView(state: backgroundState, content: baseImageView)
                } else {
                    baseImageView
                }
            }
        )

        let container = AnyView(
            VStack(spacing: .zero) {
                imageView
                Spacer()
            }
        )

        checkForMemoryLeaks(adapter, file: file, line: line)
        addTeardownBlock { [weak adapter] in
            adapter?.displayModelCompletionState = nil
            adapter?.displayImageCompletionState = nil
            KingfisherManager.shared.downloader.cancelAll()
            KingfisherManager.shared.cache.clearMemoryCache()
            RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        }

        return (adapter.weakReferenced, container)
    }

    private func waitForCompletion(
        _ expectation: XCTestExpectation,
        in container: AnyView,
        timeout: TimeInterval,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let timer = Timer(timeInterval: 0.05, repeats: true) { _ in
            _ = container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light))
        }
        RunLoop.main.add(timer, forMode: .common)
        defer { timer.invalidate() }

        wait(for: [expectation], timeout: timeout)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        _ = container.snapshot(for: SUISnapshotConfiguration.iPhone(style: .light))
        _ = file
        _ = line
    }

    private func render(_ container: AnyView, delay: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(delay))
        _ = container
    }
}

@available(iOS 17, *)
final class SnapshotBackgroundState: ObservableObject {
    @Published var color: SwiftUIColor = .clear
}

@available(iOS 17, *)
private struct DynamicBackgroundView<Content: View>: View {
    @ObservedObject var state: SnapshotBackgroundState
    let content: Content

    var body: some View {
        content.background(state.color)
    }
}
