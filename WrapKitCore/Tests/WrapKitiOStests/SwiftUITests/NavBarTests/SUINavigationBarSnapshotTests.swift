#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
@testable import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUINavigationBarSnapshotTests: XCTestCase {
    func test_live_default_state_matchesUIKit() {
        let snapshotName = "SUI_NAVBAR_LIVE_DEFAULT_STATE_MATCHES_UIKIT"

        let (sut, container) = makeSUT()

        sut.display(model: HeaderPresentableModel(style: makeStyle()))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_live_centerView_keyValue_matchesUIKit() {
        let snapshotName = "SUI_NAVBAR_LIVE_CENTERVIEW_KEYVALUE_MATCHES_UIKIT"

        let (sut, container) = makeSUT()

        sut.display(
            model: HeaderPresentableModel(
                style: makeStyle(),
                centerView: .keyValue(.init(.text("First"), .text("Second")))
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_live_secondaryTrailing_matchesUIKit() {
        let snapshotName = "SUI_NAVBAR_LIVE_SECONDARYTRAILING_MATCHES_UIKIT"

        let (sut, container) = makeSUT()

        sut.display(
            model: HeaderPresentableModel(
                style: makeStyle(),
                secondaryTrailingImage: .init(
                    title: "Image",
                    image: ImageFactory.systemImage(named: "star.fill"),
                    height: 24
                )
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_default_state() {
        let snapshotName = "SUI_NAVBAR_DEFAULT_STATE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_default_state() {
        let snapshotName = "SUI_NAVBAR_DEFAULT_STATE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle(backgroundColor: .systemRed))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_with_centerView_keyValue() {
        let snapshotName = "SUI_NAVBAR_WITH_CENTERVIEW_KEYVALUE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(centerView: .keyValue(.init(.text("First"), .text("Second"))))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_with_centerView_keyValue() {
        let snapshotName = "SUI_NAVBAR_WITH_CENTERVIEW_KEYVALUE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(centerView: .keyValue(.init(.text("First."), .text("Second"))))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_with_centerView_titleImage() {
        let snapshotName = "SUI_NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            centerView: .titledImage(
                .init(
                    .init(
                        size: CGSize(width: 24, height: 24),
                        image: .asset(ImageFactory.systemImage(named: "star.fill"))
                    ),
                    .text("Title")
                )
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_with_centerView_titleImage() {
        let snapshotName = "SUI_NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            centerView: .titledImage(
                .init(
                    .init(
                        size: CGSize(width: 24, height: 24),
                        image: .asset(ImageFactory.systemImage(named: "star"))
                    ),
                    .text("Title")
                )
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_with_leadingCard_backgroundImage_title() {
        let snapshotName = "SUI_NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            leadingCard: .init(
                backgroundImage: .init(image: .asset(ImageFactory.systemImage(named: "star.fill"))),
                title: .text("Title"),
                onPress: { }
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_with_leadingCard_backgroundImage_title() {
        let snapshotName = "SUI_NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            leadingCard: .init(
                backgroundImage: .init(image: .asset(ImageFactory.systemImage(named: "star"))),
                title: .text("Title")
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_with_secondaryTrailingImage() {
        let snapshotName = "SUI_NAVBAR_WITH_SECONDARY_TRAILING_IMAGE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            secondaryTrailingImage: .init(
                title: "Image",
                image: ImageFactory.systemImage(named: "star.fill"),
                height: 24
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_with_secondaryTrailingImage() {
        let snapshotName = "SUI_NAVBAR_WITH_SECONDARY_TRAILING_IMAGE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            secondaryTrailingImage: .init(
                title: "Image",
                image: ImageFactory.systemImage(named: "star"),
                height: 24
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_with_tertiaryAndSecondary_trailingImages() {
        let snapshotName = "SUI_NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGES"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            tertiaryTrailingImage: .init(
                title: "Tert",
                image: ImageFactory.systemImage(named: "star.fill"),
                height: 24
            )
        )
        sut.display(
            secondaryTrailingImage: .init(
                title: "Second",
                image: ImageFactory.systemImage(named: "star.fill"),
                height: 24
            )
        )

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_with_tertiaryAndSecondary_trailingImages() {
        let snapshotName = "SUI_NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGES"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(
            tertiaryTrailingImage: .init(
                title: "Tert",
                image: ImageFactory.systemImage(named: "star"),
                height: 24
            )
        )
        sut.display(
            secondaryTrailingImage: .init(
                title: "Second",
                image: ImageFactory.systemImage(named: "star"),
                height: 24
            )
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_navigationBar_hidden_state() {
        let snapshotName = "SUI_NAVBAR_HIDDEN_STATE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_hidden_state() {
        let snapshotName = "SUI_NAVBAR_HIDDEN_STATE"

        let (sut, container) = makeSUT()

        sut.display(style: makeStyle())
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

@available(iOS 17.0, *)
private extension SUINavigationBarSnapshotTests {
    func makeStyle(
        backgroundColor: UIColor = .red,
        horizontalSpacing: CGFloat = 1.0
    ) -> HeaderPresentableModel.Style {
        .init(
            backgroundColor: backgroundColor,
            horizontalSpacing: horizontalSpacing,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green
        )
    }

    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: HeaderOutputSwiftUIAdapter, container: UIViewController) {
        let sut = HeaderOutputSwiftUIAdapter()
        let host = UIHostingController(rootView: SUINavigationBar(adapter: sut))
        let container = makeContainer()

        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        container.addChild(host)
        container.view.addSubview(host.view)
        host.view.anchor(
            .top(container.view.topAnchor, constant: 0, priority: .required),
            .leading(container.view.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.view.trailingAnchor, constant: 0, priority: .required)
        )
        host.didMove(toParent: container)

        container.view.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(host, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIViewController {
        let container = UIViewController()
        container.view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.view.backgroundColor = .clear
        return container
    }
}
#endif
