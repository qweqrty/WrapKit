#if canImport(SwiftUI)
@testable import WrapKit
import SwiftUI
import UIKit
import WrapKitTestUtils
import XCTest

final class SUILabelStateModelTests: XCTestCase {
    @available(iOS 16.0, *)
    @MainActor
    func test_attributedTrailingNewline_preservesEmptyLineHeightLikeUIKit() {
        let text = "CardView\nSubtitle\nMultiple\nRow"
        let constraint = CGSize(width: 390, height: 1_000)
        let cases: [(font: UIFont, lineSpacing: CGFloat, newline: String)] = [
            (.systemFont(ofSize: 14, weight: .light), 4, "\n"),
            (.systemFont(ofSize: 24), 0, "\r\n"),
            (.boldSystemFont(ofSize: 18), 8, "\u{2028}")
        ]

        for testCase in cases {
            var measuredHeights: [(uiKit: CGFloat, swiftUI: CGFloat)] = []
            for suffix in ["", testCase.newline, testCase.newline + testCase.newline] {
                let model = TextOutputPresentableModel.attributes([.init(
                    text: text + suffix,
                    font: testCase.font,
                    lineSpacing: testCase.lineSpacing
                )])
                let label = WrapKit.Label(font: testCase.font)
                label.display(model: model)
                let host = UIHostingController(rootView:
                    SUILabelView(model: model, font: testCase.font)
                        .fixedSize(horizontal: false, vertical: true)
                )
                host.loadViewIfNeeded()
                measuredHeights.append((
                    label.sizeThatFits(constraint).height,
                    host.sizeThatFits(in: constraint).height
                ))
            }

            for index in 1..<measuredHeights.count {
                let previous = measuredHeights[index - 1]
                let current = measuredHeights[index]
                XCTAssertGreaterThan(current.uiKit, previous.uiKit)
                XCTAssertEqual(
                    current.swiftUI - previous.swiftUI,
                    current.uiKit - previous.uiKit,
                    accuracy: 1,
                    "The empty line must retain font and spacing: \(testCase), line \(index)"
                )
            }
        }
    }

    @available(iOS 17.0, *)
    @MainActor
    func test_htmlOverflow_fillsContainerAndKeepsFullAttributedContent() throws {
        let size = CGSize(width: 390, height: 150)
        let config = HTMLAttributedStringConfig(lineSpacing: 8)
        let expectedText = try XCTUnwrap(
            HtmlTestCases.lists.asHtmlAttributedString(config: config)
        ).string
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUILabelView(
                model: .attributedString(HtmlTestCases.lists, config: config)
            )
            .frame(width: size.width, height: size.height),
            size: size
        )

