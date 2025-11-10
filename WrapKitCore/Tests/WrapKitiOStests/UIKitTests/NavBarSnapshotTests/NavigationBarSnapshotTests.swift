//
//  NavigationBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by sunflow on 10/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

class NavigationBarSnapshotTests: XCTestCase {
    
    func test_navigationBar_defaul_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_DEFAULT_STATE_DARK")
    }
    
    // TODO: - second value doesnt appear
    func test_navigationBar_with_centerView_keyValue() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_CENTERVIEW_KEYVALUE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_CENTERVIEW_KEYVALUE_DARK")
    }
    
    // TODO: - title doesnt appear
    func test_navigationBar_with_centerView_titleImage() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        sut.display(
            centerView: .titledImage(
                .init(.some(
                    .init(size: CGSize(width: 24, height: 24),
                          image: .asset(Image(systemName: "star.fill")))),
                      .text("Title"))))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE_DARK")
    }
    
    // TODO: - maybe wrong title apperance. need to ask
    func test_navigationBar_with_leadingCard_backgoundImage() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        sut.display(leadingCard: .init(backgroundImage: .init(size: CGSize(width: 25, height: 25), image: .asset(Image(systemName: "star.fill"))), title: .text("Title")))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE_DARK")
    }
    
    func test_navigationBar_with_leadingCard_trailingTitles() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        sut.display(leadingCard: .init(backgroundImage: .init(size: CGSize(width: 24, height: 24), image: .asset(Image(systemName: "star.fill"))),trailingTitles: .init(.text("Title"), .text("Subtitle"))))
        
        // THEN
        record(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES_LIGHT")
        record(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES_DARK")
    }
    
}

extension NavigationBarSnapshotTests {
    func makeSUT(
            file: StaticString = #file,
            line: UInt = #line
        ) -> NavigationBar {
            let sut = NavigationBar()
            
            sut.frame = .init(origin: .zero, size: SnapshotConfiguration.size)
            checkForMemoryLeaks(sut, file: file, line: line)
            return sut
        }
}
