import WrapKit
import WrapKitTestUtils
import XCTest

final class ProgressBarSnapshotTests: XCTestCase {

    func test_progressBar_presentableModel_preservesDynamicColors() {
        let trackColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? .black : .white
        }
        let fillColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? .green : .red
        }
        let sut = ProgressBarView()

        sut.display(model: .init(
            progress: 50,
            style: .init(
                backgroundColor: trackColor,
                progressBarColor: fillColor,
                cornerStyle: .fixed(4)
            )
        ))

        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        XCTAssertTrue(
            sut.trackView.backgroundColor?.resolvedColor(with: lightTraits).isEqual(UIColor.white) == true
        )
        XCTAssertTrue(
            sut.trackView.backgroundColor?.resolvedColor(with: darkTraits).isEqual(UIColor.black) == true
        )
        XCTAssertTrue(
            sut.progressView.backgroundColor?.resolvedColor(with: lightTraits).isEqual(UIColor.red) == true
        )
        XCTAssertTrue(
            sut.progressView.backgroundColor?.resolvedColor(with: darkTraits).isEqual(UIColor.green) == true
        )
    }

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
    
    func test_progressBar_with_gradient() {
        // UIKit implementation detail: gradientBackgroundColor/applyCornerStyle are not part of
        // ProgressBarOutput, so there is no adapter state to mirror into SwiftUI here.
        let snapshotName = "PROGRESSBAR_WITH_GRADIENT"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .clear, height: 6.0, cornerStyle: .fixed(4)))
        sut.display(progress: 100.0)
        sut.applyCornerStyle(.fixed(4))
        sut.gradientBackgroundColor(
            width: 6,
            colors: [.systemBlue, .systemPurple, .systemRed],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 0)
        )
        
        // THEN
        assertUIKitOnlySnapshot(
            snapshot: sut,
            named: snapshotName,
            reason: "The gradient API is UIKit-only and is not part of ProgressBarOutput."
        )
    }
    
    func test_fail_progressBar_with_gradient() {
        let snapshotName = "PROGRESSBAR_WITH_GRADIENT"
        
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .clear, height: 6.0, cornerStyle: .fixed(4)))
        sut.display(progress: 100.0)
        sut.gradientBackgroundColor(
            width: 6,
            colors: [.systemGreen, .systemYellow, .systemOrange],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 0)
        )
        
        // THEN
        assertUIKitOnlySnapshotFail(
            snapshot: sut,
            named: snapshotName,
            reason: "The gradient API is UIKit-only and is not part of ProgressBarOutput."
        )
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

    func test_progressBar_styleWithoutHeight_preservesEstablishedHeight() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"
        let sut = makeSUT()

        sut.display(style: .init(backgroundColor: .systemRed, height: 50))
        sut.display(style: .init(backgroundColor: .systemRed, trackHeight: 33))
        sut.display(progress: 100.0)

        assert(snapshot: sut, named: snapshotName)
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

extension ProgressBarSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PairedProgressBarSnapshotSUT {
        let container = makeContainer()
        let sut = PairedProgressBarSnapshotSUT(uiKitContainer: container)

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