        let label = try XCTUnwrap(host.firstSubview(of: WrapKit.Label.self))
        XCTAssertEqual(label.bounds.width, size.width, accuracy: 0.001)
        XCTAssertEqual(label.bounds.height, size.height, accuracy: 0.001)
        XCTAssertEqual(label.numberOfLines, 0)
        XCTAssertEqual(label.attributedText?.string, expectedText)
        XCTAssertGreaterThan(
            label.sizeThatFits(
                CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
            ).height,
            size.height
        )
    }

    @available(iOS 17.0, *)
    @MainActor
    func test_nonHTMLAttributes_keepNativeSwiftUIRenderer() {
        let host = SwiftUIAccessibilityTestHost(
            rootView: SUILabelView(
                model: .attributes([TextAttributes(text: "Native attributed text")])
            )
            .frame(width: 390, height: 150),
            size: CGSize(width: 390, height: 150)
        )

        XCTAssertNil(host.firstSubview(of: WrapKit.Label.self))
    }

    func test_fullModelWithoutText_keepsExistingContentVisibleLikeUIKit() {
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)

        adapter.display(text: "Existing")
        adapter.display(model: .init(
            accessibilityIdentifier: "updated-label",
            accessibility: .init(label: "Updated accessibility"),
            model: nil
        ))

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
        XCTAssertEqual(sut.presentable.accessibilityIdentifier, "updated-label")
        XCTAssertEqual(sut.presentable.accessibility?.label, "Updated accessibility")

        adapter.display(model: .init(
            accessibilityIdentifier: nil,
            accessibility: nil,
            model: nil
        ))

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
        XCTAssertNil(sut.presentable.accessibilityIdentifier)
        XCTAssertNil(sut.presentable.accessibility)
    }

    func test_premountGranularThenFullModelUsesFinalFullModelContent() {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(text: "Stale text")
        adapter.display(model: .text(
            accessibilityIdentifier: "final.label",
            accessibility: .init(label: "Final accessibility"),
            "Final text"
        ))

        let sut = SUILabelStateModel(adapter: adapter)

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Final text")
        XCTAssertEqual(sut.presentable.accessibilityIdentifier, "final.label")
        XCTAssertEqual(sut.presentable.accessibility?.label, "Final accessibility")
    }

    func test_premountFullModelThenGranularUsesFinalGranularContent() {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(model: .text(
            accessibilityIdentifier: "retained.label",
            accessibility: .init(label: "Retained accessibility"),
            "Stale text"
        ))
        adapter.display(text: "Final text")

        let sut = SUILabelStateModel(adapter: adapter)

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Final text")
        XCTAssertEqual(sut.presentable.accessibilityIdentifier, "retained.label")
        XCTAssertEqual(sut.presentable.accessibility?.label, "Retained accessibility")
    }

    func test_fullPlainModelAfterStyledFullModel_preservesStyleLikeUIKit() throws {
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)
        let insets = WrapKit.EdgeInsets(
            top: 1,
            leading: 2,
            bottom: 3,
            trailing: 4
        )

        adapter.display(model: .init(
            model: .textStyled(
                text: .text("Styled text"),
                cornerStyle: .fixed(12),
                insets: insets,
                height: 44,
                backgroundColor: .systemYellow
            )
        ))
        adapter.display(model: .text("Plain text"))

        guard case let .textStyled(
            text,
            cornerStyle,
            actualInsets,
            height,
            backgroundColor
        ) = sut.presentable.model else {
            return XCTFail("Expected the existing styled container to be preserved")
        }
        guard case .fixed(let radius) = try XCTUnwrap(cornerStyle) else {
            return XCTFail("Expected a fixed corner radius")
        }

        XCTAssertEqual(text.text, "Plain text")
        XCTAssertEqual(radius, 12)
        XCTAssertEqual(actualInsets, insets)
        XCTAssertEqual(height, 44)
        XCTAssertTrue(backgroundColor?.isEqual(UIColor.systemYellow) == true)
    }

    func test_premountDifferentContentOutputsHonorFinalWriteInEitherOrder() {
        let textLastAdapter = TextOutputSwiftUIAdapter()
        textLastAdapter.display(attributes: [.init(text: "Stale attributes")])
        textLastAdapter.display(text: "Final text")

        let htmlLastAdapter = TextOutputSwiftUIAdapter()
        htmlLastAdapter.display(text: "Stale text")
        htmlLastAdapter.display(htmlString: "<b>Final HTML</b>")

        let textLast = SUILabelStateModel(adapter: textLastAdapter)
        let htmlLast = SUILabelStateModel(adapter: htmlLastAdapter)

        XCTAssertEqual(textLast.presentable.model?.text, "Final text")
        XCTAssertEqual(htmlLast.presentable.model?.text, "<b>Final HTML</b>")
    }

    func test_fullModelWithoutContent_replacesAccessibilityAndPreservesContent() {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(text: "Existing")
        adapter.display(model: .init(
            accessibilityIdentifier: nil,
            accessibility: nil,
            model: nil
        ))

        let sut = SUILabelStateModel(adapter: adapter)

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
        XCTAssertNil(sut.presentable.accessibilityIdentifier)
        XCTAssertNil(sut.presentable.accessibility)
    }

    func test_nilTextModel_hidesWithoutDiscardingExistingContent() {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(text: "Existing")
        adapter.display(textModel: nil)

        let sut = SUILabelStateModel(adapter: adapter)

        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
    }

    @MainActor
    func test_premountAnimatedThenPlainText_matchesUIKitCompletionContract() {
        assertAnimatedReplacementParity { output in
            output.display(text: "Replacement")
        }
    }

    @MainActor
    func test_premountAnimatedThenNilModel_matchesUIKitCompletionContract() {
        assertAnimatedReplacementParity { output in
            output.display(model: nil)
        }
    }

    @MainActor
    func test_premountAnimatedThenHidden_matchesUIKitCompletionContract() {
        assertAnimatedReplacementParity { output in
            output.display(isHidden: true)
        }
    }

    @MainActor
    func test_liveAnimatedThenPlainText_matchesUIKitCompletionContract() {
        assertAnimatedReplacementParity(mountSwiftUIBeforeOutputs: true) { output in
            output.display(text: "Replacement")
        }
    }

    @MainActor
    func test_liveAnimatedThenNilModel_matchesUIKitCompletionContract() {
        assertAnimatedReplacementParity(mountSwiftUIBeforeOutputs: true) { output in
            output.display(model: nil)
        }
    }

    @MainActor
    func test_liveAnimatedThenHidden_matchesUIKitCompletionContract() {
        assertAnimatedReplacementParity(mountSwiftUIBeforeOutputs: true) { output in
            output.display(isHidden: true)
        }
    }

    @MainActor
    func test_styledAnimationThenStyledReplacement_preservesNewestStyleLikeUIKit() throws {
        let uikitCompletion = expectation(description: "UIKit animation completion")
        let swiftUICompletion = expectation(description: "SwiftUI animation completion")
        let uikitOutput = Label()
        let swiftUIOutput = TextOutputSwiftUIAdapter()
        let swiftUIState = SUILabelStateModel(adapter: swiftUIOutput)
        let latestInsets = WrapKit.EdgeInsets(
            top: 5,
            leading: 6,
            bottom: 7,
            trailing: 8
        )
        let animatedContent: ((() -> Void)?) -> TextOutputPresentableModel.TextModel = { completion in
            .textStyled(
                text: .animatedDecimal(
                    from: 0,
                    to: 1,
                    mapToString: { .text($0 == 1 ? "Final" : "Animating") },
                    animationStyle: .none,
                    duration: 0.05,
                    completion: completion
                ),
                cornerStyle: .fixed(4),
                insets: .zero,
                height: 20,
                backgroundColor: .systemRed
            )
        }
        let latestContent = TextOutputPresentableModel.TextModel.textStyled(
            text: .text("Replacement"),
            cornerStyle: .fixed(12),
            insets: latestInsets,
            height: 44,
            backgroundColor: .systemBlue
        )

        uikitOutput.display(model: .init(model: animatedContent {
            uikitCompletion.fulfill()
        }))
        swiftUIOutput.display(model: .init(model: animatedContent {
            swiftUICompletion.fulfill()
        }))
        uikitOutput.display(textModel: latestContent)
        swiftUIOutput.display(textModel: latestContent)

        wait(for: [uikitCompletion, swiftUICompletion], timeout: 0.5)

        guard case let .textStyled(
            text,
            cornerStyle,
            actualInsets,
            height,
            backgroundColor
        ) = swiftUIState.presentable.model else {
            return XCTFail("Expected the latest styled container to be preserved")
        }
        guard case .fixed(let radius) = try XCTUnwrap(cornerStyle) else {
            return XCTFail("Expected the latest fixed corner radius")
        }

        XCTAssertEqual(renderedText(in: text), uikitOutput.text)
        XCTAssertEqual(radius, 12)
        XCTAssertEqual(actualInsets, latestInsets)
        XCTAssertEqual(height, 44)
        XCTAssertTrue(backgroundColor?.isEqual(UIColor.systemBlue) == true)
        guard case .fixed(let uikitRadius) = try XCTUnwrap(uikitOutput.cornerStyle) else {
            return XCTFail("Expected UIKit to preserve its latest fixed corner radius")
        }
        XCTAssertEqual(uikitRadius, radius)
        XCTAssertEqual(uikitOutput.textInsets, latestInsets.asUIEdgeInsets)
        XCTAssertTrue(uikitOutput.backgroundColor?.isEqual(UIColor.systemBlue) == true)
    }

    @MainActor
    func test_newAnimationCancelsPreviousCompletionLikeUIKit() {
        let staleUIKitCompletion = expectation(description: "Stale UIKit completion")
        staleUIKitCompletion.isInverted = true
        let staleSwiftUICompletion = expectation(description: "Stale SwiftUI completion")
        staleSwiftUICompletion.isInverted = true
        let latestUIKitCompletion = expectation(description: "Latest UIKit completion")
        let latestSwiftUICompletion = expectation(description: "Latest SwiftUI completion")
        let uikitOutput = Label()
        let swiftUIOutput = TextOutputSwiftUIAdapter()
        let swiftUIState = SUILabelStateModel(adapter: swiftUIOutput)

        startAnimation(on: uikitOutput, id: "stale", to: 1, duration: 0.2) {
            staleUIKitCompletion.fulfill()
        }
        startAnimation(on: swiftUIOutput, id: "stale", to: 1, duration: 0.2) {
            staleSwiftUICompletion.fulfill()
        }
        startAnimation(on: uikitOutput, id: "latest", to: 2, duration: 0.01) {
            latestUIKitCompletion.fulfill()
        }
        startAnimation(on: swiftUIOutput, id: "latest", to: 2, duration: 0.01) {
            latestSwiftUICompletion.fulfill()
        }

        wait(
            for: [
                staleUIKitCompletion,
                staleSwiftUICompletion,
                latestUIKitCompletion,
                latestSwiftUICompletion
            ],
            timeout: 0.1
        )
        XCTAssertEqual(renderedText(in: swiftUIState.presentable.model), uikitOutput.text)
    }

    func test_premountLatestAnimationCompletes() {
        let completion = expectation(description: "Latest animation completes")
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(text: "Stale text")
        adapter.display(
            id: "latest",
            from: 0,
            to: 10,
            mapToString: { .text($0.asString()) },
            animationStyle: .none,
            duration: 0.01,
            completion: { completion.fulfill() }
        )

        let sut = SUILabelStateModel(adapter: adapter)

        wait(for: [completion], timeout: 0.2)
        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, Decimal(10).asString())
    }

    func test_newMountOwnsScheduledAnimationCompletion() {
        let completion = expectation(description: "Only the active mount completes")
        completion.expectedFulfillmentCount = 1
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(
            id: "lease",
            from: 0,
            to: 10,
            mapToString: { .text($0.asString()) },
            animationStyle: .none,
            duration: 0.02,
            completion: { completion.fulfill() }
        )

        let firstStateModel = SUILabelStateModel(adapter: adapter)
        let secondStateModel = SUILabelStateModel(adapter: adapter)

        wait(for: [completion], timeout: 0.2)
        XCTAssertNotNil(firstStateModel.presentable.model)
        XCTAssertEqual(secondStateModel.presentable.model?.text, Decimal(10).asString())
    }

    @MainActor
    func test_hideThenShowResumesAnimationFromCurrentTimeline() throws {
        let completion = expectation(description: "Resumed animation completes once")
        completion.expectedFulfillmentCount = 1
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)

        startAnimation(on: adapter, id: "visibility", to: 100, duration: 0.4) {
            completion.fulfill()
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
        adapter.display(isHidden: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.04))
        adapter.display(isHidden: false)

        let resumed = try decimalAnimation(in: sut.presentable.model)
        XCTAssertGreaterThan(resumed.from, 10)
        XCTAssertLessThan(resumed.from, 95)
        XCTAssertGreaterThan(resumed.duration, 0)
        XCTAssertLessThan(resumed.duration, 0.35)

        wait(for: [completion], timeout: 0.5)
        XCTAssertEqual(sut.presentable.model?.text, Decimal(100).asString())
    }

    @MainActor
    func test_stateModelRemountResumesAnimationFromCurrentTimeline() throws {
        let completion = expectation(description: "Remounted animation completes once")
        completion.expectedFulfillmentCount = 1
        let adapter = TextOutputSwiftUIAdapter()
        var firstStateModel: SUILabelStateModel? = SUILabelStateModel(adapter: adapter)

        startAnimation(on: adapter, id: "remount", to: 100, duration: 0.4) {
            completion.fulfill()
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.12))
        XCTAssertNotNil(firstStateModel)
        firstStateModel = nil

        let remountedStateModel = SUILabelStateModel(adapter: adapter)
        let resumed = try decimalAnimation(in: remountedStateModel.presentable.model)
        XCTAssertGreaterThan(resumed.from, 10)
        XCTAssertLessThan(resumed.from, 95)
        XCTAssertGreaterThan(resumed.duration, 0)
        XCTAssertLessThan(resumed.duration, 0.35)

        wait(for: [completion], timeout: 0.5)
        XCTAssertEqual(remountedStateModel.presentable.model?.text, Decimal(100).asString())
    }

    func test_nilFullModel_hidesWithoutDiscardingExistingContent() {
        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)

        adapter.display(text: "Existing")
        adapter.display(model: nil)

        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.presentable.model?.text, "Existing")
        XCTAssertNil(sut.presentable.accessibilityIdentifier)
        XCTAssertNil(sut.presentable.accessibility)
    }

    func test_nilFullModel_thenShow_preservesRetainedAttributeActionLikeUIKit() throws {
        final class ActionOwner {}

        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)
        var actionCalls = 0
        weak var weakOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            adapter.display(model: .attributes([
                .init(text: "Link", onTap: {
                    _ = owner
                    actionCalls += 1
                })
            ]))
        }

        adapter.display(model: nil)
        adapter.display(isHidden: false)

        XCTAssertFalse(sut.isHidden)
        XCTAssertNotNil(weakOwner)
        try invokeFirstAttributeAction(in: sut.presentable.model)
        XCTAssertEqual(actionCalls, 1)

        adapter.display(text: "Replacement")
        XCTAssertNil(weakOwner)
    }

    func test_fullModelWithoutContent_preservesRetainedAttributeActionLikeUIKit() throws {
        final class ActionOwner {}

        let adapter = TextOutputSwiftUIAdapter()
        let sut = SUILabelStateModel(adapter: adapter)
        var actionCalls = 0
        weak var weakOwner: ActionOwner?
        do {
            let owner = ActionOwner()
            weakOwner = owner
            adapter.display(model: .attributes([
                .init(text: "Link", onTap: {
                    _ = owner
                    actionCalls += 1
                })
            ]))
        }

        adapter.display(model: .init(
            accessibilityIdentifier: "updated-label",
            accessibility: .init(label: "Updated accessibility"),
            model: nil
        ))

        XCTAssertFalse(sut.isHidden)
        XCTAssertNotNil(weakOwner)
        XCTAssertEqual(sut.presentable.accessibilityIdentifier, "updated-label")
        try invokeFirstAttributeAction(in: sut.presentable.model)
        XCTAssertEqual(actionCalls, 1)

        adapter.display(textModel: nil)
        XCTAssertNil(weakOwner)
    }
}

