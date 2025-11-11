//
//  CardViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 11/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

final class CardViewSnapshotTests: XCTestCase {
    
    private let image = Image(systemName: "star.fill")
    
    func test_CardView_default_state() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_DEFAULT_STATE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_DEFAULT_STATE_DARK")
    }
    
    func test_CardView_with_backgroundImage() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        sut.display(backgroundImage: .init(image: .asset(image)))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_DARK")
    }
    
    func test_CardView_with_backgroundImage_contentModeIsFit_false() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        sut.display(backgroundImage: .init(image: .asset(image), contentModeIsFit: false))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODE_ISFIT_FALSELIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODEISFIT_FALSE_DARK")
    }
    
    func test_CardView_with_backgroundImage_borederWidth_and_color() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR_DARK")
    }
    
    func test_CardView_with_backgroundImage_cornderRadius() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        let image = Image(systemName: "star.fill")
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                          ))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS_DARK")
    }
    
    func test_CardView_with_backgroundImage_alpha() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                           alpha: 0.3
                                          ))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA_DARK")
    }
    
    func test_CardView_with_leadingTitles() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        sut.display(leadingTitles:
                .init(.text("First"), .text("Second"))
        )
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_LEADINGTITLES_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_LEAIDNGTITLES_DARK")
    }
    
    func test_CardView_with_trailingTitles() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        sut.display(trailingTitles: .init(.text("First"), .text("Second")))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_TRAILINGTITLES_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_TRAILINGTITLES_DARK")
    }
    
    func test_CardView_with_leadingImage() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        sut.display(leadingImage: .init(image: .asset(image)))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_LEADINGIMAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_LEADINGIMAGE_DARK")
    }
    
    func test_CardView_with_trailingImage() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .brown,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .gray,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleKeyLabelFont: .systemFont(ofSize: 14),
            trailingTitleKeyLabelFont: .boldSystemFont(ofSize: 22),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 14, weight: .light),
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        ))
        
        sut.display(trailingImage: .init(image: .asset(image)))
        
        // THEN
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "CARDVIEW_WITH_TRAILINGIMAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "CARDVIEW_WITH_TRAILINGIMAGE_DARK")
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
