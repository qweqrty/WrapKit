import WrapKit
import WrapKitTestUtils
import XCTest

#if canImport(SwiftUI)
import enum SwiftUI.ColorScheme
#endif

final class ProgressBarSnapshotTests: XCTestCase {

    private weak var currentPairedSUT: PairedProgressBarSnapshotSUT?

    private var swiftUISnapshotPrecision: Float { 0.98 }
    private var swiftUIFailSnapshotPrecision: Float { 1 }

    func test_progressBar_defaul_state() {
        let snapshotName = "PROGRESSBAR_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 0.0)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_progressBar_defaul_state() {
        let snapshotName = "PROGRESSBAR_DEFAULT_STATE"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .red, height: 5.0))
        sut.display(progress: 0.0)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_progressBar_with_progressBar_color() {
        let snapshotName = "PROGRESSBAR_WITH_PROGRESSBAR_COLOR"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 100.0)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_progressBar_with_progressBar_color() {
        let snapshotName = "PROGRESSBAR_WITH_PROGRESSBAR_COLOR"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .red, height: 5.0))
        sut.display(progress: 100.0)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_progressBar_with_height() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 50))
        sut.display(progress: 100.0)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_progressBar_with_height() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"

        // UIKit-only — используется window напрямую
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 300))
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        let (sut, _) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 51))
        sut.display(progress: 100.0)

        window.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(window.topAnchor, constant: 10, priority: .required),
            .leading(window.leadingAnchor, constant: 10, priority: .required),
            .trailing(window.trailingAnchor, constant: 10, priority: .required)
        )

        if #available(iOS 26, *) {
            assertFail(snapshot: window.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: window.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: window.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: window.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }

        sut.uiKitView.removeFromSuperview()
        window.isHidden = true
        window.resignKey()
    }

    func test_progressBar_with_cornerRadius() {
        let snapshotName = "PROGRESSBAR_WITH_CORNDERRADIUS"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, progressBarColor: .cyan, height: 10, cornerRadius: 10))
        sut.display(progress: 50.0)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_progressBar_with_cornerRadius() {
        let snapshotName = "PROGRESSBAR_WITH_CORNDERRADIUS"
        let (sut, container) = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, progressBarColor: .cyan, height: 10, cornerRadius: 11))
        sut.display(progress: 50.0)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_progressBar_hidden() {
        let snapshotName = "PROGRESSBAR_HIDDEN"
        let (sut, container) = makeSUT()

        sut.display(progress: 50.0)
        sut.display(isHidden: true)

        if #available(iOS 26, *) {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshot(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_progressBar_hidden() {
        let snapshotName = "PROGRESSBAR_HIDDEN"
        let (sut, container) = makeSUT()

        sut.display(progress: 50.0)
        sut.display(isHidden: false)

        if #available(iOS 26, *) {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertPairedSnapshotFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension ProgressBarSnapshotTests {

    func swiftUISnapshotPrecision(for snapshotName: String) -> Float {
        if snapshotName.contains("PROGRESSBAR_WITH_HEIGHT") { return 0.96 }
        if snapshotName.contains("PROGRESSBAR_WITH_CORNDERRADIUS") { return 0.97 }
        return swiftUISnapshotPrecision
    }

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
                precision: swiftUISnapshotPrecision(for: name),
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

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PairedProgressBarSnapshotSUT, container: UIView) {
        let sut = PairedProgressBarSnapshotSUT()
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
