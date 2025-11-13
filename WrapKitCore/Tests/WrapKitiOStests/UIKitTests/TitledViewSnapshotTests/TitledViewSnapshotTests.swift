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
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "TITLEDVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "TITLEDVIEW_DEFAULT_STATE_DARK")
    }
    
    func test_titledView_with_bottomTitles() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(bottomTitles: .init(.text("First bottom"), .text("Second bottom")))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "TITLEDVIEW_WITH_BOTTOMTTILES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "TITLEDVIEW_WITH_BOTTOMTTILES_DARK")
    }
    
    func test_titledView_with_leadingBottomTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(leadingBottomTitle: .text("Leading bottom title"))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "TITLEDVIEW_WITH_LEADINGBOTTOMM_TITLE_DARK")
    }
    
    func test_titledView_with_trailingBottomTitle() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(trailingBottomTitle: .text("Trailing bottom title"))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "TITLEDVIEW_WITH_TRAILINGBOTTOMM_TITLE_DARK")
    }
    
    func test_titledView_with_isHidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(titles: .init(.text("First title"), .text("Second title")))
        sut.display(isHidden: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "TITLEDVIEW_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "TITLEDVIEW_HIDDEN_DARK")
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
