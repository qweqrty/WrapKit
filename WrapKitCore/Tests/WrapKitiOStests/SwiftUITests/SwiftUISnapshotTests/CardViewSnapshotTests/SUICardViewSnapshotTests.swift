//
//  SUICardViewSnapshotTests.swift
//  WrapKitTests
//
//  Created by Urmatbek Marat Uulu on 11/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest

@available(iOS 17.0, *)
final class SUICardViewSnapshotTests: XCTestCase {
    func test_CardView_default_state() {
        let snapshotName = "CARDVIEW_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_multipleSubtitle_cardView() {
        let snapshotName = "CARDVIEW_MULTIPLE_SUBTITLE_ROW_STATE"

        // GIVEN
        let sut = makeSUT()

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
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_multipleTitleSubtitle_cardView() {
        let snapshotName = "CARDVIEW_MULTIPLE_TITLE_SUBTITLE_ROW_STATE"

        // GIVEN
        let sut = makeSUT()

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
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_default_state() {
        let snapshotName = "CARDVIEW_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeAssertFailStyle())

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_backgroundImage() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .systemSymbol("star.fill"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_backgroundImage() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle(backgroundColor: .blue))
        sut.display(backgroundImage: .systemSymbol("star"))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_backgroundImage_contentModeIsFit_false() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODE_ISFIT_FALSE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(backgroundImage: .systemSymbol("star.fill", contentModeIsFit: false))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_backgroundImage_contentModeIsFit_false() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CONTENTMODE_ISFIT_FALSE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle(backgroundColor: .blue))
        sut.display(backgroundImage: .systemSymbol("star.fill", contentModeIsFit: true))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_backgroundImage_borederWidth_and_color() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(backgroundImage: .systemSymbol(
            "star.fill",
            size: .init(width: 24, height: 24),
            borderWidth: 4,
            borderColor: .black
        ))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_backgroundImage_borederWidth_and_color() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_BORDERWIDTH_AND_COLOR"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(backgroundImage: .systemSymbol(
            "star.fill",
            size: .init(width: 24, height: 24),
            borderWidth: 3,
            borderColor: .black
        ))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_backgroundImage_cornderRadius() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(backgroundImage: .systemSymbol(
            "star.fill",
            size: .init(width: 24, height: 24),
            borderWidth: 4,
            borderColor: .black,
            cornerRadius: 20
        ))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_backgroundImage_cornderRadius() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_CORNERRADIUS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(backgroundImage: .systemSymbol(
            "star.fill",
            size: .init(width: 24, height: 24),
            borderWidth: 4,
            borderColor: .black,
            cornerRadius: 21
        ))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_backgroundImage_alpha() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(backgroundImage: .systemSymbol(
            "star.fill",
            size: .init(width: 24, height: 24),
            borderWidth: 4,
            borderColor: .black,
            cornerRadius: 20,
            alpha: 0.3
        ))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_backgroundImage_alpha() {
        let snapshotName = "CARDVIEW_WITH_BACKGROUNDIMAGE_ALPHA"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(backgroundImage: .systemSymbol(
            "star.fill",
            size: .init(width: 24, height: 24),
            borderWidth: 4,
            borderColor: .black,
            cornerRadius: 20,
            alpha: 0.4
        ))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_leadingTitles() {
        let snapshotName = "CARDVIEW_WITH_LEADINGTITLES"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingTitles:
                .init(.text("First"), .text("Second"))
        )

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_leadingTitles() {
        let snapshotName = "CARDVIEW_WITH_LEADINGTITLES"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingTitles:
                .init(.text("First."), .text("Second"))
        )

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_trailingTitles() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGTITLES"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingTitles: .init(.text("First"), .text("Second")))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_trailingTitles() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGTITLES"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingTitles: .init(.text("First."), .text("Second")))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_leadingImage() {
        let snapshotName = "CARDVIEW_WITH_LEADINGIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(leadingImage: .systemSymbol("star.fill"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_leadingImage() {
        let snapshotName = "CARDVIEW_WITH_LEADINGIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle(backgroundColor: .blue))
        sut.display(leadingImage: .systemSymbol("star"))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_trailingImage() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(trailingImage: .systemSymbol("star.fill"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_trailingImage() {
        let snapshotName = "CARDVIEW_WITH_TRAILINGIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle(backgroundColor: .blue))
        sut.display(trailingImage: .systemSymbol("star"))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_secondaryTrailingImage() {
        let snapshotName = "CARDVIEW_WITH_SECONDARYTRAILINGIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(secondaryTrailingImage: .systemSymbol("star"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_secondaryTrailingImage() {
        let snapshotName = "CARDVIEW_WITH_SECONDARYTRAILINGIMAGE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle(backgroundColor: .blue))
        sut.display(secondaryTrailingImage: .systemSymbol("star.fill"))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_subTitle() {
        let snapshotName = "CARDVIEW_WITH_SUBTITLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(subTitle: .text("Subtitle"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_subTitle() {
        let snapshotName = "CARDVIEW_WITH_SUBTITLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(subTitle: .text("Subtitle."))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_valueTitle() {
        let snapshotName = "CARDVIEW_WITH_VALUETITLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(valueTitle: .text("Value title"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_valueTitle() {
        let snapshotName = "CARDVIEW_WITH_VALUETITLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(valueTitle: .text("Value title."))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_title_value_subtitle() {
        let snapshotName = "CARDVIEW_WITH_TITLE_VALUE_SUBTITLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(title: .text("Title"))
        sut.display(subTitle: .text("Subtitle"))
        sut.display(valueTitle: .text("Value title"))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_title_value_subtitle() {
        let snapshotName = "CARDVIEW_WITH_TITLE_VALUE_SUBTITLE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())
        sut.display(title: .text("Title."))
        sut.display(subTitle: .text("Subtitle."))
        sut.display(valueTitle: .text("Value title."))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_bottomSeparator() {
        let snapshotName = "CARDVIEW_WITH_BOTTOM_SEPARATOR"

        // GIVEN
        let sut = makeSUT()

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
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_bottomSeparator() {
        let snapshotName = "CARDVIEW_WITH_BOTTOM_SEPARATOR"

        // GIVEN
        let sut = makeSUT()

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
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_switchControl() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL"

        // GIVEN
        let sut = makeSUT()

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
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_switchControl() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL"

        // GIVEN
        let sut = makeSUT()

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
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_with_switchControl_isFalse() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL_ISFALSE"

        // GIVEN
        let sut = makeSUT()

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
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_with_switchControl_isFalse() {
        let snapshotName = "CARDVIEW_WITH_SWITCHCONTROL_ISFALSE"

        // GIVEN
        let sut = makeSUT()

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
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_postOnPressOutputVisualState() {
        let snapshotName = "CARDVIEW_WITH_ONPRESS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(title: .text("Title"))
        let pressedStyle = makeDefaultStyle(backgroundColor: .systemGreen)
        var pressCount = 0
        let onPress: () -> Void = { [weak sut] in
            pressCount += 1
            sut?.display(style: pressedStyle)
        }
        sut.display(onPress: onPress)

        XCTContext.runActivity(named: "Post-callback visual state; gesture delivery is not a snapshot concern") { _ in
            XCTAssertTrue(sut.invokeSwiftUIStoredOnPressOutputForPostStateSnapshot())
            XCTAssertEqual(pressCount, 1)
        }

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_postOnPressOutputVisualState() {
        let snapshotName = "CARDVIEW_WITH_ONPRESS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(title: .text("Title"))
        let pressedStyle = makeDefaultStyle(backgroundColor: .green)
        var pressCount = 0
        let onPress: () -> Void = { [weak sut] in
            pressCount += 1
            sut?.display(style: pressedStyle)
        }
        sut.display(onPress: onPress)

        XCTContext.runActivity(named: "Post-callback visual state; gesture delivery is not a snapshot concern") { _ in
            XCTAssertTrue(sut.invokeSwiftUIStoredOnPressOutputForPostStateSnapshot())
            XCTAssertEqual(pressCount, 1)
        }

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_postOnLongPressOutputVisualState() {
        let snapshotName = "CARDVIEW_WITH_ONLONGPRESS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(title: .text("Title"))
        let pressedStyle = makeDefaultStyle(backgroundColor: .systemGreen)
        var longPressCount = 0
        let onLongPress: () -> Void = { [weak sut] in
            longPressCount += 1
            sut?.display(style: pressedStyle)
        }
        sut.display(onLongPress: onLongPress)

        XCTContext.runActivity(named: "Post-callback visual state; gesture delivery is not a snapshot concern") { _ in
            XCTAssertTrue(sut.invokeSwiftUIStoredOnLongPressOutputForPostStateSnapshot())
            XCTAssertEqual(longPressCount, 1)
        }

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_postOnLongPressOutputVisualState() {
        let snapshotName = "CARDVIEW_WITH_ONLONGPRESS"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(title: .text("Title"))
        let pressedStyle = makeDefaultStyle(backgroundColor: .green)
        var longPressCount = 0
        let onLongPress: () -> Void = { [weak sut] in
            longPressCount += 1
            sut?.display(style: pressedStyle)
        }
        sut.display(onLongPress: onLongPress)

        XCTContext.runActivity(named: "Post-callback visual state; gesture delivery is not a snapshot concern") { _ in
            XCTAssertTrue(sut.invokeSwiftUIStoredOnLongPressOutputForPostStateSnapshot())
            XCTAssertEqual(longPressCount, 1)
        }

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_CardView_isHidden() {
        let snapshotName = "CARDVIEW_ISHIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(isHidden: true)

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_fail_CardView_isHidden() {
        let snapshotName = "CARDVIEW_ISHIDDEN"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: makeDefaultStyle())

        sut.display(isHidden: false)

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_trailingImageLeadingZero() {
        let snapshotName = "trailingImageLeadingZero"
        // GIVEN
        let sut = makeSUT()

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
            leadingImage: .systemSymbol("star.fill"),
            trailingImage: .systemSymbol("star.fill"),
            subTitle: .text("subTitle")
        ))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_trailingImageLeadingZeroShouldFail() {
        let snapshotName = "trailingImageLeadingDefault" // correct is "trailingImageLeadingZero"
        // GIVEN
        let sut = makeSUT()

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
            leadingImage: .systemSymbol("star.fill"),
            trailingImage: .systemSymbol("star.fill"),
            subTitle: .text("subTitle")
        ))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }

    func test_trailingImageLeadingDefault() {
        let snapshotName = "trailingImageLeadingDefault"
        // GIVEN
        let sut = makeSUT()

        // WHEN
        let style = makeDefaultStyle(
            hStackViewDistribution: .fill,
            hStackViewSpacing: 24
        )
        sut.display(style: style)
        sut.display(model: .init(
            title: .text("Title"),
            leadingImage: .systemSymbol("star.fill"),
            trailingImage: .systemSymbol("star.fill"),
            subTitle: .text("subTitle")
        ))

        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        } else {
            assert(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.standard)
            assert(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.standard)
        }
    }

    func test_trailingImageLeadingDefaultFail() {
        let snapshotName = "trailingImageLeadingZero" // correct is "trailingImageLeadingDefault"
        // GIVEN
        let sut = makeSUT()

        // WHEN
        let style = makeDefaultStyle(
            hStackViewDistribution: .fill,
            hStackViewSpacing: 24
        )
        sut.display(style: style)
        sut.display(model: .init(
            title: .text("Title"),
            leadingImage: .systemSymbol("star.fill"),
            trailingImage: .systemSymbol("star.fill"),
            subTitle: .text("subTitle")
        ))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS26_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS26_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        } else {
            assertFail(snapshot: sut.swiftUISnapshot(for: .light), named: "SwiftUI_iOS18.5_\(snapshotName)_LIGHT", precision: SwiftUISnapshotPrecision.fail)
            assertFail(snapshot: sut.swiftUISnapshot(for: .dark), named: "SwiftUI_iOS18.5_\(snapshotName)_DARK", precision: SwiftUISnapshotPrecision.fail)
        }
    }
}

@available(iOS 17.0, *)
extension SUICardViewSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUICardViewSnapshotSUT {
        let container = makeContainer()
        let sut = SwiftUICardViewSnapshotSUT(uiKitContainer: container)
        container.backgroundColor = .clear
        container.isOpaque = false

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
            .height(200, priority: .required)
        )

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
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

    func makeWrappedTitleMarginsContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(origin: .zero, size: SnapshotConfiguration.size)
        container.backgroundColor = .red

        let stackView = StackView(
            axis: .vertical,
            spacing: 24,
            contentInset: .init(top: 24, left: 24, bottom: 24, right: 24)
        )
        container.addSubview(stackView)
        stackView.anchor(
            .top(container.topAnchor),
            .leading(container.leadingAnchor),
            .trailing(container.trailingAnchor)
        )

        stackView.addArrangedSubview(makeWrappedTitleMarginsWrapperView(
            title: "Короткий пример текста для проверки отступов"
        ))
        stackView.addArrangedSubview(makeWrappedTitleMarginsWrapperView(
            title: "Длинный пример текста для проверки переноса на вторую строку внутри карточки"
        ))
        stackView.addArrangedSubview(UIView())
        container.layoutIfNeeded()
        return container
    }

    func makeWrappedTitleMarginsWrapperView(title: String) -> WrapperView<CardView> {
        return WrapperView(
            contentView: makeWrappedTitleMarginsCardView(title: title),
            contentViewConstraints: { contentView, superView in
                contentView.anchor(
                    .top(superView.topAnchor),
                    .trailingLessThanEqual(superView.trailingAnchor),
                    .leading(superView.leadingAnchor),
                    .bottom(superView.bottomAnchor)
                )
            }
        )
    }

    func makeWrappedTitleMarginsCardView(title: String) -> CardView {
        let cardView = CardView()
        cardView.display(style: makeDefaultStyle(
            backgroundColor: .systemGray5,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .init(horizontal: 6, vertical: 4),
            hStackViewDistribution: .fill,
            titleKeyTextColor: .label,
            titleKeyLabelFont: .systemFont(ofSize: 13),
            cornerRadius: 14,
            stackSpace: 0,
            hStackViewSpacing: 4,
            titleKeyNumberOfLines: 0,
            titleValueNumberOfLines: 0,
            borderColor: .clear,
            borderWidth: 0
        ))
        cardView.display(title: .text(title))

        return cardView
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
