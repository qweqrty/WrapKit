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
