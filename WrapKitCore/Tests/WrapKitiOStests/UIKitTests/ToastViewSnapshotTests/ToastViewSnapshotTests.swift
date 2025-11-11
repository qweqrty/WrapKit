//
//  ToastViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 11/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

class ToastViewSnapshotTests: XCTestCase {
    func test_ToastView_default_state() {
        // GIVEN
        let sut = makeSUT()
        let exp = expectation(description: "Wait for complition")
        
        sut.cardView.display(model: .init(
            style: makeDefaultStyle(),
            title: .text("Toast Message")
        ))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak sut] in
            sut?.show()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                exp.fulfill()
            }
        }
    
        wait(for: [exp], timeout: 2.0)
        
        // THEN
        record(snapshot: sut.snapshot(for: .iPhone(style: .light)),
               named: "TOASTVIEW_DEFAULT_STATE_LIGHT")
        record(snapshot: sut.snapshot(for: .iPhone(style: .dark)),
               named: "TOASTVIEW_DAFULT_STATE_DARK")
    }
}

extension ToastViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ToastView {
        let sut = ToastView(position: .top)
        
        checkForMemoryLeaks(sut, file: file, line: line)
        sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
        return sut
    }
    
    func makeDefaultStyle() -> CardViewPresentableModel.Style {
        return .init(
            backgroundColor: .green,
            vStacklayoutMargins: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .black,
            titleKeyTextColor: .black,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .gray,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleKeyLabelFont: .boldSystemFont(ofSize: 15),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 13),
            cornerRadius: 12,
            stackSpace: 4,
            hStackViewSpacing: 12,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .lightGray,
            borderWidth: 1
        )
    }
}
