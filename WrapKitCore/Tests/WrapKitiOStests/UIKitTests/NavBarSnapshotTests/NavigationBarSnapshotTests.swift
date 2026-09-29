//
//  NavigationBarSnapshotTests.swift
//  WrapKitTests
//
//  Created by sunflow on 10/11/25.
//

import WrapKit
import WrapKitTestUtils
import XCTest
import UIKit

class NavigationBarSnapshotTests: XCTestCase {
    
    func test_navigationBar_defaul_state() {
        let snapshotName = "NAVBAR_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_defaul_state() {
        let snapshotName = "NAVBAR_DEFAULT_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_centerView_keyValue() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_KEYVALUE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_centerView_keyValue() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_KEYVALUE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_centerView_titleImage() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_centerView_titleImage() {
        let snapshotName = "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_backgoundImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        sut.display(leadingCard: .init(backgroundImage: .init(size: .init(width: 120, height: 44), image: .asset(Image(systemName: "star.fill"))), title: .text("Title")))
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_backgoundImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
        // WHEN
        sut.display(style: .init(
            backgroundColor: .red,
            horizontalSpacing: 1.0,
            primeFont: .boldSystemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: .systemFont(ofSize: 14),
            secondaryColor: .green)
        )
        
        sut.display(leadingCard: .init(backgroundImage: .init(size: .init(width: 120, height: 44), image: .asset(Image(systemName: "star"))), title: .text("Title")))
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_trailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
                trailingTitles: .init(.text("Title"), .text("Subtitle")),
                leadingImage: .init(
                    size: CGSize(width: 24, height: 24),
                    image: .asset(Image(systemName: "star.fill")))
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
    
    func test_fail_navigationBar_with_leadingCard_trailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
                trailingTitles: .init(.text("Title."), .text("Subtitle.")),
                leadingImage: .init(
                    size: CGSize(width: 24, height: 24),
                    image: .asset(Image(systemName: "star.fill")))))

        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // MARK: - func display(secondaryTrailingImage:) tests
    func test_navigationBar_with_secondaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_secondaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_secondaryTrailingImage_onPress() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_ON_PRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            height: 24,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
            })
        ))
        
        findView(Button.self, in: sut.topItem?.rightBarButtonItems?.last?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .yellow)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func test_fail_navigationBar_with_secondaryTrailingImage_onPress() {
        let snapshotName = "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_ON_PRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Image",
            image: image,
            height: 24,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .systemYellow))
            })
        ))
        
        findView(Button.self, in: sut.topItem?.rightBarButtonItems?.last?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .systemYellow)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_tertiaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_tertiaryTrailingImage() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_tertiaryTrailingImage_onPress() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
            image: image,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
            }
        )))
        
        findView(Button.self, in: sut.topItem?.rightBarButtonItems?.first?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .yellow)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_tertiaryTrailingImage_onPress() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
            image: image,
            height: 24,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .systemYellow))
            }
        )))
        
        findView(Button.self, in: sut.topItem?.rightBarButtonItems?.first?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .systemYellow)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_tertiaryAndSecondary_trailingImages() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
            title: "Tert",
            image: image,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
            })
        ))
        
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Second",
            image: image,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
            })
        ))
        
        findView(Button.self, in: sut.topItem?.rightBarButtonItems?.last?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .yellow)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_tertiaryAndSecondary_trailingImages() {
        let snapshotName = "NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
            title: "Tert",
            image: image,
            height: 24,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
            })
        ))
        
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Second",
            image: image,
            height: 24,
            onPress: { [weak sut] in
                sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
            })
        ))
        
        findView(Button.self, in: sut.topItem?.rightBarButtonItems?.last?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .yellow)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_hidden_state() {
        let snapshotName = "NAVBAR_HIDDEN_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_hidden_state() {
        let snapshotName = "NAVBAR_HIDDEN_STATE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_leadingTrailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_TITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
        guard let card = findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView) else {
            return XCTFail("Expected a leading card")
        }
        let labels = [
            card.leadingTitleViews.keyLabel, card.leadingTitleViews.valueLabel,
            card.titleViews.keyLabel,
            card.trailingTitleViews.keyLabel, card.trailingTitleViews.valueLabel
        ]
        for label in labels {
            XCTAssertGreaterThanOrEqual(
                label.bounds.width + 1, label.intrinsicContentSize.width,
                "Truncated: \(label.text ?? "")"
            )
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_leadingTrailingTitles() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_TITLES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_leadingTrailingImages() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_IMAGES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_leadingTrailingImages() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_IMAGES"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_subtitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SUBTITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_subtitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SUBTITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_valueTitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_VALUETITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_valueTitle() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_VALUETITLE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    // TODO: - bottom image doesnt appear
    func test_navigationBar_with_leadingCard_bottomImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_bottomImage() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMIMAGE"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_bottomSeparator() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMSEPARATOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_bottomSeparator() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_BOTTOMSEPARATOR"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_switchControl() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SWITCHCONTROL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_switchControl() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_SWITCHCONTROL"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_onPress() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
                onPress: { [weak sut] in
                    sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
                }
            )
        )
        
        findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .yellow)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_onPress() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
                onPress: { [weak sut] in
                    sut?.display(style: Self.headerStyle(backgroundColor: .systemYellow))
                }
            )
        )
        
        findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView)?.onPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .systemYellow)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_onLongPress() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONLONGPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
                onLongPress: { [weak sut] in
                    sut?.display(style: Self.headerStyle(backgroundColor: .yellow))
                }
            )
        )
        
        findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView)?.onLongPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .yellow)
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_fail_navigationBar_with_leadingCard_onLongPress() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_ONLONGPRESS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
                onLongPress: { [weak sut] in
                    sut?.display(style: Self.headerStyle(backgroundColor: .systemYellow))
                }
            )
        )
        
        findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView)?.onLongPress?()
        XCTAssertEqual(sut.topItem?.standardAppearance?.backgroundColor, .systemYellow)
        
        // THEN
        if #available(iOS 26, *) {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assertFail(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
    
    func test_navigationBar_with_leadingCard_noGestureRecognizers() {
        let snapshotName = "NAVBAR_WITH_LEADINGCARD_NO_GESTURE_RECOGNIZERS"
        
        // GIVEN
        let (sut, container) = makeSUT()
        
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
        
        findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView)?.onPress?()
        
        // THEN
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }
}

