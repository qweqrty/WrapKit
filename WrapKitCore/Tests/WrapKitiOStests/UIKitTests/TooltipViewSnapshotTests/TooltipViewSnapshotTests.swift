@testable import WrapKit
import WrapKitTestUtils
import XCTest

final class TooltipViewSnapshotTests: XCTestCase {
    private enum TargetPosition {
        case center
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing
    }

    func test_tooltipView_defaultState() {
        let snapshotName = "TOOLTIP_VIEW_DEFAULT_STATE"
        let (sut, snapshotView) = makeSUT()

        sut.display(tooltipModel: nil)
        snapshotView.layoutIfNeeded()

        assertSnapshots(container: snapshotView, snapshotName: snapshotName)
    }

    func test_tooltipView_withTapTrigger() {
        let snapshotName = "TOOLTIP_VIEW_TAP_TRIGGER"
        let (sut, snapshotView) = makeSUT()
        let tooltipItems = makeTooltipItems()

        sut.display(tooltipModel: .init(
            items: tooltipItems,
            trigger: .tap
        ))

        XCTAssertEqual(sut.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.count, 1)

        assertSnapshots(container: snapshotView, snapshotName: snapshotName)
    }

    func test_tooltipView_withLongPressTrigger() {
        let snapshotName = "TOOLTIP_VIEW_LONGPRESS_TRIGGER"
        let (sut, snapshotView) = makeSUT()
        let tooltipItems = makeTooltipItems()

        sut.display(tooltipModel: .init(
            items: tooltipItems,
            trigger: .longPress(minimumPressDuration: 0.35)
        ))

        let gesture = sut.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }.first
        XCTAssertEqual(gesture?.minimumPressDuration, 0.35)

