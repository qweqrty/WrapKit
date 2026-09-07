#if canImport(SwiftUI) && canImport(UIKit)
@testable import WrapKit
import XCTest

@MainActor
final class SUIEmptyViewStateModelTests: XCTestCase {
    func test_nilThenContentlessTitlePreservesActionAcrossRemountLikeUIKit() throws {
        final class ActionOwner {}

        let uiKitView = EmptyView()
        weak var uiKitOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            uiKitOwner = owner
            uiKitView.display(title: .attributes([
                .init(text: "Retained title", onTap: { _ = owner })
            ]))
        }
        uiKitView.display(title: nil)
        XCTAssertNotNil(uiKitOwner)
        uiKitView.display(title: .init(model: nil))
        XCTAssertFalse(uiKitView.titleLabel.isHidden)
        XCTAssertNotNil(uiKitOwner)
        uiKitView.display(title: .attributes([.init(text: "Replacement")]))
        XCTAssertNil(uiKitOwner)

        let adapter = EmptyViewOutputSwiftUIAdapter()
        var calls = 0
        weak var weakOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            adapter.display(title: .attributes([
                .init(text: "Retained title", onTap: {
                    _ = owner
                    calls += 1
                })
            ]))
        }

        adapter.display(title: nil)
        XCTAssertNotNil(weakOwner)
        adapter.display(title: .init(model: nil))

        var sut: SUIEmptyViewStateModel? = .init(adapter: adapter)
        sut = nil
        let remountedSUT = SUIEmptyViewStateModel(adapter: adapter)

        let action = try XCTUnwrap(firstTapAction(
            in: remountedSUT.titleStateModel.presentable.model
        ))
        action()
        XCTAssertEqual(calls, 1)

        adapter.display(title: .attributes([.init(text: "Replacement")]))
        XCTAssertNil(weakOwner)
    }

    func test_titleAnimationCompletionSurvivesPlainReplacementAndStateModelRemount() {
        let completion = expectation(description: "Title animation completes")
        let adapter = EmptyViewOutputSwiftUIAdapter()
        var sut: SUIEmptyViewStateModel? = .init(adapter: adapter)

        adapter.display(title: .init(model: .animatedDecimal(
            from: 0,
            to: 1,
            mapToString: { .text($0.asString()) },
            animationStyle: .none,
            duration: 0.05,
            completion: { completion.fulfill() }
        )))
        adapter.display(title: .text("Replacement"))

        sut = nil
        let remountedSUT = SUIEmptyViewStateModel(adapter: adapter)

        wait(for: [completion], timeout: 0.5)
        XCTAssertEqual(remountedSUT.title?.plainText, "Replacement")
        XCTAssertEqual(remountedSUT.titleStateModel.presentable.model?.text, "1")
    }

    func test_premountModelAndIncrementalOutputsHonorFinalWriteInEitherOrder() {
        let modelLastAdapter = EmptyViewOutputSwiftUIAdapter()
        modelLastAdapter.display(title: .text("Old incremental title"))
        modelLastAdapter.display(isHidden: true)
        modelLastAdapter.display(model: .init(title: .text("Latest model title")))

        let incrementalLastAdapter = EmptyViewOutputSwiftUIAdapter()
        incrementalLastAdapter.display(model: .init(title: .text("Old model title")))
        incrementalLastAdapter.display(title: .text("Latest incremental title"))
        incrementalLastAdapter.display(isHidden: true)

        let modelLast = SUIEmptyViewStateModel(adapter: modelLastAdapter)
        let incrementalLast = SUIEmptyViewStateModel(adapter: incrementalLastAdapter)

        XCTAssertEqual(modelLast.title?.plainText, "Latest model title")
        XCTAssertFalse(modelLast.isHidden)
        XCTAssertEqual(incrementalLast.title?.plainText, "Latest incremental title")
        XCTAssertTrue(incrementalLast.isHidden)
    }

    func test_buttonOutput_preservesFullPresentableModel() {
        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)
        let image = ImageFactory.systemImage(named: "star.fill")

        adapter.display(buttonModel: .init(
            accessibilityIdentifier: "empty.action",
            accessibility: .init(label: "Try again", hint: "Retries the request"),
            title: "Retry",
            image: image,
            spacing: 7,
            height: 44,
            width: 180,
            style: .init(backgroundColor: .systemBlue),
            enabled: false,
            onPress: {}
        ))

        XCTAssertEqual(sut.buttonModel?.accessibilityIdentifier, "empty.action")
        XCTAssertEqual(sut.buttonModel?.accessibility?.label, "Try again")
        XCTAssertEqual(sut.buttonModel?.accessibility?.hint, "Retries the request")
        XCTAssertEqual(sut.buttonModel?.title, "Retry")
        XCTAssertNotNil(sut.buttonModel?.image)
        XCTAssertEqual(sut.buttonModel?.spacing, 7)
        XCTAssertEqual(sut.buttonModel?.height, 44)
        XCTAssertEqual(sut.buttonModel?.width, 180)
        XCTAssertNotNil(sut.buttonModel?.style)
        XCTAssertEqual(sut.buttonModel?.enabled, false)
        XCTAssertNotNil(sut.buttonModel?.onPress)
    }

    func test_nilButtonOutput_clearsVisibleModel() {
        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)
        adapter.display(buttonModel: .init(title: "Retry"))

        adapter.display(buttonModel: nil)

        XCTAssertNil(sut.buttonModel)
        XCTAssertTrue(sut.isButtonHidden)
    }

    func test_nilButtonOutput_releasesSupersededActionOwner() throws {
        final class ActionOwner {}

        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)
        var calls = 0
        weak var weakOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            adapter.display(buttonModel: .init(onPress: {
                _ = owner
                calls += 1
            }))
        }
        let retainedAction = try XCTUnwrap(sut.buttonModel?.onPress)

        XCTAssertNotNil(weakOwner)
        retainedAction()
        XCTAssertEqual(calls, 1)

        adapter.display(buttonModel: nil)

        XCTAssertNil(weakOwner)
        XCTAssertNil(sut.buttonModel)
        retainedAction()
        XCTAssertEqual(calls, 1)
    }

    func test_incrementalButtonModel_preservesUIKitLayoutAndEnabledState() {
        let adapter = EmptyViewOutputSwiftUIAdapter()
        let sut = SUIEmptyViewStateModel(adapter: adapter)

        adapter.display(buttonModel: .init(
            title: "Initial",
            height: 44,
            width: 180,
            style: .init(backgroundColor: .systemBlue),
            enabled: false
        ))
        adapter.display(buttonModel: .init(title: "Updated"))

        XCTAssertEqual(sut.buttonModel?.title, "Updated")
        XCTAssertEqual(sut.buttonModel?.height, 44)
        XCTAssertEqual(sut.buttonModel?.width, 180)
        XCTAssertNotNil(sut.buttonModel?.style)
        XCTAssertEqual(sut.buttonModel?.enabled, false)
    }

    @available(iOS 17.0, *)
    func test_imageClosureOnlyReplacementUpdatesMountedViewAndSurvivesRemount() throws {
        final class ActionOwner {}

        let adapter = EmptyViewOutputSwiftUIAdapter()
        var calls: [String] = []
        weak var oldOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            oldOwner = owner
            adapter.display(image: .systemSymbol(
                "star.fill",
                accessibilityIdentifier: "empty.image",
                accessibility: .init(label: "Empty image"),
                size: .init(width: 32, height: 32),
                onPress: {
                    _ = owner
                    calls.append("old")
                }
            ))
        }

        var host: SwiftUIAccessibilityTestHost? = .init(
            rootView: SUIEmptyView(adapter: adapter),
            size: CGSize(width: 200, height: 120)
        )
        host?.settle()
        let initialElement = try XCTUnwrap(host?.element(withLabel: "Empty image"))
        XCTAssertTrue(initialElement.accessibilityActivate())
        XCTAssertEqual(calls, ["old"])

        weak var latestOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            latestOwner = owner
            adapter.display(image: .systemSymbol(
                "star.fill",
                accessibilityIdentifier: "empty.image",
                accessibility: .init(label: "Empty image"),
                size: .init(width: 32, height: 32),
                onPress: {
                    _ = owner
                    calls.append("latest")
                }
            ))
        }
        host?.settle()

        XCTAssertNil(oldOwner)
        let updatedElement = try XCTUnwrap(host?.element(withLabel: "Empty image"))
        XCTAssertTrue(updatedElement.accessibilityActivate())
        XCTAssertEqual(calls, ["old", "latest"])

        weak var firstHost = host
        host = nil
        XCTAssertNil(firstHost)
        let remountedHost = SwiftUIAccessibilityTestHost(
            rootView: SUIEmptyView(adapter: adapter),
            size: CGSize(width: 200, height: 120)
        )
        let remountedElement = try XCTUnwrap(
            remountedHost.element(withLabel: "Empty image")
        )
        XCTAssertTrue(remountedElement.accessibilityActivate())
        XCTAssertEqual(calls, ["old", "latest", "latest"])

        adapter.display(image: nil)
        remountedHost.settle()

        XCTAssertNil(latestOwner)
        XCTAssertNil(remountedHost.element(withLabel: "Empty image"))
        XCTAssertTrue(updatedElement.accessibilityActivate())
        XCTAssertEqual(calls, ["old", "latest", "latest"])
    }

    func test_uiKitEmptyView_usesCenteredDefaultLabelsAndFullButtonSemantics() {
        let sut = EmptyView()
        let image = ImageFactory.systemImage(named: "star.fill")

        sut.display(buttonModel: .init(
            accessibilityIdentifier: "empty.action",
            accessibility: .init(label: "Try again", hint: "Retries the request"),
            title: "Retry",
            image: image,
            height: 44,
            enabled: false,
            onPress: {}
        ))

        XCTAssertEqual(sut.titleLabel.textAlignment, .center)
        XCTAssertEqual(sut.subTitleLabel.textAlignment, .center)
        XCTAssertFalse(sut.button.isEnabled)
        XCTAssertNotNil(sut.button.image(for: .normal))
        XCTAssertEqual(sut.button.accessibilityIdentifier, "empty.action")
        XCTAssertEqual(sut.button.accessibilityLabel, "Try again")
        XCTAssertEqual(sut.button.accessibilityHint, "Retries the request")
        XCTAssertEqual(
            sut.button.constraints.first(where: { $0.firstAttribute == .height })?.constant,
            44
        )
    }
}

private func firstTapAction(
    in model: TextOutputPresentableModel.TextModel?,
    file: StaticString = #filePath,
    line: UInt = #line
) -> (() -> Void)? {
    guard case let .attributes(attributes)? = model else {
        XCTFail("Expected text attributes", file: file, line: line)
        return nil
    }
    return attributes.first?.onTap
}

private extension TextOutputPresentableModel {
    var plainText: String? {
        guard case let .text(value) = model else { return nil }
        return value
    }
}
#endif
