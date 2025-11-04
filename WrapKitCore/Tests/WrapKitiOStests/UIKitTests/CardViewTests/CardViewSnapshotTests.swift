//
//  CardViewSnapshotTests.swift
//  WrapKit
//
//  Created by sunflow on 3/11/25.
//

import WrapKit
import XCTest
import WrapKitTestUtils

class CardViewSnapshotTests: XCTestCase {
    func test_cardView_defaultState() {
        // GIVEN
        let sut = makeSUT()
        
        sut.display(model: .init(title: .text("Blabla")))
        
        // ASSERT
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARD_VIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARD_VIEW_DEFAULT_STATE_DARK")
    }
}

extension CardViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> CardView {
        let sut = CardView()
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        return sut
    }
}

fileprivate extension CardViewPresentableModel.Style {
}
