#if os(iOS) || targetEnvironment(macCatalyst)
import WrapKit
import WrapKitTestUtils
import XCTest
import UIKit

class NavigationBarSnapshotTests: XCTestCase {
    func test_iOS26_leadingCardUsesInteractiveCapsuleGlassOnlyWhileItHasActions() throws {
        guard #available(iOS 26.0, *), isLiquidGlassEnabled else {
            throw XCTSkip("Liquid Glass requires iOS 26 and an enabled feature flag.")
        }

        let sut = UINavigationBar()
        XCTAssertNil(sut.topItem?.leftBarButtonItem)

        sut.display(leadingCard: .init(title: .text("Press"), onPress: {}))

        let glassView = try XCTUnwrap(findView(UIVisualEffectView.self, in: sut.topItem?.leftBarButtonItem?.customView))
        let glassEffect = try XCTUnwrap(glassView.effect as? UIGlassEffect)
        let card = try XCTUnwrap(findView(CardView.self, in: glassView.contentView))
        XCTAssertTrue(glassEffect.isInteractive)
        XCTAssertEqual(glassView.cornerConfiguration, .capsule())
        XCTAssertTrue(card.superview === glassView.contentView)

        sut.display(leadingCard: .init(title: .text("Static")))

        XCTAssertNil(glassView.superview)
        XCTAssertNil(findView(UIVisualEffectView.self, in: sut.topItem?.leftBarButtonItem?.customView))
        XCTAssertNotNil(findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView))

        sut.display(leadingCard: .init(title: .text("Long press"), onLongPress: {}))

        XCTAssertTrue(findView(UIVisualEffectView.self, in: sut.topItem?.leftBarButtonItem?.customView) === glassView)
        XCTAssertTrue(card.superview === glassView.contentView)
    }

    func test_iOS26_allTrailingButtonsKeepGlassCapsuleConfigurationAfterDisplay() throws {
        guard #available(iOS 26.0, *), isLiquidGlassEnabled else {
            throw XCTSkip("Liquid Glass requires iOS 26 and an enabled feature flag.")
        }

        let sut = UINavigationBar()
        var expectedConfiguration = UIButton.Configuration.glass()
        expectedConfiguration.cornerStyle = .capsule
        let model = ButtonPresentableModel(title: "Action", image: UIImage(systemName: "star"), onPress: {})

        sut.display(primeTrailingImage: model)
        sut.display(secondaryTrailingImage: model)
        sut.display(tertiaryTrailingImage: model)

        let items = try XCTUnwrap(sut.topItem?.rightBarButtonItems)
        XCTAssertEqual(items.count, 3)
        for item in items {
            let button = try XCTUnwrap(findView(Button.self, in: item.customView))
            XCTAssertFalse(button.isHidden)
            let configuration = try XCTUnwrap(button.configuration)
            XCTAssertEqual(configuration.cornerStyle, expectedConfiguration.cornerStyle)
            XCTAssertTrue(
                String(reflecting: configuration).contains("baseStyle=glass"),
                "UIKit exposes no public glass-style discriminator: \(String(reflecting: configuration))"
            )
        }
    }

    func test_navigationBar_style_appliesSecondaryTypographyToCenterValueLabel() throws {
        let navigationBar = UINavigationBar()
        let secondaryFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        navigationBar.display(style: .init(
            backgroundColor: .clear,
            horizontalSpacing: 1,
            primeFont: .systemFont(ofSize: 24),
            primeColor: .blue,
            secondaryFont: secondaryFont,
            secondaryColor: .green,
            numberOfLines: 3
        ))
        navigationBar.display(centerView: .keyValue(.init(.text("Title"), .text("Subtitle"))))

        let titles = try XCTUnwrap(findView(VKeyValueFieldView.self, in: navigationBar.topItem?.titleView))
        XCTAssertEqual(titles.valueLabel.font, secondaryFont)
        XCTAssertEqual(titles.valueLabel.textColor, .green)
        XCTAssertEqual(titles.valueLabel.numberOfLines, 3)
    }

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
            primeFont: .boldSystemFont(ofSize: 18),
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
            primeFont: .boldSystemFont(ofSize: 18),
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

        // Both references use a light navigation bar, including in a dark window.
        if #available(iOS 26, *) {
            sut.overrideUserInterfaceStyle = .light
        }

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

    func test_navigationBar_with_leadingCard_bottomImage() throws {
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

        sut.display(
            leadingCard: .init(
                bottomImage: .systemSymbol(
                    "star.fill",
                    size: CGSize(width: 24, height: 24)
                )
            )
        )

        // THEN
        let lightSnapshot = container.snapshot(for: .iPhone(style: .light))
        let card = try XCTUnwrap(findView(CardView.self, in: sut.topItem?.leftBarButtonItem?.customView))
        XCTAssertFalse(card.bottomImageWrapperView.isHidden)
        XCTAssertFalse(card.bottomImageView.isHidden)
        XCTAssertNotNil(card.bottomImageView.image)
        XCTAssertGreaterThan(card.bottomImageView.bounds.width, 0)
        XCTAssertGreaterThan(card.bottomImageView.bounds.height, 0)

        if #available(iOS 26, *) {
            assert(snapshot: lightSnapshot, named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(snapshot: lightSnapshot, named: "iOS18.5_\(snapshotName)_LIGHT")
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

        sut.display(
            leadingCard: .init(
                bottomImage: .systemSymbol(
                    "star",
                    size: CGSize(width: 24, height: 24)
                )
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
#endif
