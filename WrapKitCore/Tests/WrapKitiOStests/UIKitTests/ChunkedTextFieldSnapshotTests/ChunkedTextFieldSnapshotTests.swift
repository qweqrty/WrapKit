//
//  ChunkedTextFieldSnapshotTests.swift
//  WrapKitTests
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class ChunkedTextFieldSnapshotTests: XCTestCase {
    func test_ChunkedTextField_default_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DEFAULT_STATE"

        sut.display(text: nil)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_default_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DEFAULT_STATE"

        sut.display(text: "1")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_with_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_TEXT"

        sut.display(text: "1234")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_TEXT"

        sut.display(text: "1235")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_with_partial_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_PARTIAL_TEXT"

        sut.display(text: "12")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_partial_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_PARTIAL_TEXT"

        sut.display(text: "123")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_with_long_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_LONG_TEXT"

        sut.display(text: "123456789")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_long_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_LONG_TEXT"

        sut.display(text: "987654321")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_invalid_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_INVALID_STATE"

        sut.display(text: "1234")
        sut.display(isValid: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_invalid_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_INVALID_STATE"

        sut.display(text: "1234")
        sut.display(isValid: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_disabled_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DISABLED_STATE"

        sut.display(text: "1234")
        sut.display(isUserInteractionEnabled: false)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_disabled_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DISABLED_STATE"

        sut.display(text: "1234")
        sut.display(isUserInteractionEnabled: true)

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_with_six_items() {
        let sut = makeSUT(count: 6)
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_SIX_ITEMS"

        sut.display(text: "123456")

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_six_items() {
        let sut = makeSUT(count: 6)
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_SIX_ITEMS"

        sut.display(text: "12345")

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_ChunkedTextField_with_model() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_MODEL"

        sut.display(model: .init(text: "4321", isValid: false, isUserInteractionEnabled: true))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_model() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_MODEL"

        sut.display(model: .init(text: "4321", isValid: true, isUserInteractionEnabled: true))

        assertFail(snapshot: sut, named: snapshotName)
    }
}

private extension ChunkedTextFieldSnapshotTests {
    func makeSUT(
        count: Int = 4,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> PairedChunkedTextFieldSnapshotSUT {
        let sut = PairedChunkedTextFieldSnapshotSUT(
            count: count,
            appearance: makeAppearance()
        )

        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeAppearance() -> TextfieldAppearance {
        TextfieldAppearance(
            colors: .init(
                textColor: .blue,
                selectedBorderColor: .yellow,
                selectedBackgroundColor: .cyan,
                selectedErrorBorderColor: .red,
                errorBorderColor: .systemRed,
                errorBackgroundColor: .brown,
                deselectedBorderColor: .green,
                deselectedBackgroundColor: .orange,
                disabledTextColor: .purple,
                disabledBackgroundColor: .systemPurple
            ),
            font: .systemFont(ofSize: 24),
            border: .init(
                idleBorderWidth: 2,
                selectedBorderWidth: 3
            ),
            placeholder: .init(
                color: .systemGray,
                font: .systemFont(ofSize: 20)
            )
        )
    }
}