extension NavigationBarSnapshotTests {
    private static func headerStyle(backgroundColor: UIColor) -> HeaderPresentableModel.Style {
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
    ) -> (sut: UINavigationBar, container: UIViewController) {
        let root = UIViewController()
        root.view.backgroundColor = .black
        let container = UINavigationController(rootViewController: root)
        container.loadViewIfNeeded()
        let sut = container.navigationBar
        
        checkForMemoryLeaks(sut, file: file, line: line)
        return (sut, container)
    }
}

private func findView<T: UIView>(_ type: T.Type, in root: UIView?) -> T? {
    guard let root else { return nil }
    if let view = root as? T { return view }
    return root.subviews.lazy.compactMap { findView(type, in: $0) }.first
}

/// Keep the same window alive between updates, as on the navigation demo screen.
/// Recreating a snapshot window for each display call can hide invalidation bugs.
final class NavigationBarUpdateSnapshotTests: XCTestCase {
    func test_titleWithTrailingButton_staysCenteredAfterRemoveAndRestore() throws {
        let sut = try makeLiveHeader()
        let button = ButtonPresentableModel(image: UIImage(systemName: "magnifyingglass"))
        sut.output.display(centerView: title)
        for (index, model) in [button, nil, button].enumerated() {
            sut.output.display(primeTrailingImage: model)
            attach(sut.snapshot(), named: "centered_title_\(index)")
            let label = sut.output.headerTitleLabel
            let frame = label.convert(label.bounds, to: sut.navigation.navigationBar)
            XCTAssertGreaterThan(label.bounds.width, 0)
            XCTAssertEqual(frame.midX, sut.navigation.navigationBar.bounds.midX, accuracy: 1,
                           "A short title must remain centered when there is enough room on both sides")
        }
    }

