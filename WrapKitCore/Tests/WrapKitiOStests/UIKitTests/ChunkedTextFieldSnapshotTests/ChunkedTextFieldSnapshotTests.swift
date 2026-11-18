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

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_default_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DEFAULT_STATE"

        sut.display(text: "1")

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_with_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_TEXT"

        sut.display(text: "1234")

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_TEXT"

        sut.display(text: "1235")

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_with_partial_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_PARTIAL_TEXT"

        sut.display(text: "12")

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_partial_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_PARTIAL_TEXT"

        sut.display(text: "123")

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_with_long_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_LONG_TEXT"

        sut.display(text: "123456789")

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_long_text() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_LONG_TEXT"

        sut.display(text: "987654321")

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_invalid_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_INVALID_STATE"

        sut.display(text: "1234")
        sut.display(isValid: false)

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_invalid_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_INVALID_STATE"

        sut.display(text: "1234")
        sut.display(isValid: true)

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_disabled_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DISABLED_STATE"

        sut.display(text: "1234")
        sut.display(isUserInteractionEnabled: false)

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_disabled_state() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_DISABLED_STATE"

        sut.display(text: "1234")
        sut.display(isUserInteractionEnabled: true)

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_with_six_items() {
        let sut = makeSUT(count: 6)
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_SIX_ITEMS"

        sut.display(text: "123456")

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_six_items() {
        let sut = makeSUT(count: 6)
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_SIX_ITEMS"

        sut.display(text: "12345")

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }

    func test_ChunkedTextField_with_model() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_MODEL"

        sut.display(model: .init(text: "4321", isValid: false, isUserInteractionEnabled: true))

        assertSnapshots(of: sut.container, named: snapshotName)
    }

    func test_fail_ChunkedTextField_with_model() {
        let sut = makeSUT()
        let snapshotName = "CHUNKEDTEXTFIELD_WITH_MODEL"

        sut.display(model: .init(text: "4321", isValid: true, isUserInteractionEnabled: true))

        assertFailSnapshots(of: sut.container, named: snapshotName)
    }
}

private extension ChunkedTextFieldSnapshotTests {
    func makeSUT(
        count: Int = 4,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ChunkedTextFieldSnapshotSUT {
        let view = ChunkedTextField(
            count: count,
            appearance: makeAppearance()
        )
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        container.addSubview(view)
        view.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required)
        )
        container.layoutIfNeeded()

        checkForMemoryLeaks(view, file: file, line: line)
        return ChunkedTextFieldSnapshotSUT(view: view, container: container)
    }

    func assertSnapshots(
        of view: UIView,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assert(
            snapshot: view.snapshot(for: .iPhone(style: .light)),
            named: "\(snapshotOSPrefix)_\(name)_LIGHT",
            file: file,
            line: line
        )
        assert(
            snapshot: view.snapshot(for: .iPhone(style: .dark)),
            named: "\(snapshotOSPrefix)_\(name)_DARK",
            file: file,
            line: line
        )
    }

    func assertFailSnapshots(
        of view: UIView,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertFail(
            snapshot: view.snapshot(for: .iPhone(style: .light)),
            named: "\(snapshotOSPrefix)_\(name)_LIGHT",
            file: file,
            line: line
        )
        assertFail(
            snapshot: view.snapshot(for: .iPhone(style: .dark)),
            named: "\(snapshotOSPrefix)_\(name)_DARK",
            file: file,
            line: line
        )
    }

    var snapshotOSPrefix: String {
        if #available(iOS 26.0, *) {
            return "iOS26"
        }
        return "iOS18.5"
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

private final class ChunkedTextFieldSnapshotSUT {
    let view: ChunkedTextField
    let container: UIView

    init(view: ChunkedTextField, container: UIView) {
        self.view = view
        self.container = container
    }

    func display(model: TextInputPresentableModel?) {
        view.display(model: model)
    }

    func display(text: String?) {
        view.display(text: text)
    }

    func display(isValid: Bool) {
        view.display(isValid: isValid)
    }

    func display(isUserInteractionEnabled: Bool) {
        view.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }
}