        assertSnapshots(container: snapshotView, snapshotName: snapshotName)
    }

    func test_tooltipView_withImmediateTrigger() {
        let snapshotName = "TOOLTIP_VIEW_IMMEDIATE_TRIGGER"
        let (sut, snapshotView) = makeSUT()
        let tooltipItems = makeTooltipItems()

        sut.display(tooltipModel: .init(
            items: tooltipItems,
            trigger: .immediate()
        ))
        XCTAssertNotNil(sut.tooltipPresentationIdentifier)

        // Cancel the queued presentation before snapshotting the target itself.
        // The window-hosted tests below validate the system menu contract.
        sut.display(tooltipModel: nil)
        flushMainQueue()
        XCTAssertFalse(sut.isTooltipMenuPresented)

        assertSnapshots(container: snapshotView, snapshotName: snapshotName)
    }

    func test_tooltipView_withTapTrigger_topLeadingTarget() {
        assertTapTooltip(
            snapshotName: "TOOLTIP_VIEW_TAP_TRIGGER_TOP_LEADING_TARGET",
            targetPosition: .topLeading
        )
    }

    func test_tooltipView_withTapTrigger_topTrailingTarget() {
        assertTapTooltip(
            snapshotName: "TOOLTIP_VIEW_TAP_TRIGGER_TOP_TRAILING_TARGET",
            targetPosition: .topTrailing
        )
    }

    func test_tooltipView_withTapTrigger_bottomLeadingTarget() {
        assertTapTooltip(
            snapshotName: "TOOLTIP_VIEW_TAP_TRIGGER_BOTTOM_LEADING_TARGET",
            targetPosition: .bottomLeading
        )
    }

    func test_tooltipView_withTapTrigger_bottomTrailingTarget() {
        assertTapTooltip(
            snapshotName: "TOOLTIP_VIEW_TAP_TRIGGER_BOTTOM_TRAILING_TARGET",
            targetPosition: .bottomTrailing
        )
    }

    private func assertTapTooltip(snapshotName: String, targetPosition: TargetPosition) {
        let (sut, snapshotView) = makeSUT(targetPosition: targetPosition)
        let tooltipItems = makeTooltipItems()

        sut.display(tooltipModel: .init(
            items: tooltipItems,
            trigger: .tap
        ))

        XCTAssertEqual(sut.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.count, 1)

        assertSnapshots(container: snapshotView, snapshotName: snapshotName)
    }

    @available(iOS 16.0, *)
    func test_tooltipView_tapTrigger_presentsMenuFromWindowAndRunsSelectedAction() throws {
        let (sut, host) = try makeHostedSUT()
        let presentationSpy = TooltipEditMenuPresentationSpy(view: sut)
        var selectedItem: String?
        var dismissCount = 0

        sut.display(tooltipModel: .init(
            items: [
                .init(title: "Copy", onTap: { selectedItem = "Copy" }),
                .init(title: "Share", onTap: { selectedItem = "Share" })
            ],
            trigger: .tap,
            onDismiss: { dismissCount += 1 }
        ))

        simulateTapTrigger(on: sut, state: .possible)
        XCTAssertFalse(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 0)

        simulateTapTrigger(on: sut, state: .ended)

        XCTAssertNotNil(sut.window)
        XCTAssertTrue(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 1)
        let interaction = try XCTUnwrap(sut.interactions.compactMap { $0 as? UIEditMenuInteraction }.first)
        let configuration = try makeActiveConfiguration(for: sut)
        XCTAssertTrue(presentationSpy.invocations[0].interaction === interaction)
        XCTAssertEqual(presentationSpy.invocations[0].identifier, configuration.identifier as? NSString)
        let menu = try XCTUnwrap(sut.editMenuInteraction(
            interaction,
            menuFor: configuration,
            suggestedActions: []
        ))
        let actions = try XCTUnwrap(menu.children as? [UIAction])
        XCTAssertEqual(actions.map(\.title), ["Copy", "Share"])

        let actionHost = UIButton()
        actionHost.addAction(actions[1], for: .touchUpInside)
        actionHost.sendActions(for: .touchUpInside)
        XCTAssertEqual(selectedItem, "Share")

        sut.editMenuInteraction(
            interaction,
            willDismissMenuFor: configuration,
            animator: nil
        )
        XCTAssertEqual(dismissCount, 0, "Selecting an item must not also report a plain dismissal")
        XCTAssertFalse(sut.isTooltipMenuPresented)

        sut.display(tooltipModel: nil)
        host.hide()
    }

    @available(iOS 16.0, *)
    func test_defaultEditMenuPresentation_callsUIKitInteraction() throws {
        let sut = ViewUIKit()
        let interaction = TooltipEditMenuInteractionSpy()
        let identifier = UUID().uuidString as NSString
        let point = CGPoint(x: 12, y: 24)

        sut.tooltipEditMenuPresentation(interaction, identifier, point)

        let configuration = try XCTUnwrap(interaction.presentedConfiguration)
        XCTAssertEqual(configuration.identifier as? NSString, identifier)
        XCTAssertEqual(configuration.sourcePoint, point)
    }

    @available(iOS 16.0, *)
    func test_tooltipView_longPressTrigger_presentsMenuOnlyOnBegan() throws {
        let (sut, host) = try makeHostedSUT()
        let presentationSpy = TooltipEditMenuPresentationSpy(view: sut)

        sut.display(tooltipModel: .init(
            items: makeTooltipItems(),
            trigger: .longPress(minimumPressDuration: 0.35)
        ))

        let installedGesture = try XCTUnwrap(
            sut.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }.first
        )
        XCTAssertEqual(installedGesture.minimumPressDuration, 0.35)

        simulateLongPressTrigger(on: sut, state: .possible)
        XCTAssertFalse(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 0)

        simulateLongPressTrigger(on: sut, state: .began)
        XCTAssertTrue(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 1)
        XCTAssertEqual(sut.interactions.compactMap { $0 as? UIEditMenuInteraction }.count, 1)

        sut.display(tooltipModel: nil)
        host.hide()
    }

    @available(iOS 16.0, *)
    func test_tooltipView_immediateTrigger_presentsMenuFromWindow() throws {
        let (sut, host) = try makeHostedSUT()
        let presentationSpy = TooltipEditMenuPresentationSpy(view: sut)

        sut.display(tooltipModel: .init(
            items: makeTooltipItems(),
            trigger: .immediate(anchorPoint: CGPoint(x: 10, y: 12))
        ))
        flushMainQueue()

        XCTAssertNotNil(sut.window)
        XCTAssertTrue(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 1)
        XCTAssertEqual(presentationSpy.invocations[0].point, CGPoint(x: 10, y: 12))
        XCTAssertEqual(sut.interactions.compactMap { $0 as? UIEditMenuInteraction }.count, 1)

        sut.display(tooltipModel: nil)
        host.hide()
    }

    @available(iOS 16.0, *)
    func test_tooltipView_dismissWithoutSelection_callsOnDismissOnce() throws {
        let (sut, host) = try makeHostedSUT()
        let presentationSpy = TooltipEditMenuPresentationSpy(view: sut)
        var dismissCount = 0

        sut.display(tooltipModel: .init(
            items: makeTooltipItems(),
            trigger: .immediate(),
            onDismiss: { dismissCount += 1 }
        ))
        flushMainQueue()
        XCTAssertEqual(presentationSpy.invocations.count, 1)

        let interaction = try XCTUnwrap(sut.interactions.compactMap { $0 as? UIEditMenuInteraction }.first)
        let configuration = try makeActiveConfiguration(for: sut)
        sut.editMenuInteraction(
            interaction,
            willDismissMenuFor: configuration,
            animator: nil
        )
        sut.editMenuInteraction(
            interaction,
            willDismissMenuFor: configuration,
            animator: nil
        )

        XCTAssertEqual(dismissCount, 1)
        XCTAssertFalse(sut.isTooltipMenuPresented)

        sut.display(tooltipModel: nil)
        host.hide()
    }

    @available(iOS 16.0, *)
    func test_tooltipView_programmaticHide_cancelsPendingAndVisibleMenuWithoutOnDismiss() throws {
        let (sut, host) = try makeHostedSUT()
        let presentationSpy = TooltipEditMenuPresentationSpy(view: sut)
        var dismissCount = 0

        sut.display(tooltipModel: .init(
            items: makeTooltipItems(),
            trigger: .immediate(),
            onDismiss: { dismissCount += 1 }
        ))
        flushMainQueue()
        XCTAssertEqual(presentationSpy.invocations.count, 1)

        let interaction = try XCTUnwrap(sut.interactions.compactMap { $0 as? UIEditMenuInteraction }.first)
        let oldConfiguration = try makeActiveConfiguration(for: sut)
        sut.display(tooltipModel: nil)
        flushMainQueue()

        XCTAssertNil(sut.tooltipPresentationIdentifier)
        XCTAssertFalse(sut.isTooltipMenuPresented)
        XCTAssertEqual(dismissCount, 0)

        // UIKit may deliver the old interaction's callback after dismissMenu().
        sut.editMenuInteraction(
            interaction,
            willDismissMenuFor: oldConfiguration,
            animator: nil
        )
        XCTAssertEqual(dismissCount, 0)

        host.hide()
    }

    func test_tooltipView_legacyMenuItems_matchTitlesAndSelectors() throws {
        let sut = ViewUIKit()
        var selectedItem: String?
        sut.display(tooltipModel: .init(
            items: [
                .init(title: "Copy", onTap: { selectedItem = "Copy" }),
                .init(title: "Share", onTap: { selectedItem = "Share" })
            ],
            trigger: .tap
        ))

        let menuItems = sut.makeLegacyTooltipMenuItems()
        XCTAssertEqual(menuItems.map(\.title), ["Copy", "Share"])
        XCTAssertTrue(sut.canPerformAction(menuItems[0].action, withSender: nil))
        XCTAssertTrue(sut.canPerformAction(menuItems[1].action, withSender: nil))

        _ = sut.perform(menuItems[1].action)
        XCTAssertEqual(selectedItem, "Share")
    }

    @available(iOS 16.0, *)
    func test_tooltipView_immediateTriggerWaitsUntilAttachedToWindow() throws {
        let (sut, container) = makeSUT()
        let presentationSpy = TooltipEditMenuPresentationSpy(view: sut)
        sut.display(tooltipModel: .init(
            items: makeTooltipItems(),
            trigger: .immediate()
        ))

        flushMainQueue()

        XCTAssertNil(sut.window)
        XCTAssertFalse(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 0)

        let scene = try XCTUnwrap(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        )
        let host = TooltipWindowHost(scene: scene, contentView: container)

        XCTAssertTrue(sut.isTooltipMenuPresented)
        XCTAssertEqual(presentationSpy.invocations.count, 1)

        sut.display(tooltipModel: nil)
        host.hide()
    }

    func test_legacyTooltipMenuOwnership_replacesOnlyTheCurrentOwner() {
        let sut = TooltipLegacyMenuOwnership()
        let firstOwner = TooltipLegacyMenuOwnerSpy()
        let secondOwner = TooltipLegacyMenuOwnerSpy()

        sut.claim(firstOwner)
        sut.claim(secondOwner)
        XCTAssertEqual(firstOwner.replacementCount, 1)
        XCTAssertEqual(secondOwner.replacementCount, 0)

        sut.release(firstOwner)
        sut.claim(firstOwner)
        XCTAssertEqual(firstOwner.replacementCount, 1)
        XCTAssertEqual(secondOwner.replacementCount, 1)

        sut.release(firstOwner)
        sut.claim(secondOwner)
        XCTAssertEqual(firstOwner.replacementCount, 1)
        XCTAssertEqual(secondOwner.replacementCount, 1)
    }
}