    func test_titleAndTrailingButtons_removeAndRestoreEachSlot() throws {
        let sut = try makeLiveHeader()
        let button = ButtonPresentableModel(image: UIImage(systemName: "xmark"), onPress: {})
        sut.output.display(centerView: title)
        sut.output.display(leadingCard: back)
        var slots = [true, true, true]
        for index in slots.indices { display(button, at: index, on: sut.output) }
        assertMatchesFresh(sut, name: "all_buttons", center: title, leading: back, slots: slots.map { $0 ? button : nil })

        for index in slots.indices {
            display(nil, at: index, on: sut.output)
            slots[index] = false
            assertMatchesFresh(sut, name: "remove_\(index)", center: title, leading: back, slots: slots.map { $0 ? button : nil })
            display(button, at: index, on: sut.output)
            slots[index] = true
            assertMatchesFresh(sut, name: "restore_\(index)", center: title, leading: back, slots: slots.map { $0 ? button : nil })
        }
        for index in slots.indices { display(nil, at: index, on: sut.output) }
        assertMatchesFresh(sut, name: "remove_all", center: title, leading: back)
        for index in slots.indices { display(button, at: index, on: sut.output) }
        assertMatchesFresh(sut, name: "restore_all", center: title, leading: back, slots: [button, button, button])
    }

    func test_customTrailingButton_removeAndRestoreWithTitle() throws {
        let sut = try makeLiveHeader()
        let button = ButtonPresentableModel(title: "Done", image: UIImage(systemName: "checkmark"), onPress: {})
        sut.output.display(centerView: title)
        for (index, model) in [button, nil, button].enumerated() {
            sut.output.display(primeTrailingImage: model)
            assertMatchesFresh(sut, name: "custom_trailing_\(index)", center: title, slots: [model, nil, nil])
        }
    }

    func test_titleLogoAndEmptyTitle_updatesKeepTheirNaturalSize() throws {
        let sut = try makeLiveHeader()
        let logo = HeaderPresentableModel.CenterView.titledImage(.init(
            .init(size: CGSize(width: 24, height: 24), image: .asset(UIImage(systemName: "star.fill"))), .text("3.66.0")
        ))
        let button = ButtonPresentableModel(image: UIImage(systemName: "magnifyingglass"))
        sut.output.display(primeTrailingImage: button)
        let centers: [HeaderPresentableModel.CenterView?] = [title, logo, title, nil, title]
        for (index, center) in centers.enumerated() {
            sut.output.display(centerView: center)
            assertMatchesFresh(sut, name: "center_\(index)", center: center, slots: [button, nil, nil])
        }
    }

    func test_leadingIconTextAndCustomCard_switchBackToOriginal() throws {
        let sut = try makeLiveHeader()
        sut.output.display(centerView: title)
        let icon = ImageViewPresentableModel(image: .asset(UIImage(systemName: "chevron.left")))
        // Use a fixed-color asset: this scenario checks layout, not SF Symbol vibrancy.
        let customImage = UIImage(systemName: "wallet.pass")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let cards: [CardViewPresentableModel?] = [
            back, .init(title: .text("Back"), onPress: {}),
            .init(leadingImage: icon, onPress: {}),
            .init(title: .text("Back"), leadingImage: icon,
                  secondaryLeadingImage: .init(size: .init(width: 24, height: 24), image: .asset(customImage)), onPress: {}),
            nil, back
        ]
        for (index, card) in cards.enumerated() {
            sut.output.display(leadingCard: card)
            assertMatchesFresh(sut, name: "leading_\(index)", center: title, leading: card)
        }
    }

    func test_hiddenHeader_showRestoresCurrentModel() throws {
        let sut = try makeLiveHeader()
        sut.output.display(centerView: title)
        sut.output.display(leadingCard: back)
        assertMatchesFresh(sut, name: "before_hide", center: title, leading: back)
        sut.output.display(isHidden: true)
        _ = sut.snapshot()
        sut.output.display(primeTrailingImage: .init(image: UIImage(systemName: "magnifyingglass")))
        sut.output.display(isHidden: false)
        assertMatchesFresh(sut, name: "shown", center: title, leading: back,
                           slots: [.init(image: UIImage(systemName: "magnifyingglass")), nil, nil])
    }

    func test_fullModel_hideThenRedisplay_restoresTitleAndButtons() throws {
        let sut = try makeLiveHeader()
        let button = ButtonPresentableModel(image: UIImage(systemName: "magnifyingglass"))
        let model = HeaderPresentableModel(centerView: title, leadingCard: back, primeTrailingImage: button)
        sut.output.display(model: model)
        assertMatchesFresh(sut, name: "full_model", center: title, leading: back, slots: [button, nil, nil])
        sut.output.display(model: nil)
        attach(sut.snapshot(), named: "nil_model")
        XCTAssertTrue(sut.navigation.isNavigationBarHidden)
        sut.output.display(model: model)
        XCTAssertFalse(sut.navigation.isNavigationBarHidden)
        assertMatchesFresh(sut, name: "restored_model", center: title, leading: back, slots: [button, nil, nil])
    }

