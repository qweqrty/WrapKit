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
    private let secondImage = Image(systemName: "star")
    
    func test_CardView_default_state() {
        let snapshotName = "CARDVIEW_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_multipleSubtitle_cardView() {
        let snapshotName = "CARDVIEW_MULTIPLE_SUBTITLE_ROW_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            style: makeMultipleSubtitleRowStyle(),
            subTitle: .attributes([
                .init(text: "CardView" + "\n"),
                .init(text: "Subtitle" + "\n"),
                .init(text: "Multiple" + "\n"),
                .init(text: "Row" + "\n")
            ])
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_multipleTitleSubtitle_cardView() {
        let snapshotName = "CARDVIEW_MULTIPLE_TITLE_SUBTITLE_ROW_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(model: .init(
            style: makeMultipleSubtitleRowStyle(),
            title: .text("title"),
            subTitle: .text(
                "40407, 40404, 40424, 40412, 40482, 40419, 40478, 405799, 40487, 40422, 40489, 40456, 40570, 405852, 405850, 40444, 40414, 405848, 405853, 405845, 405849, 405846, 40411, 40405, 40446, 40430, 40427, 40443, 40420"
            )
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_CardView_default_state() {
        let snapshotName = "CARDVIEW_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeAssertFailStyle())
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_backgroundImage() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .init(image: .asset(image)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_backgroundImage() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .init(image: .asset(secondImage)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_backgroundImage_contentModeIsFit_false() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODE_ISFIT_FALSE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .init(image: .asset(image), contentModeIsFit: false))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_backgroundImage_contentModeIsFit_false() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODE_ISFIT_FALSE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .init(image: .asset(image), contentModeIsFit: true))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_backgroundImage_borederWidth_and_color() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_backgroundImage_borederWidth_and_color() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 3,
                                           borderColor: .black))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_backgroundImage_cornderRadius() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image = Image(systemName: "star.fill")
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                          ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_backgroundImage_cornderRadius() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let image = Image(systemName: "star.fill")
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 21,
                                          ))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_backgroundImage_alpha() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                           alpha: 0.3
                                          ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_backgroundImage_alpha() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(backgroundImage: .init(size: .init(width: 24, height: 24),
                                           image: .asset(image),
                                           borderWidth: 4,
                                           borderColor: .black,
                                           cornerRadius: 20,
                                           alpha: 0.4
                                          ))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_leadingTitles() {
        let snapshotName = "CARDVIEW_WITH_LEADINGTITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingTitles:
                .init(.text("First"), .text("Second"))
        )
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_leadingTitles() {
        let snapshotName = "CARDVIEW_WITH_LEADINGTITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingTitles:
                .init(.text("First."), .text("Second"))
        )
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_trailingTitles() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGTITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingTitles: .init(.text("First"), .text("Second")))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_trailingTitles() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGTITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingTitles: .init(.text("First."), .text("Second")))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_leadingImage() {
        let snapshotName = "CARDVIEW_WITH_LEADINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingImage: .init(image: .asset(image)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_leadingImage() {
        let snapshotName = "CARDVIEW_WITH_LEADINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingImage: .init(image: .asset(secondImage)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_trailingImage() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingImage: .init(image: .asset(image)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_trailingImage() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingImage: .init(image: .asset(secondImage)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_secondaryTrailingImage() {
        let snapshotName = "CARDVIEW_WITH_SECONDARYTRAILINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(secondaryTrailingImage: .init(image: .asset(secondImage)))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_secondaryTrailingImage() {
        let snapshotName = "CARDVIEW_WITH_SECONDARYTRAILINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(secondaryTrailingImage: .init(image: .asset(image)))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_subTitle() {
        let snapshotName = "CARDVIEW_WITH_SUBTITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(subTitle: .text("Subtitle"))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_subTitle() {
        let snapshotName = "CARDVIEW_WITH_SUBTITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(subTitle: .text("Subtitle."))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_valueTitle() {
        let snapshotName = "CARDVIEW_WITH_VALUETITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(valueTitle: .text("Value title"))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_valueTitle() {
        let snapshotName = "CARDVIEW_WITH_VALUETITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(valueTitle: .text("Value title."))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_title_value_subtitle() {
        let snapshotName = "CARDVIEW_WITH_TITLE_VALUE_SUBTITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(title: .text("Title"))
        sut.display(subTitle: .text("Subtitle"))
        sut.display(valueTitle: .text("Value title"))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_title_value_subtitle() {
        let snapshotName = "CARDVIEW_WITH_TITLE_VALUE_SUBTITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(title: .text("Title."))
        sut.display(subTitle: .text("Subtitle."))
        sut.display(valueTitle: .text("Value title."))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_bottomSeparator() {
        let snapshotName = "CARDVIEW_WITH_BOTTOM_SEPARATOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .black,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .green,
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
            borderWidth: 0
        ))
        
        sut.display(title: .text("Title"))
        sut.display(bottomSeparator: .init(color: .lightGray, height: 4))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_bottomSeparator() {
        let snapshotName = "CARDVIEW_WITH_BOTTOM_SEPARATOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fillEqually,
            leadingTitleKeyTextColor: .blue,
            titleKeyTextColor: .black,
            trailingTitleKeyTextColor: .black,
            titleValueTextColor: .cyan,
            subTitleTextColor: .green,
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
            borderWidth: 0
        ))
        
        sut.display(title: .text("Title"))
        sut.display(bottomSeparator: .init(color: .gray, height: 4))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_switchControl() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeSwitchControlStyle())
        
        sut.display(title: .text("Title"))
        sut.display(switchControl: .init(
            isOn: true,
            isEnabled: true,
            style: .init(tintColor: .blue, thumbTintColor: .green, backgroundColor: .white, cornerRadius: 10)
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_switchControl() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeSwitchControlStyle())
        
        sut.display(title: .text("Title"))
        sut.display(switchControl: .init(
            isOn: true,
            isEnabled: true,
            style: .init(tintColor: .systemBlue, thumbTintColor: .green, backgroundColor: .white, cornerRadius: 10)
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_with_switchControl_isFalse() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL_ISFALSE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeSwitchControlStyle())
        
        sut.display(title: .text("Title"))
        sut.display(switchControl: .init(
            isOn: false,
            isEnabled: true,
            style: .init(tintColor: .blue, thumbTintColor: .green, backgroundColor: .white, cornerRadius: 10)
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_with_switchControl_isFalse() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL_ISFALSE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(switchControl: .init(
            isOn: true,
            isEnabled: true,
            style: .init(tintColor: .blue, thumbTintColor: .green, backgroundColor: .white, cornerRadius: 10)
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - need to simulate real tap
    func test_CardView_onPress() {
        let snapshotName = "CARDVIEW_WITH_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .systemGreen
        })
        
        sut.onPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_onPress() {
        let snapshotName = "CARDVIEW_WITH_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(onPress: { [weak sut] in
            sut?.backgroundColor = .green
        })
        
        sut.onPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - need to simulate real tap
    func test_CardView_onLongPress() {
        let snapshotName = "CARDVIEW_WITH_ONLONGPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .systemGreen
        })
        
        sut.onLongPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_CardView_onLongPress() {
        let snapshotName = "CARDVIEW_WITH_ONLONGPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
        sut.display(title: .text("Title"))
        sut.display(onLongPress: { [weak sut] in
            sut?.backgroundColor = .green
        })
        
        sut.onLongPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_CardView_isHidden() {
        let snapshotName = "CARDVIEW_ISHIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
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
    
    func test_fail_CardView_isHidden() {
        let snapshotName = "CARDVIEW_ISHIDDEN"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: makeDefaultStyle())
        
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
    
    func test_trailingImageLeadingZero() {
        let snapshotName = "trailingImageLeadingZero"
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = makeDefaultStyle(
            hStackViewDistribution: .fill,
            hStackViewSpacing: 24,
            trailingImageLeadingSpacing: 0,
            secondaryTrailingImageLeadingSpacing: 0
        )
        sut.display(style: style)
        sut.display(model: .init(
            title: .text("Title"),
            leadingImage: .init(image: .asset(image)),
            trailingImage: .init(image: .asset(image)),
            subTitle: .text("subTitle")
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_trailingImageLeadingZeroShouldFail() {
        let snapshotName = "trailingImageLeadingDefault" // correct is "trailingImageLeadingZero"
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = makeDefaultStyle(
            hStackViewDistribution: .fill,
            hStackViewSpacing: 24,
            trailingImageLeadingSpacing: 0,
            secondaryTrailingImageLeadingSpacing: 0
        )
        sut.display(style: style)
        sut.display(model: .init(
            title: .text("Title"),
            leadingImage: .init(image: .asset(image)),
            trailingImage: .init(image: .asset(image)),
            subTitle: .text("subTitle")
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_trailingImageLeadingDefault() {
        let snapshotName = "trailingImageLeadingDefault"
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = makeDefaultStyle(
            hStackViewDistribution: .fill,
            hStackViewSpacing: 24
        )
        sut.display(style: style)
        sut.display(model: .init(
            title: .text("Title"),
            leadingImage: .init(image: .asset(image)),
            trailingImage: .init(image: .asset(image)),
            subTitle: .text("subTitle")
        ))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_trailingImageLeadingDefaultFail() {
        let snapshotName = "trailingImageLeadingZero" // correct is "trailingImageLeadingDefault"
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        let style = makeDefaultStyle(
            hStackViewDistribution: .fill,
            hStackViewSpacing: 24
        )
        sut.display(style: style)
        sut.display(model: .init(
            title: .text("Title"),
            leadingImage: .init(image: .asset(image)),
            trailingImage: .init(image: .asset(image)),
            subTitle: .text("subTitle")
        ))
        
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

extension CardViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: CardView, container: UIView) {
        let sut = CardView()
        let container = makeContainer()
        
        container.addSubview(sut)
        sut.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(200, priority: .required)
        )
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
    
    func makeDefaultStyle(
        backgroundColor: Color = .systemRed,
        vStacklayoutMargins: EdgeInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5),
        hStacklayoutMargins: EdgeInsets = .zero,
        hStackViewDistribution: StackViewDistribution = .fillEqually,
        leadingTitleKeyTextColor: Color = .blue,
        titleKeyTextColor: Color = .brown,
        trailingTitleKeyTextColor: Color = .black,
        titleValueTextColor: Color = .cyan,
        subTitleTextColor: Color = .gray,
        leadingTitleKeyLabelFont: Font = .boldSystemFont(ofSize: 22),
        titleKeyLabelFont: Font = .systemFont(ofSize: 14),
        trailingTitleKeyLabelFont: Font = .boldSystemFont(ofSize: 22),
        titleValueLabelFont: Font = .systemFont(ofSize: 14),
        subTitleLabelFont: Font = .systemFont(ofSize: 14, weight: .light),
        subtitleNumberOfLines: Int = 0,
        cornerRadius: CGFloat = 20,
        roundedCorners: CACornerMask = .allCorners,
        stackSpace: CGFloat = 5.0,
        hStackViewSpacing: CGFloat = 2.0,
        titleKeyNumberOfLines: Int = 0,
        titleValueNumberOfLines: Int = 0,
        borderColor: Color = .green,
        borderWidth: CGFloat = 4,
        gradientBorderColors: [Color]? = nil,
        trailingImageLeadingSpacing: CGFloat? = nil,
        secondaryTrailingImageLeadingSpacing: CGFloat? = nil
    ) -> CardViewPresentableModel.Style {
        return .init(
            backgroundColor: backgroundColor,
            vStacklayoutMargins: vStacklayoutMargins,
            hStacklayoutMargins: hStacklayoutMargins,
            hStackViewDistribution: hStackViewDistribution,
            leadingTitleKeyTextColor: leadingTitleKeyTextColor,
            titleKeyTextColor: titleKeyTextColor,
            trailingTitleKeyTextColor: trailingTitleKeyTextColor,
            titleValueTextColor: titleValueTextColor,
            subTitleTextColor: subTitleTextColor,
            leadingTitleKeyLabelFont: leadingTitleKeyLabelFont,
            titleKeyLabelFont: titleKeyLabelFont,
            trailingTitleKeyLabelFont: trailingTitleKeyLabelFont,
            titleValueLabelFont: titleValueLabelFont,
            subTitleLabelFont: subTitleLabelFont,
            subtitleNumberOfLines: subtitleNumberOfLines,
            cornerRadius: cornerRadius,
            roundedCorners: roundedCorners,
            stackSpace: stackSpace,
            hStackViewSpacing: hStackViewSpacing,
            titleKeyNumberOfLines: titleKeyNumberOfLines,
            titleValueNumberOfLines: titleValueNumberOfLines,
            borderColor: borderColor,
            borderWidth: borderWidth,
            gradientBorderColors: gradientBorderColors,
            trailingImageLeadingSpacing: trailingImageLeadingSpacing,
            secondaryTrailingImageLeadingSpacing: secondaryTrailingImageLeadingSpacing
        )
    }
    
    func makeMultipleSubtitleRowStyle() -> CardViewPresentableModel.Style {
        return .init(
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
            subtitleNumberOfLines: 0,
            cornerRadius: 20,
            stackSpace: 5.0,
            hStackViewSpacing: 2.0,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .green,
            borderWidth: 4
        )
    }
    
    func makeAssertFailStyle() -> CardViewPresentableModel.Style {
        return .init(
            backgroundColor: .red,
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
        )
    }
    
    func makeSwitchControlStyle() -> CardViewPresentableModel.Style {
        return .init(
            backgroundColor: .systemRed,
            vStacklayoutMargins: .init(top: 5, leading: 5, bottom: 5, trailing: 5),
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fill,
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
        )
    }
    
    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
