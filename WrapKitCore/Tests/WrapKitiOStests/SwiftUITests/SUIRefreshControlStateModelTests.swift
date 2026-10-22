#if canImport(SwiftUI)
@testable import WrapKit
import Foundation
import SwiftUI
import XCTest
#if canImport(UIKit)
import UIKit
#endif

final class SUIRefreshControlStateModelTests: XCTestCase {
    func test_adapterPreservesLoadingOutputContract() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let loadingOutput: any LoadingOutput = adapter

        adapter.display(model: .init(isLoading: true))

        XCTAssertEqual(loadingOutput.isLoading, true)

        loadingOutput.isLoading = false

        XCTAssertEqual(adapter.isLoading, false)
    }

    func test_callbacks_followUIKitReplacementAndAppendingSemantics() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let sut = SUIRefreshControlStateModel(adapter: adapter)
        var calls: [String] = []
        let firstCallback = { calls.append("direct.first") }
        let secondCallback = { calls.append("direct.second") }

        XCTAssertEqual(adapter.onRefresh?.count, 0)

        adapter.onRefresh = [firstCallback, secondCallback]
        sut.triggerRefresh()

        adapter.display(onRefresh: { calls.append("display.primary") })
        adapter.display(appendingOnRefresh: { calls.append("display.appended") })
        sut.triggerRefresh()

        XCTAssertEqual(adapter.onRefresh?.count, 2)

        XCTAssertEqual(calls, [
            "direct.first",
            "direct.second",
            "display.primary",
            "display.appended"
        ])
    }

    func test_waitForLoadingToFinish_waitsForPresenterOutputAfterPull() async {
        let adapter = await MainActor.run { RefreshControlOutputSwiftUIAdapter() }
        let sut = await MainActor.run { SUIRefreshControlStateModel(adapter: adapter) }
        var refreshCount = 0
        await MainActor.run {
            adapter.display(onRefresh: { refreshCount += 1 })
            sut.triggerRefresh()
        }
        let finished = expectation(description: "Pull finished")
        finished.isInverted = true
        let waiter = Task {
            await sut.waitForLoadingToFinish()
            finished.fulfill()
        }

        await fulfillment(of: [finished], timeout: 0.3)

        let didFinish = expectation(description: "Pull finished after presenter output")
        let observer = Task {
            await waiter.value
            didFinish.fulfill()
        }
        await MainActor.run { adapter.display(isLoading: false) }
        await fulfillment(of: [didFinish], timeout: 1)
        observer.cancel()
        XCTAssertEqual(refreshCount, 1)
    }

    func test_waitForLoadingToFinish_returnsWhenPresenterFinishesSynchronously() async {
        let adapter = await MainActor.run { RefreshControlOutputSwiftUIAdapter() }
        let sut = await MainActor.run { SUIRefreshControlStateModel(adapter: adapter) }
        await MainActor.run {
            adapter.display(onRefresh: { [weak adapter] in adapter?.display(isLoading: false) })
            sut.triggerRefresh()
        }
        let finished = expectation(description: "Pull finished")
        Task {
            await sut.waitForLoadingToFinish()
            finished.fulfill()
        }

        await fulfillment(of: [finished], timeout: 0.5)
    }

    func test_modelSynchronizesPublicCallbackPropertyLikeUIKit() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        var refreshCount = 0

        adapter.display(model: .init(onRefresh: { refreshCount += 1 }))
        adapter.onRefresh?.forEach { $0?() }

        XCTAssertEqual(adapter.onRefresh?.count, 1)
        XCTAssertEqual(refreshCount, 1)

        adapter.display(model: nil)

        guard let callbacks = adapter.onRefresh else {
            return XCTFail("UIKit keeps the callback storage allocated")
        }
        XCTAssertEqual(callbacks.count, 1)
        XCTAssertNil(callbacks[0])
    }

    func test_mixedDirectAndDisplayAppendingPreservesAllCallbacksBeforeMountAfterMountAndRemount() {
        for mountsBeforeRegistration in [false, true] {
            let adapter = RefreshControlOutputSwiftUIAdapter()
            let refreshOutput: any RefreshControlOutput = adapter
            let output = refreshOutput.weakReferenced.mainQueueDispatched
            var calls: [String] = []
            let initialState = mountsBeforeRegistration ? SUIRefreshControlStateModel(adapter: adapter) : nil

            output.onRefresh?.append { calls.append("main") }
            output.display(appendingOnRefresh: { calls.append("update") })
            output.onRefresh?.append { calls.append("options") }

            let state = initialState ?? SUIRefreshControlStateModel(adapter: adapter)
            state.triggerRefresh()
            XCTAssertEqual(calls, ["main", "update", "options"])
            calls.removeAll()

            let remountedState = SUIRefreshControlStateModel(adapter: adapter)
            remountedState.triggerRefresh()
            XCTAssertEqual(calls, ["main", "update", "options"])
            calls.removeAll()

            adapter.onRefresh?.forEach { $0?() }
            XCTAssertEqual(calls, ["main", "update", "options"])
        }
    }

    func test_displayReplacementThenDirectAppendPreservesCallbacksAndRevokesOldEventCopy() throws {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let state = SUIRefreshControlStateModel(adapter: adapter)
        var calls: [String] = []
        adapter.display(onRefresh: { calls.append("first") })
        let oldEventCallback = try XCTUnwrap(adapter.displayOnRefreshState?.onRefresh)

        adapter.onRefresh?.append { calls.append("second") }
        oldEventCallback()
        XCTAssertTrue(calls.isEmpty)

        state.triggerRefresh()
        XCTAssertEqual(calls, ["first", "second"])
        calls.removeAll()

        let remountedState = SUIRefreshControlStateModel(adapter: adapter)
        remountedState.triggerRefresh()
        XCTAssertEqual(calls, ["first", "second"])
    }

    func test_nilCallbackStorageIgnoresDisplayWritesUntilDirectlyAllocatedLikeUIKit() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let state = SUIRefreshControlStateModel(adapter: adapter)
        var calls = 0
        adapter.onRefresh = nil

        adapter.display(onRefresh: { calls += 1 })
        XCTAssertNil(adapter.onRefresh)
        XCTAssertNil(adapter.displayOnRefreshState?.onRefresh)

        adapter.display(appendingOnRefresh: { calls += 1 })
        XCTAssertNil(adapter.onRefresh)
        XCTAssertNil(adapter.displayAppendingOnRefreshState?.appendingOnRefresh)

        adapter.display(model: .init(onRefresh: { calls += 1 }, isLoading: true))
        XCTAssertNil(adapter.onRefresh)
        XCTAssertNil(adapter.displayModelState?.model?.onRefresh)
        XCTAssertTrue(state.isLoading)
        state.triggerRefresh()
        XCTAssertTrue(state.onRefreshCallbacks.isEmpty)
        XCTAssertEqual(calls, 0)

        adapter.onRefresh = []
        adapter.display(appendingOnRefresh: { calls += 1 })
        state.triggerRefresh()
        XCTAssertEqual(calls, 1)

        adapter.display(onRefresh: nil)
        XCTAssertEqual(adapter.onRefresh?.count, 1)
        XCTAssertNil(adapter.onRefresh?.first ?? nil)
        adapter.display(appendingOnRefresh: nil)
        XCTAssertEqual(adapter.onRefresh?.count, 2)
        adapter.display(model: nil)
        XCTAssertEqual(adapter.onRefresh?.count, 1)
        XCTAssertNil(adapter.onRefresh?.first ?? nil)
    }

    func test_directReplacementWithLargerArrayRevokesOldUICallbacksAndReleasesOwner() throws {
        final class CallbackOwner {}
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let state = SUIRefreshControlStateModel(adapter: adapter)
        var calls: [String] = []
        weak var weakOwner: CallbackOwner?
        do {
            let owner = CallbackOwner()
            weakOwner = owner
            adapter.display(model: .init(onRefresh: {
                _ = owner
                calls.append("old")
            }))
        }
        let oldUICallback = try XCTUnwrap(state.onRefreshCallbacks.first ?? nil)
        let oldEventCallback = try XCTUnwrap(adapter.displayModelState?.model?.onRefresh)
        XCTAssertNotNil(weakOwner)

        let first = { calls.append("first") }
        let second = { calls.append("second") }
        adapter.onRefresh = [first, second]

        XCTAssertNil(weakOwner)
        oldUICallback()
        oldEventCallback()
        XCTAssertTrue(calls.isEmpty)
        state.triggerRefresh()
        XCTAssertEqual(calls, ["first", "second"])
    }

    func test_directRemovalReorderingAndDuplicatesKeepRawArraySemanticsAndRevokeOldUICopies() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let state = SUIRefreshControlStateModel(adapter: adapter)
        var calls: [String] = []
        let first = { calls.append("first") }
        let second = { calls.append("second") }
        adapter.display(onRefresh: first)
        adapter.display(appendingOnRefresh: second)
        let oldUICallbacks = state.onRefreshCallbacks

        adapter.onRefresh?.reverse()
        oldUICallbacks.forEach { $0?() }
        XCTAssertTrue(calls.isEmpty)
        state.triggerRefresh()
        XCTAssertEqual(calls, ["second", "first"])
        calls.removeAll()

        adapter.onRefresh?.removeFirst()
        state.triggerRefresh()
        XCTAssertEqual(calls, ["first"])
        calls.removeAll()

        adapter.onRefresh?.append(first)
        state.triggerRefresh()
        XCTAssertEqual(calls, ["first", "first"])
        calls.removeAll()

        adapter.onRefresh = []
        state.triggerRefresh()
        XCTAssertTrue(state.onRefreshCallbacks.isEmpty)
        XCTAssertTrue(calls.isEmpty)
    }

    func test_remountPreventsOldConsumerFromReadingOrInvokingCurrentCallbacks() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let oldState = SUIRefreshControlStateModel(adapter: adapter)
        var calls: [String] = []
        let latest = { calls.append("latest") }
        adapter.display(onRefresh: latest)
        let state = SUIRefreshControlStateModel(adapter: adapter)

        XCTAssertTrue(oldState.onRefreshCallbacks.isEmpty)
        oldState.triggerRefresh()
        XCTAssertTrue(calls.isEmpty)
        state.triggerRefresh()
        XCTAssertEqual(calls, ["latest"])
    }

    func test_triggerFinishesCurrentRawSnapshotWhenFirstHandlerClearsCallbacksLikeUIKit() {
        final class CallbackOwner {}
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let state = SUIRefreshControlStateModel(adapter: adapter)
        var calls: [String] = []
        weak var weakOwner: CallbackOwner?
        let first = { [weak adapter] in
            calls.append("first")
            adapter?.onRefresh = []
            XCTAssertNotNil(weakOwner, "The current UIKit-style batch retains its remaining handlers")
        }
        adapter.onRefresh = [first]
        do {
            let owner = CallbackOwner()
            weakOwner = owner
            adapter.display(appendingOnRefresh: {
                _ = owner
                calls.append("second")
            })
        }
        let oldUICallbacks = state.onRefreshCallbacks

        state.triggerRefresh()

        XCTAssertEqual(calls, ["first", "second"])
        XCTAssertNil(weakOwner)
        XCTAssertTrue(state.onRefreshCallbacks.isEmpty)
        oldUICallbacks.forEach { $0?() }
        state.triggerRefresh()
        XCTAssertEqual(calls, ["first", "second"])
    }

    func test_publicRawCallbackCopyKeepsUIKitSemanticsWithoutKeepingOldUILeaseActive() throws {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let state = SUIRefreshControlStateModel(adapter: adapter)
        var calls = 0
        adapter.display(onRefresh: { calls += 1 })
        let rawCallback = try XCTUnwrap(adapter.onRefresh?.first ?? nil)
        let oldUICallback = try XCTUnwrap(state.onRefreshCallbacks.first ?? nil)

        adapter.onRefresh = nil
        oldUICallback()
        XCTAssertEqual(calls, 0)
        rawCallback()
        XCTAssertEqual(calls, 1)
    }

    func test_remountUsesCurrentNilDirectCallbacksAndReleasesCallbackOwner() throws {
        final class CallbackOwner {}

        let adapter = RefreshControlOutputSwiftUIAdapter()
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
        adapter.display(model: .init(onRefresh: callback))
        callback = nil
        var mountedStateModel: SUIRefreshControlStateModel? = .init(adapter: adapter)
        let retainedCallback = try XCTUnwrap(mountedStateModel?.onRefreshCallbacks.first ?? nil)

        XCTAssertNotNil(weakOwner)
        mountedStateModel?.triggerRefresh()
        XCTAssertEqual(calls, 1)

        mountedStateModel = nil
        adapter.onRefresh = nil
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))

        XCTAssertNil(weakOwner)
        retainedCallback()
        XCTAssertEqual(calls, 1)

        let remountedStateModel = SUIRefreshControlStateModel(adapter: adapter)
        remountedStateModel.triggerRefresh()

        XCTAssertTrue(remountedStateModel.onRefreshCallbacks.isEmpty)
    }

    func test_nilModelClearsCallbacksButRetainsStyleAndLoadingLikeUIKit() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let sut = SUIRefreshControlStateModel(adapter: adapter)
        var refreshCount = 0
        adapter.display(model: .init(
            style: .init(tintColor: .systemPurple),
            onRefresh: { refreshCount += 1 },
            isLoading: true
        ))

        adapter.display(model: nil)
        sut.triggerRefresh()

        XCTAssertEqual(refreshCount, 0)
        XCTAssertTrue(sut.tintColor?.isEqual(UIColor.systemPurple) == true)
        XCTAssertTrue(sut.isLoading)
    }

    func test_styleOutput_updatesTintWithoutChangingLoadingState() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let sut = SUIRefreshControlStateModel(adapter: adapter)

        adapter.display(isLoading: true)
        adapter.display(style: .init(tintColor: .systemBlue))

        XCTAssertTrue(sut.tintColor?.isEqual(UIColor.systemBlue) == true)
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.zPosition, 0)

        adapter.display(style: .init(tintColor: .systemPurple, zPosition: 7))

        XCTAssertTrue(sut.tintColor?.isEqual(UIColor.systemPurple) == true)
        XCTAssertTrue(sut.isLoading)
        XCTAssertEqual(sut.zPosition, 7)

        adapter.display(style: .init(tintColor: nil))

        XCTAssertNil(sut.tintColor)
        XCTAssertTrue(sut.isLoading)
    }

    func test_preMountModelStyleWinsWhenItIsTheLastApplicableWrite() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        adapter.display(style: .init(tintColor: .systemPurple, zPosition: 7))
        adapter.display(model: .init(
            style: .init(tintColor: .systemBlue, zPosition: 3)
        ))

        let sut = SUIRefreshControlStateModel(adapter: adapter)

        XCTAssertTrue(sut.tintColor?.isEqual(UIColor.systemBlue) == true)
        XCTAssertEqual(sut.zPosition, 3)
    }

    func test_preMountDirectStyleWinsWhenItIsTheLastApplicableWrite() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        adapter.display(model: .init(
            style: .init(tintColor: .systemBlue, zPosition: 3)
        ))
        adapter.display(style: .init(tintColor: .systemPurple, zPosition: 7))

        let sut = SUIRefreshControlStateModel(adapter: adapter)

        XCTAssertTrue(sut.tintColor?.isEqual(UIColor.systemPurple) == true)
        XCTAssertEqual(sut.zPosition, 7)
    }

    @MainActor
    func test_triggeredRefreshWaitsUntilOutputStopsLoadingLikeUIKitPull() async {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let sut = SUIRefreshControlStateModel(adapter: adapter)
        var calls = 0
        adapter.display(isLoading: false)
        adapter.display(onRefresh: { calls += 1 })
        var isFinished = false

        sut.triggerRefresh()
        let task = Task {
            await sut.waitForLoadingToFinish()
            isFinished = true
        }
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(calls, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(isFinished)

        adapter.display(isLoading: false)
        await task.value

        XCTAssertTrue(isFinished)
    }

    @MainActor
    func test_triggeredRefreshFinishesWhenOutputStopsLoadingSynchronously() async {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let sut = SUIRefreshControlStateModel(adapter: adapter)
        adapter.display(onRefresh: { adapter.display(isLoading: false) })

        sut.triggerRefresh()
        await sut.waitForLoadingToFinish()

        XCTAssertFalse(sut.isLoading)
    }

    @MainActor
    func test_loadingWaitReturnsWhenTaskIsCancelled() async {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let sut = SUIRefreshControlStateModel(adapter: adapter)
        adapter.display(isLoading: true)

        let task = Task {
            await sut.waitForLoadingToFinish()
        }
        task.cancel()
        await task.value

        XCTAssertTrue(sut.isLoading)
    }

#if canImport(UIKit)
    func test_outputLoadingStateStartsAndStopsHostedRefreshControl() throws {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let view = ScrollView {
            LazyVStack {
                ForEach(0..<30, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
        }
        .refreshControl(adapter: adapter)
        let host = RefreshControlTestHost(rootView: view)
        let refreshControl = try XCTUnwrap(host.renderedRefreshControls().first)

        adapter.display(isLoading: true)
        host.flushUpdates()

        XCTAssertTrue(refreshControl.isRefreshing)

        adapter.display(isLoading: false)
        host.flushUpdates()

        XCTAssertFalse(refreshControl.isRefreshing)
    }

    func test_modifierAppliesTintReceivedAfterHostedScrollViewCreation() {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let view = VStack {
            Text("Header")
            ScrollView {
                LazyVStack {
                    ForEach(0..<30, id: \.self) { index in
                        Text("Row \(index)")
                    }
                }
            }
        }
        .refreshControl(adapter: adapter)
        let host = RefreshControlTestHost(rootView: view)

        adapter.display(style: .init(tintColor: .systemPurple, zPosition: 7))
        host.flushUpdates()
        let renderedRefreshControls = host.renderedRefreshControls()

        XCTAssertTrue(renderedRefreshControls.contains {
            $0.tintColor.matches(UIColor.systemPurple) && $0.layer.zPosition == 7
        })
    }

    func test_modifierRendersPurpleIndicatorWhileHostedRefreshControlIsRefreshing() throws {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let view = ScrollView {
            LazyVStack {
                ForEach(0..<30, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
        }
        .refreshControl(adapter: adapter)
        let host = RefreshControlTestHost(rootView: view)

        adapter.display(style: .init(tintColor: .systemPurple))
        adapter.display(isLoading: true)
        host.flushUpdates()
        let refreshControl = try XCTUnwrap(host.renderedRefreshControls().first)

        try host.revealRefreshingIndicator(refreshControl)
        let image = host.renderedImage()
        let attachment = XCTAttachment(image: image)
        attachment.name = "Hosted systemPurple refresh indicator"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertGreaterThan(image.rgbaPixels.purplePixelCount, 0)
        adapter.display(isLoading: false)
    }

    func test_pullFromIdleKeepsHostedRefreshControlRefreshingUntilPresenterFinishes() throws {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        var refreshCount = 0
        adapter.display(onRefresh: { refreshCount += 1 })
        let view = ScrollView {
            LazyVStack {
                ForEach(0..<30, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
        }
        .refreshControl(adapter: adapter)
        let host = RefreshControlTestHost(rootView: view)
        adapter.display(style: .init(tintColor: .systemPurple))
        host.flushUpdates()
        let refreshControl = try XCTUnwrap(host.renderedRefreshControls().first)

        try host.revealRefreshingIndicator(refreshControl)
        host.flushUpdates()

        XCTAssertEqual(refreshCount, 1)
        XCTAssertTrue(refreshControl.isRefreshing, "The pulled indicator stays until the presenter outputs isLoading(false)")
        XCTAssertGreaterThan(host.renderedImage().rgbaPixels.purplePixelCount, 0)

        adapter.display(isLoading: false)
        host.flushUpdates()

        XCTAssertFalse(refreshControl.isRefreshing)
    }

    func test_modifierRestoresDefaultIndicatorAppearanceWhenTintBecomesNil() throws {
        let adapter = RefreshControlOutputSwiftUIAdapter()
        let view = ScrollView {
            LazyVStack {
                ForEach(0..<30, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
        }
        .refreshControl(adapter: adapter)
        let host = RefreshControlTestHost(rootView: view)

        adapter.display(style: .init(tintColor: .systemPurple))
        adapter.display(isLoading: true)
        host.flushUpdates()
        let refreshControl = try XCTUnwrap(host.renderedRefreshControls().first)
        try host.revealRefreshingIndicator(refreshControl)
        XCTAssertGreaterThan(host.renderedImage().rgbaPixels.purplePixelCount, 0)

        adapter.display(style: .init(tintColor: nil))
        host.flushUpdates()
        let defaultImage = host.renderedImage()
        let attachment = XCTAttachment(image: defaultImage)
        attachment.name = "Hosted refresh indicator after tint becomes nil"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertEqual(defaultImage.rgbaPixels.purplePixelCount, 0)
        XCTAssertGreaterThan(defaultImage.rgbaPixels.neutralIndicatorPixelCount, 0)
        adapter.display(isLoading: false)
    }
#endif
}

#if canImport(UIKit)
private final class RefreshControlTestHost {
    private let window: UIWindow
    private let hostingController: UIHostingController<AnyView>

    init<Content: View>(rootView: Content) {
        hostingController = UIHostingController(rootView: AnyView(rootView))
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        hostingController.view.frame = window.bounds
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
    }

    func flushUpdates() {
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
    }

    func renderedRefreshControls() -> [UIRefreshControl] {
        hostingController.view.allSubviews.compactMap { view in
            let typeName = String(describing: type(of: view))
            guard view is UIRefreshControl ||
                    typeName.localizedCaseInsensitiveContains("refreshcontrol") else {
                return nil
            }
            return view as? UIRefreshControl
        }
    }

    func revealRefreshingIndicator(_ refreshControl: UIRefreshControl) throws {
        let scrollView = try XCTUnwrap(refreshControl.superview as? UIScrollView)
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
        scrollView.setContentOffset(
            CGPoint(
                x: scrollView.contentOffset.x,
                y: -scrollView.adjustedContentInset.top - max(refreshControl.bounds.height, 60)
            ),
            animated: false
        )
        flushUpdates()
    }

    func renderedImage() -> UIImage {
        flushUpdates()
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1
        return UIGraphicsImageRenderer(bounds: hostingController.view.bounds, format: format).image { _ in
            hostingController.view.drawHierarchy(
                in: hostingController.view.bounds,
                afterScreenUpdates: true
            )
        }
    }
}

private extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap(\.allSubviews)
    }
}

private extension UIColor {
    func matches(_ other: UIColor, accuracy: CGFloat = 0.001) -> Bool {
        let traits = UITraitCollection(userInterfaceStyle: .light)
        var lhs = (red: CGFloat.zero, green: CGFloat.zero, blue: CGFloat.zero, alpha: CGFloat.zero)
        var rhs = (red: CGFloat.zero, green: CGFloat.zero, blue: CGFloat.zero, alpha: CGFloat.zero)
        guard resolvedColor(with: traits).getRed(
            &lhs.red,
            green: &lhs.green,
            blue: &lhs.blue,
            alpha: &lhs.alpha
        ), other.resolvedColor(with: traits).getRed(
            &rhs.red,
            green: &rhs.green,
            blue: &rhs.blue,
            alpha: &rhs.alpha
        ) else { return false }
        return abs(lhs.red - rhs.red) <= accuracy &&
            abs(lhs.green - rhs.green) <= accuracy &&
            abs(lhs.blue - rhs.blue) <= accuracy &&
            abs(lhs.alpha - rhs.alpha) <= accuracy
    }
}

private extension Array where Element == UInt8 {
    var purplePixelCount: Int {
        stride(from: 0, to: count, by: 4).reduce(into: 0) { result, index in
            let red = Int(self[index])
            let green = Int(self[index + 1])
            let blue = Int(self[index + 2])
            let alpha = self[index + 3]
            if alpha > 32, red > green + 15, blue > red + 5 {
                result += 1
            }
        }
    }

    var neutralIndicatorPixelCount: Int {
        let pixelWidth = 390
        return stride(from: 0, to: count, by: 4).reduce(into: 0) { result, index in
            let pixelIndex = index / 4
            let x = pixelIndex % pixelWidth
            let y = pixelIndex / pixelWidth
            guard (170..<220).contains(x), (60..<120).contains(y) else { return }

            let red = Int(self[index])
            let green = Int(self[index + 1])
            let blue = Int(self[index + 2])
            let alpha = self[index + 3]
            let maximum = Swift.max(red, Swift.max(green, blue))
            let minimum = Swift.min(red, Swift.min(green, blue))
            if alpha > 32, maximum - minimum < 12, maximum < 230 {
                result += 1
            }
        }
    }
}

private extension UIImage {
    var rgbaPixels: [UInt8] {
        guard let cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return []
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }
}
#endif
#endif