private extension SUILabelStateModelTests {
    @MainActor
    func assertAnimatedReplacementParity(
        mountSwiftUIBeforeOutputs: Bool = false,
        replacement: (any TextOutput) -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let uikitCompletion = expectation(description: "UIKit animation completion")
        let swiftUICompletion = expectation(description: "SwiftUI animation completion")
        var uikitCompletionCount = 0
        var swiftUICompletionCount = 0

        let uikitOutput = Label()
        let swiftUIOutput = TextOutputSwiftUIAdapter()
        var swiftUIState: SUILabelStateModel? = mountSwiftUIBeforeOutputs
            ? SUILabelStateModel(adapter: swiftUIOutput)
            : nil
        let mapToString: (Decimal) -> TextOutputPresentableModel.TextModel = {
            .text($0 == 1 ? "Final" : "Animating")
        }

        uikitOutput.display(
            id: "animation",
            from: 0,
            to: 1,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.05,
            completion: {
                uikitCompletionCount += 1
                uikitCompletion.fulfill()
            }
        )
        swiftUIOutput.display(
            id: "animation",
            from: 0,
            to: 1,
            mapToString: mapToString,
            animationStyle: .none,
            duration: 0.05,
            completion: {
                swiftUICompletionCount += 1
                swiftUICompletion.fulfill()
            }
        )

        replacement(uikitOutput)
        replacement(swiftUIOutput)
        if swiftUIState == nil {
            swiftUIState = SUILabelStateModel(adapter: swiftUIOutput)
        }

        wait(for: [uikitCompletion, swiftUICompletion], timeout: 0.5)

        guard let resolvedSwiftUIState = swiftUIState else {
            return XCTFail("SwiftUI state model was not mounted", file: file, line: line)
        }
        XCTAssertEqual(uikitCompletionCount, 1, file: file, line: line)
        XCTAssertEqual(swiftUICompletionCount, uikitCompletionCount, file: file, line: line)
        XCTAssertEqual(resolvedSwiftUIState.isHidden, uikitOutput.isHidden, file: file, line: line)
        XCTAssertEqual(
            renderedText(in: resolvedSwiftUIState.presentable.model),
            uikitOutput.text,
            file: file,
            line: line
        )
    }

