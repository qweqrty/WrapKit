import WrapKit
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
        simulateTapTrigger(on: sut)
        flushMainQueue()

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
        simulateLongPressTrigger(on: sut)
        flushMainQueue()

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
        flushMainQueue()
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
        simulateTapTrigger(on: sut)
        flushMainQueue()

        assertSnapshots(container: snapshotView, snapshotName: snapshotName)
    }
}

private extension TooltipViewSnapshotTests {
    func assertSnapshots(container: UIView, snapshotName: String) {
        if #available(iOS 26, *) {
            record(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS26_\(snapshotName)_LIGHT")
            record(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS26_\(snapshotName)_DARK")
        } else {
            record(snapshot: container.snapshot(for: .iPhone(style: .light)), named: "iOS18.5_\(snapshotName)_LIGHT")
            record(snapshot: container.snapshot(for: .iPhone(style: .dark)), named: "iOS18.5_\(snapshotName)_DARK")
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

    func simulateTapTrigger(on view: ViewUIKit) {
        let gesture = UITapGestureRecognizer()
        _ = view.perform(NSSelectorFromString("handleTooltipTap:"), with: gesture)
    }

    func simulateLongPressTrigger(on view: ViewUIKit) {
        let gesture = UILongPressGestureRecognizer()
        _ = view.perform(NSSelectorFromString("handleTooltipLongPress:"), with: gesture)
    }

    func flushMainQueue() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }
}
