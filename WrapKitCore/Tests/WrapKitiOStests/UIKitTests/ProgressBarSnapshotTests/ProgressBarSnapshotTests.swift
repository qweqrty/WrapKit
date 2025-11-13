//
//  ProgressBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 12/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class ProgressBarSnapshotTests: XCTestCase {
    func test_progressBar_defaul_state() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 0.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "PROGRESSBAR_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "PROGRESSBAR_DEFAULT_STATE_DARK")
    }
    
    func test_progressBar_with_progressBar_color() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 100.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "PROGRESSBAR_WITH_PROGRESSBAR_COLOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "PROGRESSBAR_WITH_PROGRESSBAR_COLOR_DARK")
    }
    
    func test_progressBar_with_height() {
        // GIVEN
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 300))
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        let (sut, _) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 50))
        sut.display(progress: 100.0)
        
        window.addSubview(sut)
        sut.anchor(
            .top(window.topAnchor, constant: 10, priority: .required),
            .leading(window.leadingAnchor, constant: 10, priority: .required),
            .trailing(window.trailingAnchor, constant: 10, priority: .required)
        )
        
        // THEN
        assert(snapshot: window.snapshot(for: .iPhone(style: .light)),
               named: "PROGRESSBAR_WITH_HEIGHT_LIGHT")
        assert(snapshot: window.snapshot(for: .iPhone(style: .dark)),
               named: "PROGRESSBAR_WITH_HEIGHT_DARK")
        
        sut.removeFromSuperview()
        window.isHidden = true
        window.resignKey()
    }
    
    func test_progressBar_with_cornerRadius() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            progressBarColor: .cyan,
            height: 10,
            cornerRadius: 10))
        sut.display(progress: 50.0)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "PROGRESSBAR_WITH_CORNDERRADIUS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "PROGRESSBAR_WITH_CORNDERRADIUS_DARK")
    }
    
    func test_progressBar_hidden() {
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(progress: 50.0)
        sut.display(isHidden: true)
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)),
               named: "PROGRESSBAR_HIDDEN_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)),
               named: "PROGRESSBAR_HIDDEN_DARK")
    }
}

extension ProgressBarSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ProgressBarView, container: UIView) {
        let sut = ProgressBarView()
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