private extension TooltipViewSnapshotTests {
    func assertSnapshots(container: UIView, snapshotName: String) {
        if #available(iOS 26, *) {
            assert(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            assert(
                snapshot: container.snapshot(for: .iPhone(style: .light)),
                named: "iOS18.5_\(snapshotName)_LIGHT",
                precision: 0.999,
                perceptualPrecision: 0.98
            )
            assert(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
        }
    }

    func makeTooltipItems() -> [TooltipViewPresentableModel.Item] {
        [
            .init(title: "Copy", onTap: {}),
            .init(title: "Share", onTap: {})
        ]
    }

    private func makeSUT(
        targetPosition: TargetPosition = .center,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ViewUIKit, snapshotView: UIView) {
        let sut = ViewUIKit()
        let container = UIView()
        let content = UIView()

        container.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        container.backgroundColor = .systemBackground

        container.addSubview(content)
        content.fillSuperview()
        content.backgroundColor = .systemBackground

        let host = UIView()
        content.addSubview(host)
        host.anchor(
            .top(content.safeAreaLayoutGuide.topAnchor, constant: 12, priority: .required),
            .leading(content.leadingAnchor, constant: 16, priority: .required),
            .trailing(content.trailingAnchor, constant: 16, priority: .required),
            .bottom(content.safeAreaLayoutGuide.bottomAnchor, constant: 12, priority: .required)
        )
        host.backgroundColor = .secondarySystemBackground
        host.layer.cornerRadius = 20

        host.addSubview(sut)
        let targetWidth: CGFloat = 220
        let targetHeight: CGFloat = 64
        switch targetPosition {
        case .center:
            sut.anchor(
                .centerX(host.centerXAnchor, constant: 0),
                .centerY(host.centerYAnchor, constant: 0),
                .width(targetWidth, priority: .required),
                .height(targetHeight, priority: .required)
            )
        case .topLeading:
            sut.anchor(
                .top(host.topAnchor, constant: 16, priority: .required),
                .leading(host.leadingAnchor, constant: 16, priority: .required),
                .width(targetWidth, priority: .required),
                .height(targetHeight, priority: .required)
            )
        case .topTrailing:
            sut.anchor(
                .top(host.topAnchor, constant: 16, priority: .required),
                .trailing(host.trailingAnchor, constant: 16, priority: .required),
                .width(targetWidth, priority: .required),
                .height(targetHeight, priority: .required)
            )
        case .bottomLeading:
            sut.anchor(
                .bottom(host.bottomAnchor, constant: 180, priority: .required),
                .leading(host.leadingAnchor, constant: 16, priority: .required),
                .width(targetWidth, priority: .required),
                .height(targetHeight, priority: .required)
            )
        case .bottomTrailing:
            sut.anchor(
                .bottom(host.bottomAnchor, constant: 180, priority: .required),
                .trailing(host.trailingAnchor, constant: 16, priority: .required),
                .width(targetWidth, priority: .required),
                .height(targetHeight, priority: .required)
            )
        }
        sut.backgroundColor = .tertiarySystemBackground
        sut.layer.cornerRadius = 14
        sut.layer.borderWidth = 1
        sut.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.65).cgColor

        container.layoutIfNeeded()
//        checkForMemoryLeaks(sut, file: file, line: line)
//        checkForMemoryLeaks(container, file: file, line: line)
        return (sut, container)
    }

