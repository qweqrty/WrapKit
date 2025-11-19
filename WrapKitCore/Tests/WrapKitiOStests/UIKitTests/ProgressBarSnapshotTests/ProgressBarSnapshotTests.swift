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
        let snapshotName = "PROGRESSBAR_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 0.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_progressBar_with_progressBar_color() {
        let snapshotName = "PROGRESSBAR_WITH_PROGRESSBAR_COLOR"
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(backgroundColor: .systemRed, height: 5.0))
        sut.display(progress: 100.0)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_progressBar_with_height() {
        let snapshotName = "PROGRESSBAR_WITH_HEIGHT"
        
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
        if #available(iOS 26, *) {
            assert(snapshot: window.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: window.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: window.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: window.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
        
        sut.removeFromSuperview()
        window.isHidden = true
        window.resignKey()
    }
    
    func test_progressBar_with_cornerRadius() {
        let snapshotName = "PROGRESSBAR_WITH_CORNDERRADIUS"
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
    }
    
    func test_progressBar_hidden() {
        let snapshotName = "PROGRESSBAR_HIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(progress: 50.0)
        sut.display(isHidden: true)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else if #available(iOS 18.3.1, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.3.1_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.3.1_\(snapshotName)_DARK")
        } else {
            XCTFail("Please download given os in Xcode Manage Run Destinations...")
        }
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