    func startAnimation(
        on output: any TextOutput,
        id: String,
        to endAmount: Decimal,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        output.display(
            id: id,
            from: 0,
            to: endAmount,
            mapToString: { .text("Final \($0)") },
            animationStyle: .none,
            duration: duration,
            completion: completion
        )
    }

    func renderedText(in model: TextOutputPresentableModel.TextModel?) -> String? {
        switch model {
        case .animatedDecimal(_, _, let to, let mapToString, _, _, _):
            return mapToString?(to).text ?? to.asString()
        case .animated(_, _, let to, let mapToString, _, _, _):
            return mapToString?(to).text ?? to.asDecimal().asString()
        case .textStyled(let text, _, _, _, _):
            return renderedText(in: text)
        default:
            return model?.text
        }
    }

    func invokeFirstAttributeAction(
        in model: TextOutputPresentableModel.TextModel?
    ) throws {
        guard case .attributes(let attributes) = model else {
            return XCTFail("Expected retained text attributes")
        }
        try XCTUnwrap(attributes.first?.onTap)()
    }

    func decimalAnimation(
        in model: TextOutputPresentableModel.TextModel?
    ) throws -> (from: Decimal, duration: TimeInterval) {
        switch model {
        case let .animatedDecimal(_, from, _, _, _, duration, _):
            return (from, duration)
        case .textStyled(let nested, _, _, _, _):
            return try decimalAnimation(in: nested)
        default:
            XCTFail("Expected a running decimal animation")
            throw DecimalAnimationError.notRunning
        }
    }
}

private enum DecimalAnimationError: Error {
    case notRunning
}
#endif