    func simulateTapTrigger(on view: ViewUIKit, state: UIGestureRecognizer.State) {
        let gesture = TapGestureRecognizerStub(state: state)
        _ = view.perform(NSSelectorFromString("handleTooltipTap:"), with: gesture)
    }

    func simulateLongPressTrigger(on view: ViewUIKit, state: UIGestureRecognizer.State) {
        let gesture = LongPressGestureRecognizerStub(state: state)
        _ = view.perform(NSSelectorFromString("handleTooltipLongPress:"), with: gesture)
    }

    func makeHostedSUT() throws -> (sut: ViewUIKit, host: TooltipWindowHost) {
        let (sut, container) = makeSUT()
        let scene = try XCTUnwrap(
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
            "Tooltip interaction tests require an application window scene"
        )
        let host = TooltipWindowHost(scene: scene, contentView: container)
        flushMainQueue()
        XCTAssertNotNil(sut.window)
        return (sut, host)
    }

    @available(iOS 16.0, *)
    func makeActiveConfiguration(for view: ViewUIKit) throws -> UIEditMenuConfiguration {
        let identifier = try XCTUnwrap(view.tooltipPresentationIdentifier)
        return UIEditMenuConfiguration(identifier: identifier, sourcePoint: .zero)
    }

    func flushMainQueue() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

}

