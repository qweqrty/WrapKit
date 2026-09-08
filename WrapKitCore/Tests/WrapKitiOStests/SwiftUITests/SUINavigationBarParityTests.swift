#if canImport(SwiftUI) && canImport(UIKit)
    import SwiftUI
    import UIKit
    @testable import WrapKit
    import WrapKitTestUtils
    import XCTest

    @MainActor
    final class SUINavigationBarParityTests: XCTestCase {
        private let containerWidth: CGFloat = 390

        func test_granularThenFullModelBeforeMount_replaysLatestValuesInPresenterOrder() {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(style: makeStyle(horizontalSpacing: 4))
            adapter.display(primeTrailingImage: makeButton(
                id: "granular",
                label: "Granular",
                systemName: "star",
                onPress: {}
            ))
            adapter.display(model: .init(
                style: makeStyle(horizontalSpacing: 20),
                primeTrailingImage: makeButton(
                    id: "model",
                    label: "Model",
                    systemName: "star.fill",
                    onPress: {}
                )
            ))

            let stateModel = SUINavigationBarStateModel(adapter: adapter)

            XCTAssertEqual(stateModel.model.style?.horizontalSpacing, 20)
            XCTAssertEqual(stateModel.model.primeTrailingImage?.accessibilityIdentifier, "model")
        }

        func test_fullModelThenGranularBeforeMount_replaysLatestValuesInPresenterOrder() {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(model: .init(
                style: makeStyle(horizontalSpacing: 20),
                primeTrailingImage: makeButton(
                    id: "model",
                    label: "Model",
                    systemName: "star.fill",
                    onPress: {}
                )
            ))
            adapter.display(style: makeStyle(horizontalSpacing: 4))
            adapter.display(primeTrailingImage: nil)

            let stateModel = SUINavigationBarStateModel(adapter: adapter)

            XCTAssertEqual(stateModel.model.style?.horizontalSpacing, 4)
            XCTAssertNil(stateModel.model.primeTrailingImage)
        }

        func test_granularCallbackRemovalReleasesFullModelOwnerAndSurvivesRemount() throws {
            final class CallbackOwner {}

            let adapter = HeaderOutputSwiftUIAdapter()
            var calls = 0
            weak var weakOwner: CallbackOwner?
            var callback: (() -> Void)?
            do {
                let owner = CallbackOwner()
                weakOwner = owner
                callback = {
                    _ = owner
                    calls += 1
                }
            }
            adapter.display(model: .init(
                primeTrailingImage: .init(onPress: callback)
            ))
            callback = nil
            var mountedStateModel: SUINavigationBarStateModel? = .init(adapter: adapter)
            let retainedAction = try XCTUnwrap(
                mountedStateModel?.model.primeTrailingImage?.onPress
            )

            XCTAssertNotNil(weakOwner)
            retainedAction()
            XCTAssertEqual(calls, 1)

            adapter.display(primeTrailingImage: nil)
            mountedStateModel = nil
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))

            XCTAssertNil(weakOwner)
            retainedAction()
            XCTAssertEqual(calls, 1)

            let remountedStateModel = SUINavigationBarStateModel(adapter: adapter)

            XCTAssertNil(remountedStateModel.model.primeTrailingImage)
        }

        func test_nilModelBeforeMount_hidesAndPreservesEarlierGranularStyleLikeUIKit() {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(style: makeStyle(horizontalSpacing: 4))
            adapter.display(model: nil)

            let stateModel = SUINavigationBarStateModel(adapter: adapter)

            XCTAssertTrue(stateModel.isHidden)
            XCTAssertEqual(stateModel.model.style?.horizontalSpacing, 4)
        }

        func test_leadingCardThenHeaderStyleBeforeMount_appliesLaterHeaderTitleStyleToCard() {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(leadingCard: .init(style: makeLeadingCardStyle()))
            adapter.display(style: makeStyle(
                primeFont: .systemFont(ofSize: 29),
                primeColor: .systemGreen
            ))

            let navigationStateModel = SUINavigationBarStateModel(adapter: adapter)
            let cardStateModel = SUICardViewStateModel(adapter: navigationStateModel.leadingCardAdapter)

            XCTAssertEqual(cardStateModel.style.titleKeyLabelFont.pointSize, 29)
            XCTAssertTrue(cardStateModel.style.titleKeyTextColor.isEqual(UIColor.systemGreen))
        }

        func test_headerStyleThenLeadingCardBeforeMount_appliesLaterCardTitleStyle() {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(style: makeStyle(
                primeFont: .systemFont(ofSize: 29),
                primeColor: .systemGreen
            ))
            adapter.display(leadingCard: .init(style: makeLeadingCardStyle()))

            let navigationStateModel = SUINavigationBarStateModel(adapter: adapter)
            let cardStateModel = SUICardViewStateModel(adapter: navigationStateModel.leadingCardAdapter)

            XCTAssertEqual(cardStateModel.style.titleKeyLabelFont.pointSize, 11)
            XCTAssertTrue(cardStateModel.style.titleKeyTextColor.isEqual(UIColor.systemRed))
        }

        func test_remountPreservesLeadingCardNestedSwitchState() {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(leadingCard: .init(switchControl: .init(isOn: true)))

            weak var firstHeaderStateModel: SUINavigationBarStateModel?
            weak var firstCardStateModel: SUICardViewStateModel?
            weak var firstSwitchStateModel: SUISwitchControlStateModel?
            autoreleasepool {
                let headerStateModel = SUINavigationBarStateModel(adapter: adapter)
                let cardStateModel = SUICardViewStateModel(
                    adapter: headerStateModel.leadingCardAdapter
                )
                let switchStateModel = SUISwitchControlStateModel(
                    adapter: cardStateModel.switchControlAdapter
                )
                firstHeaderStateModel = headerStateModel
                firstCardStateModel = cardStateModel
                firstSwitchStateModel = switchStateModel

                switchStateModel.isOn = false
                cardStateModel.switchControlAdapter.display(isLoading: true)

                XCTAssertFalse(switchStateModel.isOn)
                XCTAssertTrue(switchStateModel.isLoading)
            }
            XCTAssertNil(firstHeaderStateModel)
            XCTAssertNil(firstCardStateModel)
            XCTAssertNil(firstSwitchStateModel)

            let remountedHeaderStateModel = SUINavigationBarStateModel(adapter: adapter)
            let remountedCardStateModel = SUICardViewStateModel(
                adapter: remountedHeaderStateModel.leadingCardAdapter
            )
            let remountedSwitchStateModel = SUISwitchControlStateModel(
                adapter: remountedCardStateModel.switchControlAdapter
            )

            XCTAssertFalse(remountedSwitchStateModel.isOn)
            XCTAssertTrue(remountedSwitchStateModel.isLoading)
        }

        func test_centerLabelAction_survivesRemountAndInactiveSlotIsRevoked() throws {
            let adapter = HeaderOutputSwiftUIAdapter()
            var actions: [String] = []
            adapter.display(centerView: .keyValue(.init(
                .attributes([.init(text: "Key", onTap: { actions.append("key") })]),
                .text("Value")
            )))

            weak var firstStateModel: SUINavigationBarStateModel?
            var firstKeyAction: (() -> Void)?
            autoreleasepool {
                let stateModel = SUINavigationBarStateModel(adapter: adapter)
                firstStateModel = stateModel
                firstKeyAction = firstTextAction(in: stateModel.centerKeyStateModel.presentable.model)
            }
            XCTAssertNil(firstStateModel)

            weak var remountedStateModel: SUINavigationBarStateModel?
            try autoreleasepool {
                let stateModel = SUINavigationBarStateModel(adapter: adapter)
                remountedStateModel = stateModel
                let remountedKeyAction = try XCTUnwrap(
                    firstTextAction(in: stateModel.centerKeyStateModel.presentable.model)
                )
                firstKeyAction?()
                remountedKeyAction()
                XCTAssertEqual(actions, ["key", "key"])

                adapter.display(centerView: .titledImage(.init(
                    nil,
                    .attributes([.init(text: "Title", onTap: { actions.append("title") })])
                )))

                XCTAssertTrue(stateModel.centerKeyStateModel.isHidden)
                XCTAssertTrue(stateModel.centerValueStateModel.isHidden)
                XCTAssertFalse(stateModel.centerTitledImageTitleStateModel.isHidden)
                firstKeyAction?()
                remountedKeyAction()
                XCTAssertEqual(actions, ["key", "key"])
            }
            XCTAssertNil(remountedStateModel)

            let titledRemount = SUINavigationBarStateModel(adapter: adapter)
            let titleAction = try XCTUnwrap(
                firstTextAction(in: titledRemount.centerTitledImageTitleStateModel.presentable.model)
            )
            titleAction()

            XCTAssertEqual(actions, ["key", "key", "title"])

            adapter.display(centerView: nil)

            XCTAssertTrue(titledRemount.centerKeyStateModel.isHidden)
            XCTAssertTrue(titledRemount.centerValueStateModel.isHidden)
            XCTAssertTrue(titledRemount.centerTitledImageTitleStateModel.isHidden)
            titleAction()
            XCTAssertEqual(actions, ["key", "key", "title"])
        }

        func test_centerValueAnimationCompletion_survivesCenterReplacementAndRemount() {
            let adapter = HeaderOutputSwiftUIAdapter()
            var completionCalls = 0
            adapter.display(centerView: .keyValue(.init(
                .text("Key"),
                .animatedDecimal(
                    from: 0,
                    to: 1,
                    mapToString: nil,
                    animationStyle: .none,
                    duration: 0,
                    completion: { completionCalls += 1 }
                )
            )))

            weak var firstStateModel: SUINavigationBarStateModel?
            autoreleasepool {
                let stateModel = SUINavigationBarStateModel(adapter: adapter)
                firstStateModel = stateModel

                adapter.display(centerView: .titledImage(.init(nil, .text("Replacement"))))

                XCTAssertTrue(stateModel.centerKeyStateModel.isHidden)
                XCTAssertTrue(stateModel.centerValueStateModel.isHidden)
                XCTAssertFalse(stateModel.centerTitledImageTitleStateModel.isHidden)
            }
            XCTAssertNil(firstStateModel)

            var remountedStateModel: SUINavigationBarStateModel? = .init(adapter: adapter)
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))

            XCTAssertEqual(completionCalls, 1)
            XCTAssertEqual(remountedStateModel?.centerValueStateModel.presentable.model?.text, "1")
            XCTAssertEqual(
                remountedStateModel?.centerTitledImageTitleStateModel.presentable.model?.text,
                "Replacement"
            )

            remountedStateModel = nil
            let secondRemount = SUINavigationBarStateModel(adapter: adapter)
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))

            XCTAssertEqual(completionCalls, 1)
            XCTAssertEqual(secondRemount.centerValueStateModel.presentable.model?.text, "1")
        }

        @available(iOS 17.0, *)
        func test_titledImageClosureOnlyReplacementUpdatesMountedViewAndSurvivesRemount() throws {
            final class ActionOwner {}

            let adapter = HeaderOutputSwiftUIAdapter()
            var calls: [String] = []
            weak var oldOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                oldOwner = owner
                adapter.display(centerView: .titledImage(.init(
                    .systemSymbol(
                        "star.fill",
                        accessibilityIdentifier: "header.center.image",
                        accessibility: .init(label: "Center image"),
                        size: .init(width: 24, height: 24),
                        onPress: {
                            _ = owner
                            calls.append("old")
                        }
                    ),
                    .text("Title")
                )))
            }

            var host: SwiftUIAccessibilityTestHost? = makeHost(adapter: adapter)
            let initialElement = try XCTUnwrap(host?.element(withLabel: "Center image"))
            XCTAssertTrue(initialElement.accessibilityActivate())
            XCTAssertEqual(calls, ["old"])

            weak var latestOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                latestOwner = owner
                adapter.display(centerView: .titledImage(.init(
                    .systemSymbol(
                        "star.fill",
                        accessibilityIdentifier: "header.center.image",
                        accessibility: .init(label: "Center image"),
                        size: .init(width: 24, height: 24),
                        onPress: {
                            _ = owner
                            calls.append("latest")
                        }
                    ),
                    .text("Title")
                )))
            }
            host?.settle()

            XCTAssertNil(oldOwner)
            let updatedElement = try XCTUnwrap(host?.element(withLabel: "Center image"))
            XCTAssertTrue(updatedElement.accessibilityActivate())
            XCTAssertEqual(calls, ["old", "latest"])

            weak var firstHost = host
            host = nil
            XCTAssertNil(firstHost)
            let remountedHost = makeHost(adapter: adapter)
            let remountedElement = try XCTUnwrap(
                remountedHost.element(withLabel: "Center image")
            )
            XCTAssertTrue(remountedElement.accessibilityActivate())
            XCTAssertEqual(calls, ["old", "latest", "latest"])

            adapter.display(centerView: nil)
            remountedHost.settle()

            XCTAssertNil(latestOwner)
            XCTAssertNil(remountedHost.element(withLabel: "Center image"))
            XCTAssertTrue(updatedElement.accessibilityActivate())
            XCTAssertEqual(calls, ["old", "latest", "latest"])
        }

        @available(iOS 17.0, *)
        func test_titledImage_usesVerticalFourPointLayoutAndModelImageSize() throws {
            let imageModel = ImageViewPresentableModel.systemSymbol(
                "star.fill",
                accessibilityIdentifier: "header.center.image",
                accessibility: .init(label: "Featured image"),
                size: .init(width: 24, height: 24),
                onPress: {}
            )
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(model: .init(
                style: makeStyle(),
                centerView: .titledImage(.init(
                    imageModel,
                    .text(
                        accessibilityIdentifier: "header.center.title",
                        accessibility: .init(label: "Featured title"),
                        "Featured"
                    )
                ))
            ))
            let host = makeHost(adapter: adapter)

            let imageFrame = try frame(ofLabel: "Featured image", in: host)
            let titleFrame = try frame(ofLabel: "Featured title", in: host)

            XCTAssertEqual(SUINavigationBarCenterLayoutMetrics.spacing, 4)
            XCTAssertEqual(
                SUINavigationBarCenterLayoutMetrics.resolvedImageSize(for: imageModel),
                CGSize(width: 24, height: 24)
            )
            XCTAssertGreaterThan(imageFrame.width, 0)
            XCTAssertGreaterThan(imageFrame.height, 0)
            XCTAssertLessThanOrEqual(imageFrame.width, 24)
            XCTAssertLessThanOrEqual(imageFrame.height, 24)
            // Pixel-aligned views with odd/even physical widths can have centers half a pixel apart.
            let halfPhysicalPixel = 0.5 / SnapshotRenderDefaults.scale
            XCTAssertEqual(imageFrame.midX, titleFrame.midX, accuracy: halfPhysicalPixel + 0.001)
            XCTAssertGreaterThanOrEqual(titleFrame.minY - imageFrame.maxY, 4)
            XCTAssertLessThan(imageFrame.minY, titleFrame.minY)
        }

        @available(iOS 17.0, *)
        func test_keyValue_usesUIKitFourPointVerticalSpacing() throws {
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(model: .init(
                style: makeStyle(),
                centerView: .keyValue(.init(
                    .text(
                        accessibilityIdentifier: "header.center.key",
                        accessibility: .init(label: "Header key"),
                        "Overview"
                    ),
                    .text(
                        accessibilityIdentifier: "header.center.value",
                        accessibility: .init(label: "Header value"),
                        "Online"
                    )
                ))
            ))
            let host = makeHost(adapter: adapter)

            let keyFrame = try frame(ofLabel: "Header key", in: host)
            let valueFrame = try frame(ofLabel: "Header value", in: host)

            XCTAssertEqual(SUINavigationBarCenterLayoutMetrics.spacing, 4)
            XCTAssertGreaterThanOrEqual(valueFrame.minY - keyFrame.maxY, 4)
            XCTAssertEqual(keyFrame.midX, valueFrame.midX, accuracy: 0.001)
        }

        @available(iOS 17.0, *)
        func test_threeCatalogTrailingButtons_keepExactModelGeometryAndCallbacks() throws {
            let adapter = HeaderOutputSwiftUIAdapter()
            var callbacks: [String] = []
            adapter.display(model: .init(
                style: makeStyle(horizontalSpacing: 12),
                primeTrailingImage: makeButton(
                    id: "header.trailing.help",
                    label: "Help",
                    systemName: "questionmark.circle",
                    onPress: { callbacks.append("help") }
                ),
                secondaryTrailingImage: makeButton(
                    id: "header.trailing.notifications",
                    label: "Notifications",
                    systemName: "bell",
                    onPress: { callbacks.append("notifications") }
                ),
                tertiaryTrailingImage: makeButton(
                    id: "header.trailing.profile",
                    label: "Profile",
                    systemName: "person.crop.circle",
                    onPress: { callbacks.append("profile") }
                )
            ))
            let host = makeHost(adapter: adapter)

            let buttons = try ["Help", "Notifications", "Profile"].map { label -> NSObject in
                try XCTUnwrap(host.element(withLabel: label))
            }
            let frames = buttons.map(\.accessibilityFrame)

            for frame in frames {
                XCTAssertEqual(frame.width, 32, accuracy: 0.001)
                XCTAssertEqual(frame.height, 32, accuracy: 0.001)
                XCTAssertEqual(frame.midY, frames[0].midY, accuracy: 0.001)
            }
            XCTAssertEqual(frames[1].minX - frames[0].maxX, 18, accuracy: 0.001)
            XCTAssertEqual(frames[2].minX - frames[1].maxX, 18, accuracy: 0.001)
            XCTAssertEqual(
                host.frame.maxX - frames[2].maxX,
                expectedHorizontalInset,
                accuracy: 0.001
            )

            buttons.forEach { XCTAssertTrue($0.accessibilityActivate()) }
            XCTAssertEqual(callbacks, ["help", "notifications", "profile"])
        }

        @available(iOS 17.0, *)
        func test_trailingButton_explicitTitleColorSurvivesHeaderPrimeColorUpdatesLikeUIKit() throws {
            var presses = 0
            let button = ButtonPresentableModel(
                accessibilityIdentifier: "header.colored",
                accessibility: .init(label: "Blue button"),
                title: "Blue",
                height: 44,
                width: 100,
                style: .init(titleColor: .blue),
                onPress: { presses += 1 }
            )
            let initialModel = HeaderPresentableModel(
                style: makeStyle(primeColor: .red),
                primeTrailingImage: button
            )
            let nativeHeader = NavigationBar()
            nativeHeader.display(model: initialModel)
            let nativeHost = SwiftUIAccessibilityTestHost(
                rootView: UIKitHeaderProbe(header: nativeHeader)
                    .frame(width: containerWidth, height: 200)
                    .ignoresSafeArea(),
                size: CGSize(width: containerWidth, height: 200)
            )
            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(model: initialModel)
            let swiftUIHost = makeHost(adapter: adapter)

            for (color, name) in [(UIColor.red, "red"), (UIColor.green, "green")] {
                let style = makeStyle(primeColor: color)
                nativeHeader.display(style: style)
                adapter.display(style: style)
                nativeHost.settle()
                swiftUIHost.settle()

                XCTAssertEqual(nativeHeader.primeTrailingImageWrapperView.contentView.tintColor, color)
                _ = try XCTUnwrap(swiftUIHost.element(withIdentifier: "header.colored"))
                let nativePixels = try renderedColorCounts(in: nativeHeader, named: "UIKit blue button over \(name) header tint")
                let swiftUIView = try XCTUnwrap(swiftUIHost.firstSubview(of: UIView.self))
                let swiftUIPixels = try renderedColorCounts(in: swiftUIView, named: "SwiftUI blue button over \(name) header tint")

                XCTAssertGreaterThan(nativePixels.blue, 10, "UIKit must visibly render the explicit blue foreground; counts=\(nativePixels)")
                XCTAssertGreaterThan(swiftUIPixels.blue, 10, "SwiftUI must visibly render the explicit blue foreground; counts=\(swiftUIPixels)")
                XCTAssertEqual(swiftUIPixels.red + swiftUIPixels.green, 0, "Header tint must not override the button's explicit foreground")
            }

            nativeHeader.primeTrailingImageWrapperView.contentView.sendActions(for: .touchUpInside)
            XCTAssertTrue(try XCTUnwrap(swiftUIHost.element(withIdentifier: "header.colored")).accessibilityActivate())
            XCTAssertEqual(presses, 2)
        }

        @available(iOS 17.0, *)
        func test_trailingButtonBorder_rendersInsideOutputBounds() throws {
            let adapter = HeaderOutputSwiftUIAdapter()
            let buttonSize = CGSize(width: 80, height: 24)
            adapter.display(model: .init(
                style: makeStyle(),
                primeTrailingImage: .init(
                    accessibilityIdentifier: "header.bordered",
                    accessibility: .init(label: "Bordered button"),
                    title: "Border",
                    height: buttonSize.height,
                    width: buttonSize.width,
                    style: .init(
                        backgroundColor: .white,
                        titleColor: .black,
                        borderWidth: 4,
                        borderColor: .red,
                        font: .systemFont(ofSize: 12),
                        cornerStyle: .fixed(8)
                    ),
                    onPress: {}
                )
            ))
            let host = makeHost(adapter: adapter)
            let button = try XCTUnwrap(host.element(withIdentifier: "header.bordered"))
            let buttonBounds = button.accessibilityFrame.offsetBy(
                dx: -host.frame.minX,
                dy: -host.frame.minY
            )
            XCTAssertEqual(buttonBounds.width, buttonSize.width, accuracy: 0.001)
            XCTAssertEqual(buttonBounds.height, buttonSize.height, accuracy: 0.001)

            let view = try XCTUnwrap(host.firstSubview(of: UIView.self))
            let borderBounds = try renderedRedPixelBounds(in: view)
            let onePhysicalPixel = 1 / UIScreen.main.scale
            XCTAssertGreaterThan(borderBounds.width, 0, "The border must actually render")
            XCTAssertGreaterThan(borderBounds.height, 0, "The border must actually render")
            XCTAssertGreaterThanOrEqual(borderBounds.minX, buttonBounds.minX - onePhysicalPixel)
            XCTAssertGreaterThanOrEqual(borderBounds.minY, buttonBounds.minY - onePhysicalPixel)
            XCTAssertLessThanOrEqual(borderBounds.maxX, buttonBounds.maxX + onePhysicalPixel)
            XCTAssertLessThanOrEqual(borderBounds.maxY, buttonBounds.maxY + onePhysicalPixel)
        }

        @available(iOS 17.0, *)
        func test_leadingCardWithLeadingAndTrailingTitles_usesUIKitHorizontalGeometry() throws {
            guard #available(iOS 26.0, *) else {
                throw XCTSkip("The iOS 18 renderer uses the legacy navigation bar geometry")
            }

            let style = HeaderPresentableModel.Style(
                backgroundColor: .red,
                horizontalSpacing: 1,
                primeFont: .boldSystemFont(ofSize: 24),
                primeColor: .blue,
                secondaryFont: .systemFont(ofSize: 14),
                secondaryColor: .green
            )
            let leadingCard = CardViewPresentableModel(
                accessibilityIdentifier: "navigation.leading-card",
                accessibility: .init(label: "Leading card"),
                title: .text(
                    accessibilityIdentifier: "navigation.leading-card.title",
                    accessibility: .init(label: "Card title"),
                    "Title"
                ),
                leadingTitles: .init(
                    .text(
                        accessibilityIdentifier: "navigation.leading-card.leading-key",
                        accessibility: .init(label: "Leading key"),
                        "First title"
                    ),
                    .text("Second title")
                ),
                trailingTitles: .init(
                    .text(
                        accessibilityIdentifier: "navigation.leading-card.trailing-key",
                        accessibility: .init(label: "Trailing key"),
                        "First title"
                    ),
                    .text("Second title")
                )
            )

            let adapter = HeaderOutputSwiftUIAdapter()
            adapter.display(style: style)
            adapter.display(leadingCard: leadingCard)
            let swiftUIHost = makeHost(adapter: adapter)
            let swiftUICardFrame = try frame(ofLabel: "Leading card", in: swiftUIHost)
                .offsetBy(dx: -swiftUIHost.frame.minX, dy: -swiftUIHost.frame.minY)
            let swiftUILeadingFrame = try frame(ofLabel: "Leading key", in: swiftUIHost)
                .offsetBy(dx: -swiftUIHost.frame.minX, dy: -swiftUIHost.frame.minY)
            let swiftUITitleFrame = try frame(ofLabel: "Card title", in: swiftUIHost)
                .offsetBy(dx: -swiftUIHost.frame.minX, dy: -swiftUIHost.frame.minY)
            let swiftUITrailingFrame = try frame(ofLabel: "Trailing key", in: swiftUIHost)
                .offsetBy(dx: -swiftUIHost.frame.minX, dy: -swiftUIHost.frame.minY)

            let uiKitView = NavigationBar(frame: CGRect(x: 0, y: 0, width: containerWidth, height: 80))
            uiKitView.display(style: style)
            uiKitView.display(leadingCard: leadingCard)
            uiKitView.setNeedsLayout()
            uiKitView.layoutIfNeeded()
            let uiKitLeadingFrame = uiKitView.leadingCardView.leadingTitleViews.keyLabel.convert(
                uiKitView.leadingCardView.leadingTitleViews.keyLabel.bounds,
                to: uiKitView
            )
            let uiKitTitleFrame = uiKitView.leadingCardView.titleViews.keyLabel.convert(
                uiKitView.leadingCardView.titleViews.keyLabel.bounds,
                to: uiKitView
            )
            let uiKitTrailingFrame = uiKitView.leadingCardView.trailingTitleViews.keyLabel.convert(
                uiKitView.leadingCardView.trailingTitleViews.keyLabel.bounds,
                to: uiKitView
            )
            let uiKitTrailingTextWidth = uiKitView.leadingCardView.trailingTitleViews.keyLabel
                .intrinsicContentSize.width
            let uiKitTrailingTextMinX = uiKitTrailingFrame.midX - uiKitTrailingTextWidth / 2

            let halfPhysicalPixel = 0.5 / SnapshotRenderDefaults.scale
            XCTAssertEqual(swiftUILeadingFrame.minX, uiKitLeadingFrame.minX, accuracy: halfPhysicalPixel)
            XCTAssertEqual(swiftUITitleFrame.minX, uiKitTitleFrame.minX, accuracy: halfPhysicalPixel)
            XCTAssertEqual(swiftUITrailingFrame.minX, uiKitTrailingTextMinX, accuracy: halfPhysicalPixel)
            XCTAssertEqual(swiftUITrailingFrame.width, uiKitTrailingTextWidth, accuracy: halfPhysicalPixel)
            XCTAssertEqual(swiftUICardFrame.width, uiKitView.leadingCardView.hStackView.frame.width, accuracy: halfPhysicalPixel)
        }

        func test_sideWidthResolver_prefersEqualityButContainsImpossibleOverflow() {
            let equal = SUINavigationBarSideWidthResolver.resolvedSideWidths(
                availableWidth: 358,
                mainStackSpacing: 8,
                leadingIdealWidth: 44,
                trailingIdealWidth: 132
            )
            XCTAssertEqual(equal.leading, 171, accuracy: 0.001)
            XCTAssertEqual(equal.trailing, 171, accuracy: 0.001)

            let brokenEquality = SUINavigationBarSideWidthResolver.resolvedSideWidths(
                availableWidth: 358,
                mainStackSpacing: 8,
                leadingIdealWidth: 44,
                trailingIdealWidth: 200
            )
            XCTAssertEqual(brokenEquality.leading, 44, accuracy: 0.001)
            XCTAssertEqual(brokenEquality.trailing, 200, accuracy: 0.001)

            let overflow = SUINavigationBarSideWidthResolver.resolvedSideWidths(
                availableWidth: 100,
                mainStackSpacing: 8,
                leadingIdealWidth: 60,
                trailingIdealWidth: 120
            )
            XCTAssertEqual(overflow.leading + overflow.trailing, 84, accuracy: 0.001)
            XCTAssertGreaterThanOrEqual(overflow.leading, 0)
            XCTAssertGreaterThanOrEqual(overflow.trailing, 0)

            let compressibleLeadingCard = SUINavigationBarSideWidthResolver.resolvedSideWidths(
                availableWidth: 358,
                mainStackSpacing: 8,
                leadingIdealWidth: 256.667,
                trailingIdealWidth: 0,
                leadingCompressionBreakpointWidth: 233,
                trailingCompressionBreakpointWidth: 0
            )
            XCTAssertEqual(compressibleLeadingCard.leading, 233, accuracy: 0.001)
            XCTAssertEqual(compressibleLeadingCard.trailing, 0, accuracy: 0.001)
        }

        @available(iOS 17.0, *)
        func test_glassForegroundResolver_usesOpaqueContrastAndDefersTranslucentBackdrop() {
            var lightEnvironment = EnvironmentValues()
            lightEnvironment.colorScheme = .light
            var darkEnvironment = EnvironmentValues()
            darkEnvironment.colorScheme = .dark

            for environment in [lightEnvironment, darkEnvironment] {
                XCTAssertEqual(
                    SUINavigationBarGlassForegroundResolver.color(
                        over: SwiftUIColor(.red),
                        environment: environment
                    )?.resolve(in: environment),
                    SwiftUIColor.white.resolve(in: environment)
                )
                XCTAssertEqual(
                    SUINavigationBarGlassForegroundResolver.color(
                        over: SwiftUIColor(.yellow),
                        environment: environment
                    )?.resolve(in: environment),
                    SwiftUIColor.black.resolve(in: environment)
                )
            }
            XCTAssertNil(
                SUINavigationBarGlassForegroundResolver.color(
                    over: SwiftUIColor.clear,
                    environment: lightEnvironment
                )
            )
            XCTAssertNil(
                SUINavigationBarGlassForegroundResolver.color(
                    over: SwiftUIColor.clear,
                    environment: darkEnvironment
                )
            )
            XCTAssertNil(
                SUINavigationBarGlassForegroundResolver.color(
                    over: SwiftUIColor.red.opacity(0.5),
                    environment: lightEnvironment
                )
            )
        }
    }

    private extension SUINavigationBarParityTests {
        struct UIKitHeaderProbe: UIViewRepresentable {
            let header: NavigationBar

            func makeUIView(context: Context) -> UIView {
                let container = UIView()
                container.addSubview(header)
                header.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    header.topAnchor.constraint(equalTo: container.topAnchor),
                    header.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    header.trailingAnchor.constraint(equalTo: container.trailingAnchor)
                ])
                return container
            }

            func updateUIView(_ uiView: UIView, context: Context) {}
        }

        func renderedColorCounts(in view: UIView, named name: String) throws -> (red: Int, green: Int, blue: Int) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            format.opaque = false
            let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
                XCTAssertTrue(view.drawHierarchy(in: view.bounds, afterScreenUpdates: true))
            }
            let attachment = XCTAttachment(image: image)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)

            let cgImage = try XCTUnwrap(image.cgImage)
            var pixels = [UInt8](repeating: 0, count: cgImage.width * cgImage.height * 4)
            try pixels.withUnsafeMutableBytes { bytes in
                let context = try XCTUnwrap(CGContext(
                    data: bytes.baseAddress,
                    width: cgImage.width,
                    height: cgImage.height,
                    bitsPerComponent: 8,
                    bytesPerRow: cgImage.width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue
                        | CGImageAlphaInfo.premultipliedLast.rawValue
                ))
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
            }
            var counts = [0, 0, 0]
            for index in stride(from: 0, to: pixels.count, by: 4) where pixels[index + 3] > 200 {
                for channel in 0..<3 {
                    let otherChannels = (0..<3).filter { $0 != channel }
                    if pixels[index + channel] > 180,
                       otherChannels.allSatisfy({ pixels[index + $0] < 80 }) {
                        counts[channel] += 1
                    }
                }
            }
            return (red: counts[0], green: counts[1], blue: counts[2])
        }

        func renderedRedPixelBounds(in view: UIView) throws -> CGRect {
            let format = UIGraphicsImageRendererFormat()
            format.scale = UIScreen.main.scale
            format.opaque = false
            let image = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { _ in
                XCTAssertTrue(view.drawHierarchy(in: view.bounds, afterScreenUpdates: true))
            }
            let cgImage = try XCTUnwrap(image.cgImage)
            let width = cgImage.width
            let height = cgImage.height
            var pixels = [UInt8](repeating: 0, count: width * height * 4)
            try pixels.withUnsafeMutableBytes { bytes in
                let context = try XCTUnwrap(CGContext(
                    data: bytes.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue
                        | CGImageAlphaInfo.premultipliedLast.rawValue
                ))
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }

            var minimumX = width
            var minimumY = height
            var maximumX = -1
            var maximumY = -1
            for index in stride(from: 0, to: pixels.count, by: 4) {
                guard pixels[index] > 200, pixels[index + 1] < 80,
                      pixels[index + 2] < 80, pixels[index + 3] > 200 else { continue }
                let pixelIndex = index / 4
                minimumX = min(minimumX, pixelIndex % width)
                maximumX = max(maximumX, pixelIndex % width)
                minimumY = min(minimumY, pixelIndex / width)
                maximumY = max(maximumY, pixelIndex / width)
            }
            // An absent border must fail, not vacuously satisfy the containment checks.
            let bounds: CGRect? = maximumX >= minimumX && maximumY >= minimumY
                ? CGRect(
                    x: CGFloat(minimumX) / image.scale,
                    y: CGFloat(minimumY) / image.scale,
                    width: CGFloat(maximumX - minimumX + 1) / image.scale,
                    height: CGFloat(maximumY - minimumY + 1) / image.scale
                )
                : nil
            return try XCTUnwrap(bounds, "Expected visible red border pixels in the rendered navigation bar")
        }

        func firstTextAction(
            in model: TextOutputPresentableModel.TextModel?
        ) -> (() -> Void)? {
            switch model {
            case .attributes(let attributes):
                return attributes.first?.onTap
            case .textStyled(let text, _, _, _, _):
                return firstTextAction(in: text)
            default:
                return nil
            }
        }

        @available(iOS 17.0, *)
        func makeHost(adapter: HeaderOutputSwiftUIAdapter) -> SwiftUIAccessibilityTestHost {
            SwiftUIAccessibilityTestHost(
                rootView: SUINavigationBar(adapter: adapter)
                    .frame(width: containerWidth, alignment: .top)
                    .ignoresSafeArea(),
                size: CGSize(width: containerWidth, height: 80)
            )
        }

        @available(iOS 17.0, *)
        func frame(
            ofLabel accessibilityLabel: String,
            in host: SwiftUIAccessibilityTestHost
        ) throws -> CGRect {
            try XCTUnwrap(
                host.element(withLabel: accessibilityLabel)
            ).accessibilityFrame
        }

        func makeStyle(
            horizontalSpacing: CGFloat = 8,
            primeFont: UIFont = .systemFont(ofSize: 17, weight: .semibold),
            primeColor: UIColor = .label
        ) -> HeaderPresentableModel.Style {
            .init(
                backgroundColor: .systemGroupedBackground,
                horizontalSpacing: horizontalSpacing,
                primeFont: primeFont,
                primeColor: primeColor,
                secondaryFont: .systemFont(ofSize: 12),
                secondaryColor: .secondaryLabel,
                numberOfLines: 1
            )
        }

        func makeLeadingCardStyle() -> CardViewPresentableModel.Style {
            .init(
                backgroundColor: .clear,
                vStacklayoutMargins: .zero,
                hStacklayoutMargins: .zero,
                hStackViewDistribution: .fill,
                leadingTitleKeyTextColor: .label,
                titleKeyTextColor: .systemRed,
                trailingTitleKeyTextColor: .label,
                titleValueTextColor: .label,
                subTitleTextColor: .secondaryLabel,
                leadingTitleKeyLabelFont: .systemFont(ofSize: 10),
                titleKeyLabelFont: .systemFont(ofSize: 11),
                trailingTitleKeyLabelFont: .systemFont(ofSize: 12),
                titleValueLabelFont: .systemFont(ofSize: 13),
                subTitleLabelFont: .systemFont(ofSize: 14),
                cornerRadius: 0,
                stackSpace: 0,
                hStackViewSpacing: 8,
                titleKeyNumberOfLines: 1,
                titleValueNumberOfLines: 1
            )
        }

        func makeButton(
            id: String,
            label: String,
            systemName: String,
            onPress: @escaping () -> Void
        ) -> ButtonPresentableModel {
            .init(
                accessibilityIdentifier: id,
                accessibility: .init(label: label),
                image: ImageFactory.systemImage(named: systemName),
                height: 32,
                width: 32,
                onPress: onPress
            )
        }

        var expectedHorizontalInset: CGFloat {
            if #available(iOS 26, *), isLiquidGlassEnabled {
                return 16
            }
            return 8
        }
    }
#endif
