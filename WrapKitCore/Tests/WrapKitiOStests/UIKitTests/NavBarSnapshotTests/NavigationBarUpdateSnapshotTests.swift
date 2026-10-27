import WrapKit
import WrapKitTestUtils
import XCTest
import UIKit

/// Keep the same window alive between updates, as on the navigation demo screen.
/// Recreating a snapshot window for each display call can hide invalidation bugs.
final class NavigationBarUpdateSnapshotTests: XCTestCase {
    func test_titledImage_keepsLogoAndCaptionInsideBarAfterUpdates() throws {
        let sut = try makeLiveHeader()
        let logo = UIGraphicsImageRenderer(size: CGSize(width: 32, height: 32)).image { context in
            UIColor.systemPink.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 32, height: 32))
        }
        let button = ButtonPresentableModel(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"))
        let center = HeaderPresentableModel.CenterView.titledImage(.init(
            .init(image: .asset(logo)), .text("Личный кабинет")
        ))
        sut.output.display(centerView: center)
        for (index, trailing) in [button, nil, button].enumerated() {
            sut.output.display(primeTrailingImage: trailing)
            attach(sut.snapshot(), named: "logo_caption_fits_\(index)")
            let host = try XCTUnwrap(sut.root.navigationItem.titleView)
            let image = try XCTUnwrap(findView(ImageView.self, in: host))
            let caption = try XCTUnwrap(findView(TitledView<WrapperView<ImageView>>.self, in: host)?.closingTitleVFieldView.keyLabel)
            let bar = sut.navigation.navigationBar
            for view in [image, caption] as [UIView] {
                let frame = view.convert(view.bounds, to: host)
                XCTAssertGreaterThanOrEqual(frame.minY, host.bounds.minY - 0.5)
                XCTAssertLessThanOrEqual(frame.maxY, host.bounds.maxY + 0.5)
            }
            // iOS 26 can place the title host slightly above the bar's bounds.
            // The caption must still stay above the bottom clipping edge.
            XCTAssertLessThanOrEqual(caption.convert(caption.bounds, to: bar).maxY, bar.bounds.maxY + 0.5)
            XCTAssertGreaterThan(image.bounds.height, 0)
            XCTAssertGreaterThanOrEqual(caption.bounds.height, ceil(caption.font.lineHeight) - 0.5)
        }
    }

    func test_customTrailingButtons_followHeaderColorAfterUpdates() throws {
        let sut = try makeLiveHeader()
        let model = ButtonPresentableModel(title: "Done", image: UIImage(systemName: "checkmark"), onPress: {})
        sut.output.display(centerView: title)
        for slot in 0..<3 { display(model, at: slot, on: sut.output) }
        for (index, color) in [UIColor.label, .systemBlue].enumerated() {
            sut.output.display(style: .init(backgroundColor: .systemGroupedBackground, horizontalSpacing: 8,
                primeFont: .systemFont(ofSize: 18), primeColor: color,
                secondaryFont: .systemFont(ofSize: 14), secondaryColor: .secondaryLabel))
            for slot in 0..<3 {
                display(nil, at: slot, on: sut.output)
                display(model, at: slot, on: sut.output)
            }
            attach(sut.snapshot(), named: "custom_colors_\(index)")
            let items = try XCTUnwrap(sut.root.navigationItem.rightBarButtonItems)
            XCTAssertEqual(items.count, 3)
            for item in items {
                let button = try XCTUnwrap(findView(Button.self, in: item.customView))
                XCTAssertEqual(button.tintColor, color)
                XCTAssertEqual(button.textColor, color)
                XCTAssertEqual(button.configuration?.baseForegroundColor ?? button.currentTitleColor, color)
                if #available(iOS 26, *) {
                    let expected = model.image?.withTintColor(color.resolvedColor(with: button.traitCollection), renderingMode: .alwaysOriginal)
                    XCTAssertEqual(button.configuration?.image?.pngData(), expected?.pngData())
                }
            }
        }
    }

    func test_customTrailingButton_preservesExplicitColorWhenHeaderStyleChanges() throws {
        let sut = try makeLiveHeader()
        let model = ButtonPresentableModel(title: "Done", image: UIImage(systemName: "checkmark"),
            style: .init(titleColor: .systemPurple), onPress: {})
        sut.output.display(primeTrailingImage: model)
        sut.output.display(style: .init(backgroundColor: .systemGroupedBackground, horizontalSpacing: 8,
            primeFont: .systemFont(ofSize: 18), primeColor: .systemBlue,
            secondaryFont: .systemFont(ofSize: 14), secondaryColor: .secondaryLabel))
        // A partial model keeps the previously supplied button style.
        sut.output.display(primeTrailingImage: nil)
        sut.output.display(primeTrailingImage: .init(title: "Done", image: UIImage(systemName: "checkmark"), onPress: {}))
        attach(sut.snapshot(), named: "custom_explicit_color")
        let button = try XCTUnwrap(findView(Button.self, in: sut.root.navigationItem.rightBarButtonItem?.customView))
        XCTAssertEqual(button.textColor, .systemPurple)
        XCTAssertEqual(button.configuration?.baseForegroundColor ?? button.currentTitleColor, .systemPurple)
    }

    func test_customTrailingButton_preservesOriginalImage() throws {
        let sut = try makeLiveHeader()
        let image = try XCTUnwrap(UIImage(systemName: "checkmark")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal))
        sut.output.display(primeTrailingImage: .init(title: "Done", image: image, onPress: {}))
        sut.output.display(style: .init(backgroundColor: .systemGroupedBackground, horizontalSpacing: 8,
            primeFont: .systemFont(ofSize: 18), primeColor: .systemBlue,
            secondaryFont: .systemFont(ofSize: 14), secondaryColor: .secondaryLabel))
        attach(sut.snapshot(), named: "custom_original_color")
        let button = try XCTUnwrap(findView(Button.self, in: sut.root.navigationItem.rightBarButtonItem?.customView))
        XCTAssertTrue((button.configuration?.image ?? button.image(for: .normal)) === image)
    }

    func test_customTrailingButton_updatesDynamicImageColorWhenAppearanceChanges() throws {
        let sut = try makeLiveHeader()
        let image = try XCTUnwrap(UIImage(systemName: "checkmark"))
        sut.output.display(primeTrailingImage: .init(title: "Done", image: image, onPress: {}))
        let button = try XCTUnwrap(findView(Button.self, in: sut.root.navigationItem.rightBarButtonItem?.customView))
        for (index, style) in [UIUserInterfaceStyle.light, .dark, .light].enumerated() {
            sut.window.overrideUserInterfaceStyle = style
            attach(sut.snapshot(), named: "custom_appearance_\(index)")
            let color = UIColor.label.resolvedColor(with: button.traitCollection)
            if #available(iOS 26, *) {
                let expected = image.withTintColor(color, renderingMode: .alwaysOriginal)
                XCTAssertEqual(button.configuration?.image?.pngData(), expected.pngData())
            } else {
                XCTAssertEqual(button.tintColor.resolvedColor(with: button.traitCollection), color)
                XCTAssertTrue(button.image(for: .normal) === image)
            }
        }
    }

    func test_nativeTrailingButton_retainsIdentifierAndActionAfterUpdates() throws {
        let sut = try makeLiveHeader()
        var presses = 0
        let button = ButtonPresentableModel(
            accessibilityIdentifier: "navigation.search",
            image: UIImage(systemName: "magnifyingglass"),
            onPress: { presses += 1 }
        )
        sut.output.display(centerView: title)
        for index in 0..<2 {
            sut.output.display(primeTrailingImage: button)
            attach(sut.snapshot(), named: "interactive_search_\(index)")
            let item = try XCTUnwrap(sut.root.navigationItem.rightBarButtonItem)
            XCTAssertEqual(item.accessibilityIdentifier, "navigation.search")
            XCTAssertTrue(item.isAccessibilityElement)
            XCTAssertTrue(item.isEnabled)
            XCTAssertNotNil(item.primaryAction)
            func actionControl(in view: UIView) -> UIControl? {
                if let control = view as? UIControl, control.allControlEvents.contains(.primaryActionTriggered) {
                    return control
                }
                return view.subviews.lazy.compactMap { actionControl(in: $0) }.first
            }
            let rendered = try XCTUnwrap(actionControl(in: sut.navigation.navigationBar))
            XCTAssertTrue(rendered.isEnabled)
            rendered.sendActions(for: .primaryActionTriggered)
            XCTAssertEqual(presses, index + 1)
            sut.output.display(primeTrailingImage: nil)
            _ = sut.snapshot()
        }
    }

    func test_nativeLeadingButton_exposesAccessibilityAndEnabledState() throws {
        let sut = try makeLiveHeader()
        for enabled in [false, true] {
            sut.output.display(leadingCard: .init(
                accessibilityIdentifier: "navigation.back",
                leadingImage: .init(image: .asset(UIImage(systemName: "chevron.left"))),
                onPress: {},
                isUserInteractionEnabled: enabled
            ))
            attach(sut.snapshot(), named: "accessible_back_\(enabled)")
            let item = try XCTUnwrap(sut.root.navigationItem.leftBarButtonItem)
            XCTAssertTrue(item.isAccessibilityElement)
            XCTAssertEqual(item.accessibilityIdentifier, "navigation.back")
            XCTAssertEqual(item.isEnabled, enabled)
            XCTAssertNotNil(item.primaryAction)
        }
    }

    func test_removeAllButtons_keepsOnlyTitleAndRestoresCustomCard() throws {
        let sut = try makeLiveHeader()
        let image = UIImage(systemName: "wallet.pass")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let card = CardViewPresentableModel(title: .text("Back"),
            secondaryLeadingImage: .init(size: CGSize(width: 24, height: 24), image: .asset(image)), onPress: {})
        let button = ButtonPresentableModel(image: UIImage(systemName: "xmark"), onPress: {})
        let model = HeaderPresentableModel(centerView: title, leadingCard: card,
            primeTrailingImage: button, secondaryTrailingImage: button, tertiaryTrailingImage: button)

        for index in 0..<2 {
            sut.output.display(model: model)
            XCTAssertNotNil(sut.root.navigationItem.leftBarButtonItem)
            assertMatchesFresh(sut, name: "all_controls_on_\(index)", center: title,
                               leading: card, slots: [button, button, button])
            if #available(iOS 26, *) {
                let host = try XCTUnwrap(sut.root.navigationItem.leftBarButtonItem?.customView)
                let cardView = try XCTUnwrap(findView(CardView.self, in: host))
                let imageView = cardView.secondaryLeadingImageView
                let imageFrame = imageView.convert(imageView.bounds, to: host)
                XCTAssertGreaterThanOrEqual(host.bounds.height, 44)
                XCTAssertGreaterThanOrEqual(imageFrame.minY, 10)
                XCTAssertGreaterThanOrEqual(host.bounds.height - imageFrame.maxY, 10)
                XCTAssertEqual(imageFrame.height, 24, accuracy: 0.5, "Padding must not stretch the icon")
            }

            sut.output.display(leadingCard: nil)
            for slot in 0..<3 { display(nil, at: slot, on: sut.output) }
            XCTAssertNil(sut.root.navigationItem.leftBarButtonItem)
            XCTAssertTrue(sut.root.navigationItem.rightBarButtonItems?.isEmpty ?? true)
            XCTAssertFalse(sut.navigation.isNavigationBarHidden)
            assertMatchesFresh(sut, name: "all_controls_off_\(index)", center: title)
        }
    }

    func test_logoAndThreeTrailingButtons_toggleCustomLeadingImage() throws {
        let sut = try makeLiveHeader()
        // Match the Navigation demo's 32pt logo and 48pt wallet asset without
        // depending on DesignSystem. No explicit image size is supplied there.
        func asset(size: CGFloat, color: UIColor) -> UIImage {
            UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: size, height: size))
            }.withRenderingMode(.alwaysOriginal)
        }
        let logo = HeaderPresentableModel.CenterView.titledImage(.init(
            .init(image: .asset(asset(size: 32, color: .systemBlue))), .text("3.66.0")
        ))
        let wallet = ImageViewPresentableModel(image: .asset(asset(size: 48, color: .black)))
        let button = ButtonPresentableModel(image: UIImage(systemName: "xmark"), onPress: {})
        sut.output.display(model: .init(centerView: logo,
            leadingCard: .init(title: .text("Назад"), onPress: {}),
            primeTrailingImage: button, secondaryTrailingImage: button, tertiaryTrailingImage: button))
        for (index, image) in [nil, wallet, nil, wallet, nil].enumerated() {
            let card = CardViewPresentableModel(title: .text("Назад"), secondaryLeadingImage: image, onPress: {})
            sut.output.display(leadingCard: card)
            let customView = try XCTUnwrap(sut.root.navigationItem.leftBarButtonItem?.customView)
            let fitting = customView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            // A multiline label previously reported a 65,612pt width here;
            // UIKit then trapped while measuring the bar's custom item.
            XCTAssertGreaterThan(fitting.width, 0)
            XCTAssertLessThan(fitting.width, sut.window.bounds.width)
            guard fitting.width.isFinite, fitting.width < sut.window.bounds.width else { return }
            assertMatchesFresh(sut, name: "logo_custom_\(index)", center: logo,
                               leading: card, slots: [button, button, button])
        }
    }

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

private func findView<T: UIView>(_ type: T.Type, in root: UIView?) -> T? {
    guard let root else { return nil }
    if let view = root as? T { return view }
    return root.subviews.lazy.compactMap { findView(type, in: $0) }.first
}
