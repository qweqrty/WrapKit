//
//  TitledViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class TitledViewSnapshotTests: XCTestCase {
    func test_titledView_defaul_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_DEFAULT_STATE"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_titledView_defaul_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_DEFAULT_STATE"
        
        // WHEN
        sut.display(titles: .init(.text("First title."), .text("Second title")))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_titledView_with_bottomTitles() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_BOTTOMTTILES"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom"), .text("Second bottom")))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_titledView_with_bottomTitles() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_BOTTOMTTILES"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom."), .text("Second bottom")))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_titledView_with_leadingBottomTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title"))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_titledView_with_leadingBottomTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title."))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_titledView_with_trailingBottomTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title"))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_titledView_with_trailingBottomTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title."))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_titledView_with_isHidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_HIDDEN"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_titledView_with_isHidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        let snapshotName = "TITLEDVIEW_HIDDEN"
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: false)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension TitledViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: TitledView<UIView>, container: UIView) {
        let sut = TitledView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
        )
        
        container.layoutIfNeeded()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
