import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUIEmptyViewSnapshotTests: XCTestCase {

    func test_emptyView_default_state() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_DEFAULT_STATE"

        sut.display(title: .text("Empty view"))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_emptyView_default_state() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_DEFAULT_STATE"

        sut.display(title: .text("Empty view."))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_emptyView_with_subTitle() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_SUBTITLE"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_emptyView_with_subTitle() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_SUBTITLE"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle."))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_emptyView_with_Button() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_BUTTON"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(buttonModel: makeButtonModel(backgroundColor: .systemBlue))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_emptyView_with_Button() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_BUTTON"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(buttonModel: makeButtonModel(backgroundColor: .blue))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_emptyView_with_Image() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_IMAGE"

        let image = Image(systemName: "star.fill")
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(image: ImageViewPresentableModel(image: .asset(image)))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_emptyView_with_Image() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_IMAGE"

        let image = Image(systemName: "star")
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(image: ImageViewPresentableModel(image: .asset(image)))
        sut.display(backgroundColor: .cyan)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_emptyView_with_hidden() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_HIDDEN"

        sut.display(backgroundColor: .cyan)
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_emptyView_with_hidden() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_HIDDEN"

        sut.display(backgroundColor: .cyan)
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_emptyView_with_model() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_MODEL"

        sut.display(backgroundColor: .cyan)
        sut.display(model: makeFullModel(titleText: "Title", subtitleText: "Subtitle"))

        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_emptyView_with_model() {
        let sut = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_MODEL"

        sut.display(backgroundColor: .cyan)
        sut.display(model: makeFullModel(titleText: "Title.", subtitleText: "Subtitle."))

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
extension SUIEmptyViewSnapshotTests {
    func makeButtonModel(backgroundColor: UIColor) -> ButtonPresentableModel {
        let image = Image(systemName: "star.fill")
        return ButtonPresentableModel(
            title: "Button",
            image: image,
            spacing: 2,
            height: 40,
            style: ButtonStyle(
                backgroundColor: backgroundColor,
                titleColor: .black,
                borderWidth: 2,
                borderColor: .red,
                pressedColor: .green,
                pressedTintColor: .yellow,
                font: .systemFont(ofSize: 22),
                cornerRadius: 5,
                wrongUrlPlaceholderImage: image
            ),
            enabled: true
        )
    }

    func makeFullModel(titleText: String, subtitleText: String) -> EmptyViewPresentableModel {
        let image = Image(systemName: "star.fill")
        return EmptyViewPresentableModel(
            title: .text(titleText),
            subTitle: .text(subtitleText),
            button: makeButtonModel(backgroundColor: .systemBlue),
            image: ImageViewPresentableModel(image: .asset(image)),
            animationConfig: .default
        )
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUIEmptyViewSnapshotSUT {
        let container = makeContainer()
        let sut = SwiftUIEmptyViewSnapshotSUT(uiKitContainer: container)

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
