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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_DEFAULT_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_DEFAULT_STATE_DARK")
    }
    
    func test_navigationBar_with_centerView_keyValue() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_CENTERVIEW_KEYVALUE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_CENTERVIEW_KEYVALUE_DARK")
    }
    
    func test_navigationBar_with_centerView_titleImage() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_CENTERVIEW_TITLEDIMAGE_DARK")
    }
    
    // TODO: - maybe wrong title apperance. need to ask
    func test_navigationBar_with_leadingCard_backgoundImage() {
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
        
        sut.display(leadingCard: .init(backgroundImage: .init(image: .asset(Image(systemName: "star.fill"))), title: .text("Title")))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_BACKGROUNDIMAGE_TITLE_DARK")
    }
    
    func test_navigationBar_with_leadingCard_trailingTitles() {
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
                backgroundImage: .init(
                    size: CGSize(width: 24, height: 24),
                    image: .asset(Image(systemName: "star.fill"))),
                trailingTitles: .init(.text("Title"), .text("Subtitle"))))

        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_TRAILINGTITLES_DARK")
    }
    
    // MARK: - func display(secondaryTrailingImage:) tests
    func test_navigationBar_with_secondaryTrailingImage() {
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
        sut.display(secondaryTrailingImage: .some(.init(title: "Image", image: image, height: 24)))
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_DARK")
    }
    
    func test_navigationBar_with_secondaryTrailingImage_onPress() {
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
                sut?.backgroundColor = .yellow
            })
        ))
        
        sut.secondaryTrailingImageWrapperView.contentView.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_ONTAP_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_SECONDARY_TRAILING_IMAGE_ONTAP_DARK")
    }
    
    func test_navigationBar_with_tertiaryTrailingImage() {
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
        )))
        
        sut.secondaryTrailingImageWrapperView.contentView.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_DARK")
    }
    
    func test_navigationBar_with_tertiaryTrailingImage_onPress() {
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
                sut?.backgroundColor = .yellow
            }
        )))
        
        sut.tertiaryTrailingImageWrapperView.contentView.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_ONPRESS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_TERTIARY_TRAILINGIMAGE_ONPRESS_DARK")
    }
    
    func test_navigationBar_with_tertiaryAndSecondary_trailingImages() {
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
            height: 24,
            onPress: { [weak sut] in
                sut?.backgroundColor = .yellow
            })
        ))
        
        sut.display(secondaryTrailingImage: .some(.init(
            title: "Second",
            image: image,
            height: 24,
            onPress: { [weak sut] in
                sut?.backgroundColor = .yellow
            })
        ))
        
        sut.secondaryTrailingImageWrapperView.contentView.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_TERTIARY_SECONDARY_TRAILINGIMAGE_DARK")
    }
    
    func test_navigationBar_hidden_state() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_HIDDEN_STATE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_HIDDEN_STATE_DARK")
    }
    
    func test_navigationBar_with_leadingCard_leadingTrailingTitles() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_TITLES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_TITLES__DARK")
    }
    
    func test_navigationBar_with_leadingCard_leadingTrailingImages() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_IMAGES_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_LEADING_TRAILING_IMAGES__DARK")
    }
    
    func test_navigationBar_with_leadingCard_subtitle() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_SUBTITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_SUBTITLE__DARK")
    }
    
    func test_navigationBar_with_leadingCard_valueTitle() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_VALUETITLE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_VALUETITLE_DARK")
    }
    
    // TODO: - bottom image doesnt appear
    func test_navigationBar_with_leadingCard_bottomImage() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_BOTTOMIMAGE_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_BOTTOMIMAGE_DARK")
    }
    
    func test_navigationBar_with_leadingCard_bottomSeparator() {
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
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_BOTTOMSEPARATOR_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_BOTTOMSEPARATOR_DARK")
    }
    
    func test_navigationBar_with_leadingCard_switchControl() {
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
                        cornerRadius: 10))
            )
        )
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_SWITCHCONTROL_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_SWITCHCONTROL_DARK")
    }
    
    func test_navigationBar_with_leadingCard_onPress() {
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
                    sut?.backgroundColor = .yellow
                }
            )
        )
        
        sut.leadingCardView.onPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_ONPRESS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_ONPRESS_DARK")
    }
    
    func test_navigationBar_with_leadingCard_onLongPress() {
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
                    sut?.backgroundColor = .yellow
                }
            )
        )
        
        sut.leadingCardView.onLongPress?()
        
        // THEN
        assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "NAVBAR_WITH_LEADINGCARD_ONLONGPRESS_LIGHT")
        assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "NAVBAR_WITH_LEADINGCARD_ONLONGPRESS_DARK")
    }
    
}

extension NavigationBarSnapshotTests {
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: NavigationBar, container: UIView) {
        let sut = NavigationBar()
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
