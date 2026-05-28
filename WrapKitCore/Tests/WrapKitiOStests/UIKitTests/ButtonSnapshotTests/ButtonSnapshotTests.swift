//
//  ButtonSnapshotTests.swift
//  WrapKit
//

import WrapKit
import XCTest
import WrapKitTestUtils
import Kingfisher

#if canImport(SwiftUI)
import enum SwiftUI.ColorScheme
#endif

private enum ImageTestLinks: String {
    case light = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
    case dark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"
}

final class ButtonSnapshotTests: XCTestCase {

    private weak var currentPairedSUT: PairedButtonSnapshotSUT?

    private var swiftUISnapshotPrecision: Float { 0.98 }
    private var swiftUIFailSnapshotPrecision: Float { 1 }

    override class func setUp() {
        super.setUp()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearCache()
        KingfisherManager.shared.cache.clearDiskCache()
        KingfisherManager.shared.cache.cleanExpiredCache()
        KingfisherManager.shared.cache.cleanExpiredMemoryCache()
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
    }

    func test_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "Default")
        sut.display(style: .init(backgroundColor: .cyan))
        
        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_default_state() {
        let snapshotName = "BUTTON_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "Default.")
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "Enabled")
        sut.display(enabled: false)
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_enabled_state() {
        let snapshotName = "BUTTON_ENABLED_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "Enabled")
        sut.display(enabled: true)
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"
        let (sut, container) = makeSUT()

        sut.display(image: UIImage(systemName: "star.fill"))
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_image_state() {
        let snapshotName = "BUTTON_IMAGE_STATE"
        let (sut, container) = makeSUT()

        sut.display(image: UIImage(systemName: "star"))
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // MARK: - Set image tests

    func test_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.asset(UIImage(systemName: "star.fill"))) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_buttonOutput_image_assets() {
        let snapshotName = "BUTTON_IMAGE_ASSET"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.asset(UIImage(systemName: "star"))) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    // URL тесты — только UIKit (SwiftUI не поддерживает async URL через ButtonOutputSwiftUIAdapter)

    func test_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.url(URL(string: ImageTestLinks.light.rawValue), URL(string: ImageTestLinks.light.rawValue))) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_buttonOutput_imageURL_state_light() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .blue))
        sut.setImage(.url(URL(string: ImageTestLinks.light.rawValue), URL(string: ImageTestLinks.light.rawValue))) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.url(URL(string: ImageTestLinks.dark.rawValue), URL(string: ImageTestLinks.dark.rawValue))) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_imageURL_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URL_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .blue))
        sut.setImage(.url(URL(string: ImageTestLinks.dark.rawValue), URL(string: ImageTestLinks.dark.rawValue))) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.urlString(ImageTestLinks.light.rawValue, ImageTestLinks.light.rawValue)) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_fail_buttonOutput_imageURLString_state_light() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .blue))
        sut.setImage(.urlString(ImageTestLinks.light.rawValue, ImageTestLinks.light.rawValue)) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
        }
    }

    func test_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.urlString(ImageTestLinks.dark.rawValue, ImageTestLinks.dark.rawValue)) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_imageURLString_state_dark() {
        let snapshotName = "BUTTON_IMAGE_URLSTRING_STATE"
        let (sut, container) = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.display(style: .init(backgroundColor: .blue))
        sut.setImage(.urlString(ImageTestLinks.dark.rawValue, ImageTestLinks.dark.rawValue)) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 5.0)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"
        let (sut, container) = makeSUT()

        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_noUrl() {
        let snapshotName = "BUTTON_IMAGE_NOURL"
        let (sut, container) = makeSUT()

        sut.setImage(.url(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .blue))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"
        let (sut, container) = makeSUT()

        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_noURLString() {
        let snapshotName = "BUTTON_IMAGE_NOURLSTRING"
        let (sut, container) = makeSUT()

        sut.setImage(.urlString(nil, nil), completion: nil)
        sut.display(style: .init(backgroundColor: .blue))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"
        let (sut, container) = makeSUT()

        sut.display(model: .init(title: "BUTTON WITH SPACING", image: UIImage(systemName: "star"), spacing: 50, style: .init(backgroundColor: .red)))
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_spacing() {
        let snapshotName = "BUTTON_WITH_SPACING"
        let (sut, container) = makeSUT()

        sut.display(model: .init(title: "BUTTON WITH SPACING", image: UIImage(systemName: "star"), spacing: 40, style: .init(backgroundColor: .red)))
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_onPress() {
        let snapshotName = "BUTTON_WITH_TAP"
        let (sut, container) = makeSUT()

        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display { [weak sut] in sut?.backgroundColor = .red }
        sut.onPress?()

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_onPress() {
        let snapshotName = "BUTTON_WITH_TAP"
        let (sut, container) = makeSUT()

        sut.display(title: "BUTTON WITH TAP")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display { [weak sut] in sut?.backgroundColor = .systemRed }
        sut.onPress?()

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"
        let (sut, container) = makeSUT()

        sut.display(model: .init(title: "BUTTON WITH height", image: UIImage(systemName: "star"), spacing: 50, height: 100, style: .init(backgroundColor: .red)))
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_height() {
        let snapshotName = "BUTTON_WITH_HEIGHT"
        let (sut, container) = makeSUT()

        sut.display(model: .init(title: "BUTTON WITH height", image: UIImage(systemName: "star"), spacing: 50, height: 0, style: .init(backgroundColor: .red)))
        sut.display(style: .init(backgroundColor: .cyan))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"
        let (sut, container) = makeSUT()

        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_isHidden() {
        let snapshotName = "BUTTON_ISHIDDEN"
        let (sut, container) = makeSUT()

        sut.display(title: "BUTTON IS HIDDEN")
        sut.display(style: .init(backgroundColor: .cyan))
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // MARK: - ButtonStyle tests

    func test_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_backgroundColor() {
        let snapshotName = "BUTTON_STYLE_BACKGROUN_COLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .red))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "TITLE WITH COLOR")
        sut.display(style: .init(backgroundColor: .cyan, titleColor: .red))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_titleColor() {
        let snapshotName = "BUTTON_STYLE_TITLE_COLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "TITLE WITH COLOR.")
        sut.display(style: .init(backgroundColor: .cyan, titleColor: .red))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .cyan, borderWidth: 4.0, borderColor: .red))
        sut.display(title: "BUTTON WITH BORDER")

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_borderWidth() {
        let snapshotName = "BUTTON_STYLE_BORDER_WIDTH_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .cyan, borderWidth: 5.0, borderColor: .red))
        sut.display(title: "BUTTON WITH BORDER")

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // TODO: - pressedColor / pressedTintColor — UIKit only (анимация, нельзя симулировать в SwiftUI)
    func test_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .blue, pressedColor: .red))
        sut.touchesBegan([UITouch()], with: nil)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_pressedColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_COLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .blue, pressedColor: .systemRed))
        sut.touchesBegan([UITouch()], with: nil)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .white, titleColor: .blue, pressedTintColor: .red))
        sut.display(title: "PRESSED TINT COLOR")
        sut.touchesBegan([UITouch()], with: nil)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_pressedTintColor() {
        let snapshotName = "BUTTON_STYLE_PRESSED_TINTCOLOR_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .white, titleColor: .blue, pressedTintColor: .systemRed))
        sut.display(title: "PRESSED TINT COLOR")
        sut.touchesBegan([UITouch()], with: nil)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .cyan, font: .systemFont(ofSize: 24, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_font() {
        let snapshotName = "BUTTON_STYLE_FONT_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .cyan, font: .systemFont(ofSize: 25, weight: .bold)))
        sut.display(title: "BUTTON WITH FONT")

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .cyan, cornerRadius: 40))

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_style_cornerRadius() {
        let snapshotName = "BUTTON_STYLE_CORNER_RADIUS_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "BUTTON WITH CORNER RADIUS")
        sut.display(style: .init(backgroundColor: .cyan, cornerRadius: 41))

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")

        sut.display(style: .init(backgroundColor: .cyan))
        sut.setImage(.url(nil, nil), completion: nil)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_with_no_url() {
        let snapshotName = "BUTTON_OUTPUT_NO_URL"
        let (sut, container) = makeSUT()
        sut.wrongUrlPlaceholderImage = UIImage(systemName: "xmark")

        sut.display(style: .init(backgroundColor: .blue))
        sut.setImage(.url(nil, nil), completion: nil)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "Button title")
        sut.display(style: .init(backgroundColor: .systemBlue, loadingIndicatorColor: .red))
        sut.display(isLoading: true)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_buttonOutput_isLoading_state() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE"
        let (sut, container) = makeSUT()

        sut.display(title: "Button title")
        sut.display(style: .init(backgroundColor: .systemBlue, loadingIndicatorColor: .red))
        sut.display(isLoading: false)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_buttonOutput_isLoading_state_false() {
        let snapshotName = "BUTTON_OUTPUT_ISLOADING_STATE_FALSE"
        let (sut, container) = makeSUT()

        sut.display(title: "Button title")
        sut.display(style: .init(backgroundColor: .systemBlue, loadingIndicatorColor: .red))
        sut.display(isLoading: false)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension ButtonSnapshotTests {

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(snapshot: normalizedButtonSnapshot(snapshot), named: name, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assert(
                snapshot: normalizedButtonSnapshot(swiftUISnapshot),
                named: name,
                precision: swiftUISnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func assertPairedSnapshotFail(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertFail(snapshot: normalizedButtonSnapshot(snapshot), named: name, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertFail(
                snapshot: normalizedButtonSnapshot(swiftUISnapshot),
                named: name,
                precision: swiftUIFailSnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func normalizedButtonSnapshot(_ image: UIImage) -> UIImage {
        let clippingHeight: CGFloat = 300
        let size = image.size
        guard size.height > clippingHeight else { return image }

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            image.draw(at: .zero)
            ctx.cgContext.clear(
                CGRect(x: 0, y: clippingHeight, width: size.width, height: size.height - clippingHeight)
            )
        }
    }

    func colorScheme(from snapshotName: String) -> ColorScheme {
        snapshotName.hasSuffix("_DARK") ? .dark : .light
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedButtonSnapshotSUT, container: UIView) {
        let sut = PairedButtonSnapshotSUT()
        let container = makeContainer()

        container.addSubview(sut.uiKitButton)
        sut.uiKitButton.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(60, priority: .required)
        )
        container.layoutIfNeeded()
        
        currentPairedSUT = sut
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitButton, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
