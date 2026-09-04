//
//  SUINavigationBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by sunflow on 10/11/25.
//

import UIKit
import WrapKit
import WrapKitTestUtils
import XCTest

class SUINavigationBarSnapshotTests: XCTestCase {
    func test_navigationBar_defaul_state() {
        let snapshotName = "NAVBAR_DEFAULT_STATE"

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
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_defaul_state() {
        let snapshotName = "NAVBAR_DEFAULT_STATE"

        // GIVEN
        let sut = makeSUT()

        // WHEN
        sut.display(style: .init(
            backgroundColor: .systemRed,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_centerView_keyValue() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_KEYVALUE"

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

        sut.display(centerView: .keyValue(.init(.text("First"), .text("Second"))))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_centerView_keyValue() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_KEYVALUE"

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

        sut.display(centerView: .keyValue(.init(.text("First."), .text("Second"))))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_centerView_titleImage() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE"

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
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_centerView_titleImage() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE"

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
                          image: .asset(Image(systemName: "star")))),
                      .text("Title"))))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_backgoundImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE"

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

        sut.display(leadingCard: .init(backgroundImage: .init(image: .asset(Image(systemName: "star.fill"))), title: .text("Title"), onPress: { }))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_backgoundImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE"

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

        sut.display(leadingCard: .init(backgroundImage: .init(image: .asset(Image(systemName: "star"))), title: .text("Title")))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_trailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES"

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
            leadingCard: .init(
                backgroundImage: .init(
                    size: CGSize(width: 24, height: 24),
                    image: .asset(Image(systemName: "star.fill"))),
                trailingTitles: .init(.text("Title"), .text("Subtitle")),
                onPress: { }
            ))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_trailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES"

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
            leadingCard: .init(
                backgroundImage: .init(
                    size: CGSize(width: 24, height: 24),
                    image: .asset(Image(systemName: "star.fill"))),
                trailingTitles: .init(.text("Title."), .text("Subtitle."))))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    // MARK: - func display(secondaryTrailingImage:) tests
    func test_navigationBar_with_secondaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE"

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

        let image = Image(systemName: "star.fill")
        sut.display(secondaryTrailingImage: .init(title: "Image", image: image))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_secondaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE"

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

        let image = Image(systemName: "star")
        sut.display(secondaryTrailingImage: .some(.init(title: "Image", image: image, height: 24)))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_postSecondaryTrailingOnPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_ON_PRESS"

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

        let image = Image(systemName: "star.fill")
        let pressedStyle = makeSnapshotStyle(backgroundColor: .yellow)
        let onPress: () -> Void = { }
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            height: 24,
            onPress: onPress)
        ))

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_postSecondaryTrailingOnPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_ON_PRESS"

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

        let image = Image(systemName: "star.fill")
        let pressedStyle = makeSnapshotStyle(backgroundColor: .systemYellow)
        let onPress: () -> Void = { }
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            height: 24,
            onPress: onPress)
        ))

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_tertiaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE"

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

        let image = Image(systemName: "star.fill")
        sut.display(tertiaryTrailingImage: .some(.init(
            title: "Image",
            image: image
        )))

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_tertiaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE"

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

        let image = Image(systemName: "star")
        sut.display(tertiaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            height: 24,
        )))

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_postTertiaryTrailingOnPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_ONPRESS"

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

        let image = Image(systemName: "star.fill")
        let pressedStyle = makeSnapshotStyle(backgroundColor: .yellow)
        let onPress: () -> Void = { }
        sut.display(tertiaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            onPress: onPress
        )))

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_postTertiaryTrailingOnPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_ONPRESS"

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

        let image = Image(systemName: "star.fill")
        let pressedStyle = makeSnapshotStyle(backgroundColor: .systemYellow)
        let onPress: () -> Void = { }
        sut.display(tertiaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            height: 24,
            onPress: onPress
        )))

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_tertiaryAndSecondary_trailingImages() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGES"

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

        let image = Image(systemName: "star.fill")
        let pressedStyle = makeSnapshotStyle(backgroundColor: .yellow)
        let onPress: () -> Void = { }

        sut.display(tertiaryTrailingImage: .some(.init(
            title: "Tert",
            image: image,
            onPress: onPress)
        ))

        sut.display(secondaryTrailingImage: .some(.init(
            title: "Second",
            image: image,
            onPress: onPress)
        ))

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_tertiaryAndSecondary_trailingImages() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGES"

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

        let image = Image(systemName: "star")
        let pressedStyle = makeSnapshotStyle(backgroundColor: .yellow)
        let onPress: () -> Void = { }

        sut.display(tertiaryTrailingImage: .some(.init(
            title: "Tert",
            image: image,
            height: 24,
            onPress: onPress)
        ))

        sut.display(secondaryTrailingImage: .some(.init(
            title: "Second",
            image: image,
            height: 24,
            onPress: onPress)
        ))

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_hidden_state() {
        let snapshotName = "NAVBAR_HIDDEN_STATE"

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

        sut.display(isHidden: true)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_hidden_state() {
        let snapshotName = "NAVBAR_HIDDEN_STATE"

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

        sut.display(isHidden: false)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_leadingTrailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_TITLES"

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
            leadingCard: .init(
                title: .text("Title"),
                leadingTitles: .init(.text("First title"), .text("Second title")),
                trailingTitles: .init(.text("First title"), .text("Second title"))
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_leadingTrailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_TITLES"

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
            leadingCard: .init(
                title: .text("Title"),
                leadingTitles: .init(.text("First title."), .text("Second title")),
                trailingTitles: .init(.text("First title"), .text("Second title"))
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_leadingTrailingImages() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_IMAGES"

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

        let image = Image(systemName: "star.fill")

        sut.display(
            leadingCard: .init(
                title: .text("Title"),
                leadingImage: .init(image: .asset(image)),
                trailingImage: .init(image: .asset(image))
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_leadingTrailingImages() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_IMAGES"

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

        let image = Image(systemName: "star.fill")

        sut.display(
            leadingCard: .init(
                title: .text("Title."),
                leadingImage: .init(image: .asset(image)),
                trailingImage: .init(image: .asset(image))
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_subtitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SUBTITLE"

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
            leadingCard: .init(
                title: .text("Title"),
                subTitle: .text("Subtitle")
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_subtitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SUBTITLE"

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
            leadingCard: .init(
                title: .text("Title"),
                subTitle: .text("Subtitle.")
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_valueTitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_VALUETITLE"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title")
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_valueTitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_VALUETITLE"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title.")
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_bottomImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMIMAGE"

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

        let image = Image(systemName: "star.fill")

        sut.display(
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                bottomImage: .init(image: .asset(image))
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_bottomImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMIMAGE"

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

        let image = Image(systemName: "star")

        sut.display(
            leadingCard: .init(
                title: .text("Title."),
                valueTitle: .text("Value title"),
                bottomImage: .init(image: .asset(image))
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_bottomSeparator() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMSEPARATOR"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                bottomSeparator: .init(color: .black, height: 2)
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_bottomSeparator() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMSEPARATOR"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                bottomSeparator: .init(color: .black, height: 1)
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_switchControl() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SWITCHCONTROL"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                switchControl: .init(
                    isOn: true,
                    isEnabled: true,
                    style: .init(
                        tintColor: .black,
                        thumbTintColor: .red,
                        backgroundColor: .clear,
                        cornerRadius: 10)),
                onPress: { }
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_with_leadingCard_switchControl() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SWITCHCONTROL"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                switchControl: .init(
                    isOn: true,
                    isEnabled: true,
                    style: .init(
                        tintColor: .blue,
                        thumbTintColor: .systemRed,
                        backgroundColor: .clear,
                        cornerRadius: 10))
            )
        )

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_postLeadingCardOnPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONPRESS"

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

        let pressedStyle = makeSnapshotStyle(backgroundColor: .yellow)
        let onPress: () -> Void = { }
        sut.display(
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                onPress: onPress
            )
        )

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_postLeadingCardOnPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONPRESS"

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

        let pressedStyle = makeSnapshotStyle(backgroundColor: .systemYellow)
        let onPress: () -> Void = { }
        sut.display(
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                onPress: onPress
            )
        )

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_postLeadingCardOnLongPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONLONGPRESS"

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

        let pressedStyle = makeSnapshotStyle(backgroundColor: .yellow)
        let onLongPress: () -> Void = { }
        sut.display(
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                onLongPress: onLongPress
            )
        )

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

    func test_fail_navigationBar_postLeadingCardOnLongPressOutputVisualState() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONLONGPRESS"

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

        let pressedStyle = makeSnapshotStyle(backgroundColor: .systemYellow)
        let onLongPress: () -> Void = { }
        sut.display(
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title"),
                onLongPress: onLongPress
            )
        )

        applyPostCallbackOutputState(pressedStyle, on: sut)

        // THEN
        assertFail(snapshot: sut, named: snapshotName)
    }

    func test_navigationBar_with_leadingCard_withoutCallbacks_visualState() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_NO_GESTURE_RECOGNIZERS"

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
            leadingCard: .init(
                title: .text("Title"),
                valueTitle: .text("Value title")
            )
        )

        // THEN
        assert(snapshot: sut, named: snapshotName)
    }

}

private extension SUINavigationBarSnapshotTests {
    func applyPostCallbackOutputState(
        _ style: HeaderPresentableModel.Style,
        on sut: SwiftUINavigationBarSnapshotSUT
    ) {
        XCTContext.runActivity(
            named: "Post-callback Output state; gesture delivery is not asserted by snapshots"
        ) { _ in
            sut.display(style: style)
        }
    }

    func makeSnapshotStyle(backgroundColor: Color) -> HeaderPresentableModel.Style {
        .init(
            backgroundColor: backgroundColor,
            horizontalSpacing: 1,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green
        )
    }

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SwiftUINavigationBarSnapshotSUT {
        let container = makeContainer()
        let sut = SwiftUINavigationBarSnapshotSUT(uiKitContainer: container)

        container.addSubview(sut.uiKitView)
        sut.uiKitView.anchor(
            .top(container.topAnchor, constant: 0, priority: .required),
            .leading(container.leadingAnchor, constant: 0, priority: .required),
            .trailing(container.trailingAnchor, constant: 0, priority: .required),
        )

        container.layoutIfNeeded()

        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(sut.uiKitView, file: file, line: line)
        return sut
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        container.backgroundColor = .clear
        return container
    }
}