    func test_darkHeader_titleAndTrailingButton_removeAndRestore() throws {
        let sut = try makeLiveHeader(style: .dark)
        let button = ButtonPresentableModel(image: UIImage(systemName: "magnifyingglass"))
        sut.output.display(centerView: title)
        sut.output.display(leadingCard: back)
        for (index, model) in [button, nil, button].enumerated() {
            sut.output.display(primeTrailingImage: model)
            assertMatchesFresh(sut, name: "dark_\(index)", center: title, leading: back, slots: [model, nil, nil])
        }
    }

    private var title: HeaderPresentableModel.CenterView { .keyValue(.init(.text("Navigation"), nil)) }
    private var back: CardViewPresentableModel {
        .init(title: .text("Back"), leadingImage: .init(image: .asset(UIImage(systemName: "chevron.left"))), onPress: {})
    }

    private func makeLiveHeader(style: UIUserInterfaceStyle = .light) throws -> LiveHeader {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let header = LiveHeader(scene: scene, style: style)
        addTeardownBlock { header.close() }
        return header
    }

    private func display(_ button: ButtonPresentableModel?, at index: Int, on output: NavigationItemHeaderOutput) {
        switch index {
        case 0: output.display(primeTrailingImage: button)
        case 1: output.display(secondaryTrailingImage: button)
        default: output.display(tertiaryTrailingImage: button)
        }
    }

    private func assertMatchesFresh(
        _ sut: LiveHeader, name: String, center: HeaderPresentableModel.CenterView?,
        leading: CardViewPresentableModel? = nil, slots: [ButtonPresentableModel?] = [nil, nil, nil],
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let actual = sut.snapshot()
        // Glass must not sample another test window beneath the reference.
        sut.window.isHidden = true
        let reference = LiveHeader(scene: sut.window.windowScene!, style: sut.window.overrideUserInterfaceStyle)
        reference.output.display(model: .init(centerView: center, leadingCard: leading,
            primeTrailingImage: slots[0], secondaryTrailingImage: slots[1], tertiaryTrailingImage: slots[2]))
        let expected = reference.snapshot()
        reference.close()
        sut.window.makeKeyAndVisible()
        attach(actual, named: name + "_updated")
        attach(expected, named: name + "_fresh")
        // Live glass differs by one 8-bit channel step between renders. Require
        // every pixel to match perceptually; do not allow a percentage of missing content.
        if let diff = Diffing.image(precision: 1, perceptualPrecision: 0.98).diff(expected, actual) {
            attach(diff.artifacts.diff, named: name + "_diff")
            XCTFail("\(name): sequential display differs from the same fresh model. \(diff.message)", file: file, line: line)
        }
    }

    private func attach(_ image: UIImage, named name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private final class LiveHeader {
        let window: UIWindow
        let root = UIViewController()
        let navigation: UINavigationController
        var output: NavigationItemHeaderOutput { root.headerOutput }
        private weak var previousKeyWindow: UIWindow?

        init(scene: UIWindowScene, style: UIUserInterfaceStyle) {
            previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
            window = UIWindow(windowScene: scene)
            navigation = UINavigationController(rootViewController: root)
            root.view.backgroundColor = .systemBackground
            window.overrideUserInterfaceStyle = style
            window.rootViewController = navigation
            window.makeKeyAndVisible()
            output.display(style: .init(backgroundColor: .systemGroupedBackground, horizontalSpacing: 8,
                primeFont: .systemFont(ofSize: 18, weight: .semibold), primeColor: .label,
                secondaryFont: .systemFont(ofSize: 14), secondaryColor: .secondaryLabel))
            root.activateNavigationHeader()
        }

        func snapshot() -> UIImage {
            window.layoutIfNeeded()
            RunLoop.current.run(until: Date().addingTimeInterval(1))
            window.layoutIfNeeded()
            let format = UIGraphicsImageRendererFormat(for: window.traitCollection)
            return UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
        }

        func close() {
            window.isHidden = true
            window.rootViewController = nil
            window.windowScene = nil
            previousKeyWindow?.makeKeyAndVisible()
        }
    }
}