private final class TapGestureRecognizerStub: UITapGestureRecognizer {
    private var reportedState: UIGestureRecognizer.State

    init(state: UIGestureRecognizer.State) {
        reportedState = state
        super.init(target: nil, action: nil)
    }

    override var state: UIGestureRecognizer.State {
        get { reportedState }
        set { reportedState = newValue }
    }
}

private final class LongPressGestureRecognizerStub: UILongPressGestureRecognizer {
    private var reportedState: UIGestureRecognizer.State

    init(state: UIGestureRecognizer.State) {
        reportedState = state
        super.init(target: nil, action: nil)
    }

    override var state: UIGestureRecognizer.State {
        get { reportedState }
        set { reportedState = newValue }
    }
}

private final class TooltipWindowHost {
    private let window: UIWindow

    init(scene: UIWindowScene, contentView: UIView) {
        let viewController = UIViewController()
        window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        window.rootViewController = viewController
        viewController.view.addSubview(contentView)
        contentView.frame = window.bounds
        window.makeKeyAndVisible()
        viewController.view.layoutIfNeeded()
    }

    func hide() {
        window.isHidden = true
    }

    deinit {
        hide()
    }
}

private final class TooltipLegacyMenuOwnerSpy: TooltipLegacyMenuOwner {
    private(set) var replacementCount = 0

    func tooltipLegacyMenuWasReplaced() {
        replacementCount += 1
    }
}

private final class TooltipEditMenuPresentationSpy {
    struct Invocation {
        let interaction: NSObject
        let identifier: NSString
        let point: CGPoint
    }

    private(set) var invocations: [Invocation] = []

    init(view: ViewUIKit) {
        view.tooltipEditMenuPresentation = { [weak self] interaction, identifier, point in
            self?.invocations.append(.init(
                interaction: interaction,
                identifier: identifier,
                point: point
            ))
        }
    }
}

@available(iOS 16.0, *)
private final class TooltipEditMenuInteractionSpy: UIEditMenuInteraction {
    private(set) var presentedConfiguration: UIEditMenuConfiguration?

    init() {
        super.init(delegate: nil)
    }

    override func presentEditMenu(with configuration: UIEditMenuConfiguration) {
        presentedConfiguration = configuration
    }
}
