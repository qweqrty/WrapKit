import WrapKit
import WrapKitTestUtils
import XCTest

final class SUIProgressBarSnapshotTests: XCTestCase {

    func test_progressBar_defaul_state() {
        let snapshotName = "PROGRESSBAR_DEFAULT_STATE"
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0, trackHeight: 5.0))
        sut.display(progress: 0.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_defaul_state() {
        let snapshotName = "PROGRESSBAR_DEFAULT_STATE"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .red, height: 5.0))
        sut.display(progress: 0.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_progressBar_with_progressBar_color() {
        let snapshotName = "PROGRESSBAR_WITH_PROGRESSBAR_COLOR"
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 6.0))
        sut.display(progress: 100.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_with_progressBar_color() {
        let snapshotName = "PROGRESSBAR_WITH_PROGRESSBAR_COLOR"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .red, height: 5.0))
        sut.display(progress: 100.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_progressBar_with_height() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 50))
        sut.display(progress: 100.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_with_height() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 51))
        sut.display(progress: 100.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_progressBar_with_cornerStyle() {
        let snapshotName = "PROGRESSBAR_WITH_CORNERSTYLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            progressBarColor: .cyan,
            height: 10,
            cornerStyle: .fixed(10)))
        sut.display(progress: 50.0)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_with_cornerStyle() {
        let snapshotName = "PROGRESSBAR_WITH_CORNERSTYLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            progressBarColor: .cyan,
            height: 10,
            cornerStyle: .fixed(2)))
        sut.display(progress: 50.0)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_progressBar_hidden() {
        let snapshotName = "PROGRESSBAR_HIDDEN"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 50.0)
        sut.display(model: nil)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_hidden() {
        let snapshotName = "PROGRESSBAR_HIDDEN"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 50.0)
        sut.display(model: nil)
        sut.display(isHidden: false)

        assertFail(snapshot: sut, named: snapshotName)
    }



    func test_progressBar_half_filled() {
        let snapshotName = "PROGRESSBAR_HALF_FILLED"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(model: .init(
            progress: 50.0,
            style: .init(
                backgroundColor: .systemGray4,
                progressBarColor: .systemGreen,
                height: 6.0,
                cornerStyle: .fixed(4)
            )
        ))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_half_filled() {
        let snapshotName = "PROGRESSBAR_HALF_FILLED"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(model: .init(
            progress: 51.0,
            style: .init(
                backgroundColor: .systemGray4,
                progressBarColor: .systemGreen,
                height: 6.0,
                cornerStyle: .fixed(4)
            )
        ))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_fail_progressBar_styleWithoutHeight_preservesEstablishedHeight() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 51))
        sut.display(style: .init(backgroundColor: .systemRed, trackHeight: 33))
        sut.display(progress: 100.0)

        assertFail(snapshot: sut, named: snapshotName)
    }
}

extension SUIProgressBarSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUIProgressBarSnapshotSUT {
        let container = makeContainer()
        let sut = SwiftUIProgressBarSnapshotSUT(uiKitContainer: container)

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
