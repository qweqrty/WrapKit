import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import enum SwiftUI.ColorScheme
#endif

final class EmptyViewSnapshotTests: XCTestCase {

    private weak var currentPairedSUT: PairedEmptyViewSnapshotSUT?

    private var swiftUISnapshotPrecision: Float { 0.98 }
    private var swiftUIFailSnapshotPrecision: Float { 1 }

    func test_emptyView_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_DEFAULT_STATE"

        sut.display(title: .text("Empty view"))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_emptyView_default_state() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_DEFAULT_STATE"

        sut.display(title: .text("Empty view."))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_emptyView_with_subTitle() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_SUBTITLE"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_emptyView_with_subTitle() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_SUBTITLE"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle."))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_emptyView_with_Button() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_BUTTON"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(buttonModel: makeButtonModel(backgroundColor: .systemBlue))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_emptyView_with_Button() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_BUTTON"

        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(buttonModel: makeButtonModel(backgroundColor: .blue))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // UIKit-only — image не реализован в SUIEmptyViewContent (TODO в коде)
    func test_emptyView_with_Image() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_IMAGE"

        let image = Image(systemName: "star.fill")
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(image: ImageViewPresentableModel(image: .asset(image)))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_emptyView_with_Image() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_IMAGE"

        let image = Image(systemName: "star")
        sut.display(title: .text("Empty view"))
        sut.display(subtitle: .text("Subtitle"))
        sut.display(image: ImageViewPresentableModel(image: .asset(image)))
        sut.uiKitView.backgroundColor = .cyan

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_emptyView_with_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_HIDDEN"

        sut.uiKitView.backgroundColor = .cyan
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_emptyView_with_hidden() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_HIDDEN"

        sut.uiKitView.backgroundColor = .cyan
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    // UIKit-only — display(model:) содержит image которое не реализовано в SwiftUI
    func test_emptyView_with_model() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_MODEL"

        sut.uiKitView.backgroundColor = .cyan
        sut.display(model: makeFullModel(titleText: "Title", subtitleText: "Subtitle"))

        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_emptyView_with_model() {
        let (sut, container) = makeSUT()
        let snapshotName = "EMPTYVIEW_WITH_MODEL"

        sut.uiKitView.backgroundColor = .cyan
        sut.display(model: makeFullModel(titleText: "Title.", subtitleText: "Subtitle."))

        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension EmptyViewSnapshotTests {

    func assertPairedSnapshot(
        snapshot: UIImage,
        named name: String,
        precision: Float = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(snapshot: snapshot, named: name, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assert(
                snapshot: swiftUISnapshot,
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
        assertFail(snapshot: snapshot, named: name, precision: precision, file: file, line: line)

        if #available(iOS 17.0, *),
           let swiftUISnapshot = currentPairedSUT?.swiftUISnapshot(for: colorScheme(from: name)) {
            assertFail(
                snapshot: swiftUISnapshot,
                named: name,
                precision: swiftUIFailSnapshotPrecision,
                file: file,
                line: line
            )
        }
    }

    func colorScheme(from snapshotName: String) -> ColorScheme {
        snapshotName.hasSuffix("_DARK") ? .dark : .light
    }

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
    ) -> (sut: PairedEmptyViewSnapshotSUT, container: UIView) {
        let sut = PairedEmptyViewSnapshotSUT()
        let container = makeContainer()

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )
        container.layoutIfNeeded()

        currentPairedSUT = sut
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return (sut, container)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
