//
//  TitledViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

final class TitledViewSnapshotTests: XCTestCase {

    func test_titledView_defaul_state() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_DEFAULT_STATE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_titledView_defaul_state() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_DEFAULT_STATE"

        sut.display(titles: .init(.text("First title."), .text("Second title")))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_titledView_with_bottomTitles() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_BOTTOMTTILES"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom"), .text("Second bottom")))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_titledView_with_bottomTitles() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_BOTTOMTTILES"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom."), .text("Second bottom")))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_titledView_with_leadingBottomTitle() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title"))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_titledView_with_leadingBottomTitle() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title."))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_titledView_with_trailingBottomTitle() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title"))

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_titledView_with_trailingBottomTitle() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title."))

        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_titledView_with_isHidden() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_HIDDEN"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: true)

        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_titledView_with_isHidden() {
        let sut = makeSUT()
        let snapshotName = "TITLEDVIEW_HIDDEN"

        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: false)

        assertFail(snapshot: sut, named: snapshotName)
    }
}

private extension TitledViewSnapshotTests {
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> PairedTitledViewSnapshotSUT {
        let container = makeContainer()
        let sut = PairedTitledViewSnapshotSUT(uiKitContainer: container)

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
