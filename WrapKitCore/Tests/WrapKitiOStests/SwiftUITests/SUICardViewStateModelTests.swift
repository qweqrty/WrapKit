#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
@testable import WrapKit
import Combine
import XCTest

final class SUICardViewStateModelTests: XCTestCase {
    func test_granularThenFullModelBeforeMount_replaysLaterModelForEverySemanticField() {
        let adapter = CardViewOutputSwiftUIAdapter()
        var actions: [String] = []
        let granularStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])
        let modelStyle = makeStyle(backgroundColor: .systemBlue, gradientColors: [.systemBlue])

        displayGranularContent(
            on: adapter,
            prefix: "granular",
            style: granularStyle,
            isHidden: true,
            isUserInteractionEnabled: false,
            onPress: { actions.append("granular.press") },
            onLongPress: { actions.append("granular.longPress") }
        )
        adapter.display(isGradientBorderEnabled: true)
        adapter.display(model: makeModel(
            prefix: "model",
            style: modelStyle,
            isUserInteractionEnabled: true,
            isGradientBorderEnabled: true,
            onPress: { actions.append("model.press") },
            onLongPress: { actions.append("model.longPress") }
        ))

        let sut = SUICardViewStateModel(adapter: adapter)

        assertContent(of: sut, prefix: "model")
        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.style, modelStyle)
        XCTAssertTrue(sut.isUserInteractionEnabled)
        assertGradient(sut, equals: [.systemBlue])
        XCTAssertEqual(sut.accessibilityIdentifier, "model.card")
        XCTAssertEqual(sut.accessibilityLabel, "model.label")
        XCTAssertEqual(sut.accessibilityHint, "model.hint")
        sut.onPress?()
        sut.onLongPress?()
        XCTAssertEqual(actions, ["model.press", "model.longPress"])
    }

    func test_fullModelThenGranularBeforeMount_replaysLaterGranularForEverySemanticField() {
        let adapter = CardViewOutputSwiftUIAdapter()
        var actions: [String] = []
        let modelStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])
        let granularStyle = makeStyle(backgroundColor: .systemBlue, gradientColors: [.systemBlue])

        adapter.display(model: makeModel(
            prefix: "model",
            style: modelStyle,
            isUserInteractionEnabled: true,
            isGradientBorderEnabled: true,
            onPress: { actions.append("model.press") },
            onLongPress: { actions.append("model.longPress") }
        ))
        displayGranularContent(
            on: adapter,
            prefix: "granular",
            style: granularStyle,
            isHidden: true,
            isUserInteractionEnabled: false,
            onPress: { actions.append("granular.press") },
            onLongPress: { actions.append("granular.longPress") }
        )

        let sut = SUICardViewStateModel(adapter: adapter)

        assertContent(of: sut, prefix: "granular")
        XCTAssertTrue(sut.isHidden)
        XCTAssertEqual(sut.style, granularStyle)
        XCTAssertFalse(sut.isUserInteractionEnabled)
        assertGradient(sut, equals: [.systemRed])
        sut.onPress?()
        sut.onLongPress?()
        XCTAssertEqual(actions, ["granular.press", "granular.longPress"])
    }

    func test_nonNilModel_clearsOptionalContentButPreservesNilStyleAndInteraction() {
        let adapter = CardViewOutputSwiftUIAdapter()
        let retainedStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])

        displayGranularContent(
            on: adapter,
            prefix: "granular",
            style: retainedStyle,
            isHidden: true,
            isUserInteractionEnabled: false,
            onPress: {},
            onLongPress: {}
        )
        adapter.display(isGradientBorderEnabled: true)
        adapter.display(model: .init(
            accessibilityIdentifier: "empty.card",
            accessibility: .init(label: "Empty", hint: "Clears content"),
            style: nil,
            isUserInteractionEnabled: nil,
            isGradientBorderEnabled: false
        ))

        let sut = SUICardViewStateModel(adapter: adapter)

        XCTAssertFalse(sut.isHidden)
        XCTAssertEqual(sut.style, retainedStyle)
        XCTAssertFalse(sut.isUserInteractionEnabled)
        XCTAssertEqual(sut.accessibilityIdentifier, "empty.card")
        XCTAssertEqual(sut.accessibilityLabel, "Empty")
        XCTAssertEqual(sut.accessibilityHint, "Clears content")
        assertContentIsCleared(sut)
        XCTAssertNil(sut.activeGradientBorderColors)
    }

    func test_nilModel_hidesAndClearsAccessibilityButPreservesGranularState() {
        let adapter = CardViewOutputSwiftUIAdapter()
        let retainedStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])
        var didPress = false

        displayGranularContent(
            on: adapter,
            prefix: "retained",
            style: retainedStyle,
            isHidden: false,
            isUserInteractionEnabled: false,
            onPress: { didPress = true },
            onLongPress: nil
        )
        adapter.display(isGradientBorderEnabled: true)
        adapter.display(model: nil)

        let sut = SUICardViewStateModel(adapter: adapter)

        XCTAssertTrue(sut.isHidden)
        XCTAssertNil(sut.accessibilityIdentifier)
        XCTAssertNil(sut.accessibilityLabel)
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.style, retainedStyle)
        XCTAssertFalse(sut.isUserInteractionEnabled)
        assertContent(of: sut, prefix: "retained")
        assertGradient(sut, equals: [.systemRed])
        sut.onPress?()
        XCTAssertTrue(didPress)
    }

    func test_explicitNilStyleAndInteraction_areNoOpsBeforeAndAfterMount() {
        let adapter = CardViewOutputSwiftUIAdapter()
        let initialStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])
        let updatedStyle = makeStyle(backgroundColor: .systemBlue, gradientColors: [.systemBlue])

        adapter.display(model: .init(
            style: initialStyle,
            isUserInteractionEnabled: false,
            isGradientBorderEnabled: true
        ))
        adapter.display(style: nil)
        adapter.display(isUserInteractionEnabled: nil)

        let sut = SUICardViewStateModel(adapter: adapter)

        XCTAssertEqual(sut.style, initialStyle)
        XCTAssertFalse(sut.isUserInteractionEnabled)
        assertGradient(sut, equals: [.systemRed])

        adapter.display(style: updatedStyle)
        adapter.display(style: nil)
        adapter.display(isUserInteractionEnabled: true)
        adapter.display(isUserInteractionEnabled: nil)

        XCTAssertEqual(sut.style, updatedStyle)
        XCTAssertTrue(sut.isUserInteractionEnabled)
        assertGradient(sut, equals: [.systemRed])
    }

    func test_gradientEvent_replaysInPresenterOrderWithoutRetroactiveStyleChanges() {
        let firstStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])
        let laterStyle = makeStyle(backgroundColor: .systemBlue, gradientColors: [.systemBlue])

        let styleAfterGradientAdapter = CardViewOutputSwiftUIAdapter()
        styleAfterGradientAdapter.display(model: .init(
            style: firstStyle,
            isGradientBorderEnabled: false
        ))
        styleAfterGradientAdapter.display(isGradientBorderEnabled: true)
        styleAfterGradientAdapter.display(style: laterStyle)

        let styleAfterGradient = SUICardViewStateModel(adapter: styleAfterGradientAdapter)
        XCTAssertEqual(styleAfterGradient.style, laterStyle)
        assertGradient(styleAfterGradient, equals: [.systemRed])

        let gradientBeforeStyleAdapter = CardViewOutputSwiftUIAdapter()
        gradientBeforeStyleAdapter.display(isGradientBorderEnabled: true)
        gradientBeforeStyleAdapter.display(style: firstStyle)

        let gradientBeforeStyle = SUICardViewStateModel(adapter: gradientBeforeStyleAdapter)
        XCTAssertEqual(gradientBeforeStyle.style, firstStyle)
        XCTAssertNil(gradientBeforeStyle.activeGradientBorderColors)

        let preservedStyleAdapter = CardViewOutputSwiftUIAdapter()
        preservedStyleAdapter.display(style: firstStyle)
        preservedStyleAdapter.display(model: .init(
            style: nil,
            isGradientBorderEnabled: true
        ))

        let preservedStyle = SUICardViewStateModel(adapter: preservedStyleAdapter)
        XCTAssertEqual(preservedStyle.style, firstStyle)
        assertGradient(preservedStyle, equals: [.systemRed])
    }

    func test_stylesAroundDependentEventsBeforeMount_replayCompletePresenterHistory() {
        let adapter = CardViewOutputSwiftUIAdapter()
        let eventStyle = makeStyle(
            backgroundColor: .systemRed,
            gradientColors: [.systemRed]
        )
        let finalStyle = makeStyle(
            backgroundColor: .systemBlue,
            gradientColors: [.systemBlue],
            trailingImageLeadingSpacing: 18
        )

        adapter.display(style: eventStyle)
        adapter.display(isGradientBorderEnabled: true)
        adapter.display(trailingImage: makeImage("event.trailingImage"))
        adapter.display(style: finalStyle)

        let sut = SUICardViewStateModel(adapter: adapter)

        XCTAssertEqual(sut.style, finalStyle)
        assertGradient(sut, equals: [.systemRed])
        XCTAssertEqual(
            sut.trailingImageLeadingSpacing,
            eventStyle.trailingImageLeadingSpacing
        )
    }

    func test_remount_restoresGradientCapturedBeforeLaterStyle() {
        let adapter = CardViewOutputSwiftUIAdapter()
        let eventStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [.systemRed])
        let laterStyle = makeStyle(backgroundColor: .systemBlue, gradientColors: [.systemBlue])

        weak var firstStateModel: SUICardViewStateModel?
        autoreleasepool {
            let sut = SUICardViewStateModel(adapter: adapter)
            firstStateModel = sut

            adapter.display(style: eventStyle)
            adapter.display(isGradientBorderEnabled: true)
            adapter.display(style: laterStyle)

            XCTAssertEqual(sut.style, laterStyle)
            assertGradient(sut, equals: [.systemRed])
        }
        XCTAssertNil(firstStateModel)

        let remountedSUT = SUICardViewStateModel(adapter: adapter)

        XCTAssertEqual(remountedSUT.style, laterStyle)
        assertGradient(remountedSUT, equals: [.systemRed])
    }

    func test_remountPreservesNestedSwitchUserStateAndLoadingState() {
        let adapter = CardViewOutputSwiftUIAdapter()
        adapter.display(switchControl: .init(isOn: true))

        weak var firstCardStateModel: SUICardViewStateModel?
        weak var firstSwitchStateModel: SUISwitchControlStateModel?
        autoreleasepool {
            let cardStateModel = SUICardViewStateModel(adapter: adapter)
            let switchStateModel = SUISwitchControlStateModel(
                adapter: cardStateModel.switchControlAdapter
            )
            firstCardStateModel = cardStateModel
            firstSwitchStateModel = switchStateModel

            switchStateModel.isOn = false
            cardStateModel.switchControlAdapter.display(isLoading: true)

            XCTAssertFalse(switchStateModel.isOn)
            XCTAssertTrue(switchStateModel.isLoading)
        }
        XCTAssertNil(firstCardStateModel)
        XCTAssertNil(firstSwitchStateModel)

        let remountedCardStateModel = SUICardViewStateModel(adapter: adapter)
        let remountedSwitchStateModel = SUISwitchControlStateModel(
            adapter: remountedCardStateModel.switchControlAdapter
        )

        XCTAssertNotNil(remountedCardStateModel.switchControl)
        XCTAssertFalse(remountedSwitchStateModel.isOn)
        XCTAssertTrue(remountedSwitchStateModel.isLoading)
    }

    func test_titleOnlyThenBottomSeparator_keepsUnusedValueSlotHiddenAcrossRemount() {
        let adapter = CardViewOutputSwiftUIAdapter()
        let style = makeStyle(backgroundColor: .systemRed, gradientColors: [])
        let separator = CardViewPresentableModel.BottomSeparator(
            color: .lightGray,
            height: 4
        )

        weak var firstStateModel: SUICardViewStateModel?
        autoreleasepool {
            let stateModel = SUICardViewStateModel(adapter: adapter)
            firstStateModel = stateModel

            adapter.display(style: style)
            adapter.display(title: .text("Title"))
            adapter.display(bottomSeparator: separator)

            XCTAssertEqual(stateModel.style, style)
            XCTAssertEqual(stateModel.bottomSeparator, separator)
            assertTitleOnlySlots(in: stateModel, title: "Title")
        }
        XCTAssertNil(firstStateModel)

        let remountedStateModel = SUICardViewStateModel(adapter: adapter)

        XCTAssertEqual(remountedStateModel.style, style)
        XCTAssertEqual(remountedStateModel.bottomSeparator, separator)
        assertTitleOnlySlots(in: remountedStateModel, title: "Title")
    }

    func test_titleOnlyThenEnabledSwitch_keepsSwitchAndUnusedValueSlotAcrossRemount() {
        assertTitleOnlySwitchSequence(isOn: true)
    }

    func test_titleOnlyThenDisabledSwitch_keepsSwitchAndUnusedValueSlotAcrossRemount() {
        assertTitleOnlySwitchSequence(isOn: false)
    }

    func test_titleOnlyOnPressStyleUpdate_runsOnceAndSurvivesRemount() {
        assertTitleOnlyActionSequence(isLongPress: false)
    }

    func test_titleOnlyOnLongPressStyleUpdate_runsOnceAndSurvivesRemount() {
        assertTitleOnlyActionSequence(isLongPress: true)
    }

    func test_valueOnly_keepsUIKitInitialKeySlotLayoutAcrossRemount() {
        let adapter = CardViewOutputSwiftUIAdapter()

        weak var firstStateModel: SUICardViewStateModel?
        autoreleasepool {
            let stateModel = SUICardViewStateModel(adapter: adapter)
            firstStateModel = stateModel

            adapter.display(valueTitle: .text("Value"))

            assertValueOnlySlots(in: stateModel, valueTitle: "Value")
        }
        XCTAssertNil(firstStateModel)

        let remountedStateModel = SUICardViewStateModel(adapter: adapter)

        assertValueOnlySlots(in: remountedStateModel, valueTitle: "Value")
    }

    func test_reentrantStateModelCreationDuringOutputReceivesCompleteEvent() throws {
        let adapter = CardViewOutputSwiftUIAdapter()
        let firstStateModel = SUICardViewStateModel(adapter: adapter)
        let style = makeStyle(backgroundColor: .systemBlue, gradientColors: [.systemBlue])
        var reentrantStateModel: SUICardViewStateModel?

        let cancellable = firstStateModel.$title
            .dropFirst()
            .sink { title in
                guard title != nil, reentrantStateModel == nil else { return }
                reentrantStateModel = SUICardViewStateModel(adapter: adapter)
            }

        adapter.display(model: makeModel(
            prefix: "transaction",
            style: style,
            isUserInteractionEnabled: false,
            isGradientBorderEnabled: true,
            onPress: nil,
            onLongPress: nil
        ))

        let remountedStateModel = try XCTUnwrap(reentrantStateModel)
        assertContent(of: remountedStateModel, prefix: "transaction")
        XCTAssertEqual(remountedStateModel.style, style)
        XCTAssertFalse(remountedStateModel.isUserInteractionEnabled)
        assertGradient(remountedStateModel, equals: [.systemBlue])

        adapter.display(isHidden: true)

        XCTAssertFalse(firstStateModel.isHidden)
        XCTAssertTrue(remountedStateModel.isHidden)
        withExtendedLifetime(cancellable) {}
    }

    func test_subTitleAttributeAction_survivesStateModelRemountAndIsRevokedByReplacement() throws {
        let adapter = CardViewOutputSwiftUIAdapter()
        var actionCalls = 0
        adapter.display(subTitle: .attributes([
            .init(text: "Action", onTap: { actionCalls += 1 })
        ]))

        weak var firstStateModel: SUICardViewStateModel?
        var firstAction: (() -> Void)?
        autoreleasepool {
            let stateModel = SUICardViewStateModel(adapter: adapter)
            firstStateModel = stateModel
            firstAction = firstTextAction(in: stateModel.subTitleStateModel.presentable.model)
        }
        XCTAssertNil(firstStateModel)
        let initialAction = try XCTUnwrap(firstAction)

        let remountedStateModel = SUICardViewStateModel(adapter: adapter)
        let remountedAction = try XCTUnwrap(
            firstTextAction(in: remountedStateModel.subTitleStateModel.presentable.model)
        )

        initialAction()
        remountedAction()
        XCTAssertEqual(actionCalls, 2)

        adapter.display(subTitle: .text("Replacement"))
        initialAction()
        remountedAction()

        XCTAssertEqual(actionCalls, 2)
        XCTAssertEqual(remountedStateModel.subTitleStateModel.presentable.model?.text, "Replacement")
    }

    func test_subTitleAnimationCompletion_survivesStructuralRemovalAndStateModelRemount() {
        let adapter = CardViewOutputSwiftUIAdapter()
        var completionCalls = 0
        adapter.display(subTitle: .animatedDecimal(
            from: 0,
            to: 1,
            mapToString: nil,
            animationStyle: .none,
            duration: 0,
            completion: { completionCalls += 1 }
        ))

        weak var firstStateModel: SUICardViewStateModel?
        autoreleasepool {
            let stateModel = SUICardViewStateModel(adapter: adapter)
            firstStateModel = stateModel

            adapter.display(subTitle: nil)

            XCTAssertNil(stateModel.subTitle)
            XCTAssertTrue(stateModel.subTitleStateModel.isHidden)
        }
        XCTAssertNil(firstStateModel)

        var remountedStateModel: SUICardViewStateModel? = .init(adapter: adapter)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))

        XCTAssertEqual(completionCalls, 1)
        XCTAssertNil(remountedStateModel?.subTitle)
        XCTAssertEqual(remountedStateModel?.subTitleStateModel.presentable.model?.text, "1")

        remountedStateModel = nil
        let secondRemountedStateModel = SUICardViewStateModel(adapter: adapter)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))

        XCTAssertEqual(completionCalls, 1)
        XCTAssertEqual(secondRemountedStateModel.subTitleStateModel.presentable.model?.text, "1")
    }
}

private extension SUICardViewStateModelTests {
    func assertTitleOnlySwitchSequence(
        isOn: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let adapter = CardViewOutputSwiftUIAdapter()
        let style = makeStyle(backgroundColor: .systemRed, gradientColors: [])
        let switchModel = SwitchControlPresentableModel(
            isOn: isOn,
            isEnabled: true,
            style: .init(
                tintColor: .blue,
                thumbTintColor: .green,
                backgroundColor: .white,
                cornerRadius: 10
            )
        )

        weak var firstStateModel: SUICardViewStateModel?
        autoreleasepool {
            let stateModel = SUICardViewStateModel(adapter: adapter)
            firstStateModel = stateModel

            adapter.display(style: style)
            adapter.display(title: .text("Title"))
            adapter.display(switchControl: switchModel)

            XCTAssertEqual(stateModel.style, style, file: file, line: line)
            XCTAssertEqual(stateModel.switchControl?.isOn, isOn, file: file, line: line)
            XCTAssertEqual(stateModel.switchControl?.isEnabled, true, file: file, line: line)
            assertTitleOnlySlots(in: stateModel, title: "Title", file: file, line: line)
            assertSwitchState(in: stateModel, isOn: isOn, file: file, line: line)
        }
        XCTAssertNil(firstStateModel, file: file, line: line)

        let remountedStateModel = SUICardViewStateModel(adapter: adapter)

        XCTAssertEqual(remountedStateModel.style, style, file: file, line: line)
        XCTAssertEqual(remountedStateModel.switchControl?.isOn, isOn, file: file, line: line)
        XCTAssertEqual(remountedStateModel.switchControl?.isEnabled, true, file: file, line: line)
        assertTitleOnlySlots(in: remountedStateModel, title: "Title", file: file, line: line)
        assertSwitchState(in: remountedStateModel, isOn: isOn, file: file, line: line)
    }

    func assertTitleOnlyActionSequence(
        isLongPress: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let adapter = CardViewOutputSwiftUIAdapter()
        let initialStyle = makeStyle(backgroundColor: .systemRed, gradientColors: [])
        let pressedStyle = makeStyle(backgroundColor: .systemGreen, gradientColors: [])
        var actionCalls = 0
        let action = {
            actionCalls += 1
            adapter.display(style: pressedStyle)
        }

        weak var firstStateModel: SUICardViewStateModel?
        autoreleasepool {
            let stateModel = SUICardViewStateModel(adapter: adapter)
            firstStateModel = stateModel

            adapter.display(style: initialStyle)
            adapter.display(title: .text("Title"))
            if isLongPress {
                adapter.display(onLongPress: action)
                stateModel.onLongPress?()
            } else {
                adapter.display(onPress: action)
                stateModel.onPress?()
            }

            XCTAssertEqual(actionCalls, 1, file: file, line: line)
            XCTAssertEqual(stateModel.style, pressedStyle, file: file, line: line)
            assertTitleOnlySlots(in: stateModel, title: "Title", file: file, line: line)
        }
        XCTAssertNil(firstStateModel, file: file, line: line)

        let remountedStateModel = SUICardViewStateModel(adapter: adapter)

        XCTAssertEqual(remountedStateModel.style, pressedStyle, file: file, line: line)
        assertTitleOnlySlots(in: remountedStateModel, title: "Title", file: file, line: line)
        if isLongPress {
            remountedStateModel.onLongPress?()
        } else {
            remountedStateModel.onPress?()
        }
        XCTAssertEqual(actionCalls, 2, file: file, line: line)
        XCTAssertEqual(remountedStateModel.style, pressedStyle, file: file, line: line)
    }

    func assertTitleOnlySlots(
        in cardStateModel: SUICardViewStateModel,
        title: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let titleStateModel = SUIKeyValueFieldViewStateModel(
            adapter: cardStateModel.titleViewsAdapter,
            displaysBottomImage: true,
            isHidden: false
        )

        XCTAssertEqual(titleStateModel.keyTitle, .text(title), file: file, line: line)
        XCTAssertNil(titleStateModel.valueTitle, file: file, line: line)
        XCTAssertFalse(titleStateModel.isKeySlotHidden, file: file, line: line)
        XCTAssertTrue(titleStateModel.isValueSlotHidden, file: file, line: line)
        XCTAssertTrue(titleStateModel.isBottomImageSlotHidden, file: file, line: line)
        XCTAssertFalse(titleStateModel.isHidden, file: file, line: line)
    }

    func assertValueOnlySlots(
        in cardStateModel: SUICardViewStateModel,
        valueTitle: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let titleStateModel = SUIKeyValueFieldViewStateModel(
            adapter: cardStateModel.titleViewsAdapter,
            displaysBottomImage: true,
            isHidden: false
        )

        XCTAssertNil(titleStateModel.keyTitle, file: file, line: line)
        XCTAssertEqual(titleStateModel.valueTitle, .text(valueTitle), file: file, line: line)
        XCTAssertFalse(titleStateModel.isKeySlotHidden, file: file, line: line)
        XCTAssertFalse(titleStateModel.isValueSlotHidden, file: file, line: line)
        XCTAssertTrue(titleStateModel.isBottomImageSlotHidden, file: file, line: line)
        XCTAssertFalse(titleStateModel.isHidden, file: file, line: line)
    }

    func assertSwitchState(
        in cardStateModel: SUICardViewStateModel,
        isOn: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let switchStateModel = SUISwitchControlStateModel(
            adapter: cardStateModel.switchControlAdapter
        )

        XCTAssertEqual(switchStateModel.isOn, isOn, file: file, line: line)
        XCTAssertTrue(switchStateModel.isEnabled, file: file, line: line)
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

    func displayGranularContent(
        on adapter: CardViewOutputSwiftUIAdapter,
        prefix: String,
        style: CardViewPresentableModel.Style,
        isHidden: Bool,
        isUserInteractionEnabled: Bool,
        onPress: (() -> Void)?,
        onLongPress: (() -> Void)?
    ) {
        let model = makeModel(
            prefix: prefix,
            style: style,
            isUserInteractionEnabled: isUserInteractionEnabled,
            isGradientBorderEnabled: false,
            onPress: onPress,
            onLongPress: onLongPress
        )
        adapter.display(style: style)
        adapter.display(backgroundImage: model.backgroundImage)
        adapter.display(leadingTitles: model.leadingTitles)
        adapter.display(title: model.title)
        adapter.display(valueTitle: model.valueTitle)
        adapter.display(subTitle: model.subTitle)
        adapter.display(leadingImage: model.leadingImage)
        adapter.display(secondaryLeadingImage: model.secondaryLeadingImage)
        adapter.display(trailingImage: model.trailingImage)
        adapter.display(secondaryTrailingImage: model.secondaryTrailingImage)
        adapter.display(bottomImage: model.bottomImage)
        adapter.display(bottomSeparator: model.bottomSeparator)
        adapter.display(switchControl: model.switchControl)
        adapter.display(trailingTitles: model.trailingTitles)
        adapter.display(onPress: onPress)
        adapter.display(onLongPress: onLongPress)
        adapter.display(isHidden: isHidden)
        adapter.display(isUserInteractionEnabled: isUserInteractionEnabled)
    }

    func makeModel(
        prefix: String,
        style: CardViewPresentableModel.Style,
        isUserInteractionEnabled: Bool,
        isGradientBorderEnabled: Bool,
        onPress: (() -> Void)?,
        onLongPress: (() -> Void)?
    ) -> CardViewPresentableModel {
        .init(
            accessibilityIdentifier: "\(prefix).card",
            accessibility: .init(label: "\(prefix).label", hint: "\(prefix).hint"),
            style: style,
            backgroundImage: makeImage("\(prefix).background"),
            title: .text("\(prefix).title"),
            leadingTitles: .init(.text("\(prefix).leading.key"), .text("\(prefix).leading.value")),
            trailingTitles: .init(.text("\(prefix).trailing.key"), .text("\(prefix).trailing.value")),
            leadingImage: makeImage("\(prefix).leadingImage"),
            secondaryLeadingImage: makeImage("\(prefix).secondaryLeadingImage"),
            trailingImage: makeImage("\(prefix).trailingImage"),
            secondaryTrailingImage: makeImage("\(prefix).secondaryTrailingImage"),
            subTitle: .text("\(prefix).subTitle"),
            valueTitle: .text("\(prefix).valueTitle"),
            bottomImage: makeImage("\(prefix).bottomImage"),
            bottomSeparator: .init(color: .systemGreen, height: 2),
            switchControl: .init(accessibilityIdentifier: "\(prefix).switch", isOn: true),
            onPress: onPress,
            onLongPress: onLongPress,
            isUserInteractionEnabled: isUserInteractionEnabled,
            isGradientBorderEnabled: isGradientBorderEnabled
        )
    }

    func makeImage(_ accessibilityIdentifier: String) -> ImageViewPresentableModel {
        .init(
            accessibilityIdentifier: accessibilityIdentifier,
            size: .init(width: 20, height: 20),
            image: .symbolName("star.fill"),
            contentModeIsFit: true
        )
    }

    func makeStyle(
        backgroundColor: UIColor,
        gradientColors: [UIColor],
        trailingImageLeadingSpacing: CGFloat = 6
    ) -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: backgroundColor,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .zero,
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: .label,
            titleKeyTextColor: .label,
            trailingTitleKeyTextColor: .label,
            titleValueTextColor: .label,
            subTitleTextColor: .secondaryLabel,
            leadingTitleKeyLabelFont: .systemFont(ofSize: 12),
            titleKeyLabelFont: .systemFont(ofSize: 13),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleValueLabelFont: .systemFont(ofSize: 15),
            subTitleLabelFont: .systemFont(ofSize: 16),
            cornerRadius: 8,
            stackSpace: 2,
            hStackViewSpacing: 4,
            titleKeyNumberOfLines: 1,
            titleValueNumberOfLines: 2,
            gradientBorderColors: gradientColors,
            trailingImageLeadingSpacing: trailingImageLeadingSpacing,
            secondaryTrailingImageLeadingSpacing: 7
        )
    }

    func assertContent(
        of sut: SUICardViewStateModel,
        prefix: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.backgroundImage?.accessibilityIdentifier, "\(prefix).background", file: file, line: line)
        XCTAssertEqual(sut.title, .text("\(prefix).title"), file: file, line: line)
        XCTAssertEqual(sut.leadingTitles?.first, .text("\(prefix).leading.key"), file: file, line: line)
        XCTAssertEqual(sut.leadingTitles?.second, .text("\(prefix).leading.value"), file: file, line: line)
        XCTAssertEqual(sut.trailingTitles?.first, .text("\(prefix).trailing.key"), file: file, line: line)
        XCTAssertEqual(sut.trailingTitles?.second, .text("\(prefix).trailing.value"), file: file, line: line)
        XCTAssertEqual(sut.leadingImage?.accessibilityIdentifier, "\(prefix).leadingImage", file: file, line: line)
        XCTAssertEqual(
            sut.secondaryLeadingImage?.accessibilityIdentifier,
            "\(prefix).secondaryLeadingImage",
            file: file,
            line: line
        )
        XCTAssertEqual(sut.trailingImage?.accessibilityIdentifier, "\(prefix).trailingImage", file: file, line: line)
        XCTAssertEqual(
            sut.secondaryTrailingImage?.accessibilityIdentifier,
            "\(prefix).secondaryTrailingImage",
            file: file,
            line: line
        )
        XCTAssertEqual(sut.subTitle, .text("\(prefix).subTitle"), file: file, line: line)
        XCTAssertEqual(sut.valueTitle, .text("\(prefix).valueTitle"), file: file, line: line)
        XCTAssertEqual(sut.bottomImage?.accessibilityIdentifier, "\(prefix).bottomImage", file: file, line: line)
        XCTAssertEqual(sut.bottomSeparator, .init(color: .systemGreen, height: 2), file: file, line: line)
        XCTAssertEqual(sut.switchControl?.accessibilityIdentifier, "\(prefix).switch", file: file, line: line)
        XCTAssertEqual(sut.switchControl?.isOn, true, file: file, line: line)
    }

    func assertContentIsCleared(
        _ sut: SUICardViewStateModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNil(sut.backgroundImage, file: file, line: line)
        XCTAssertNil(sut.title, file: file, line: line)
        XCTAssertNil(sut.leadingTitles, file: file, line: line)
        XCTAssertNil(sut.trailingTitles, file: file, line: line)
        XCTAssertNil(sut.leadingImage, file: file, line: line)
        XCTAssertNil(sut.secondaryLeadingImage, file: file, line: line)
        XCTAssertNil(sut.trailingImage, file: file, line: line)
        XCTAssertNil(sut.secondaryTrailingImage, file: file, line: line)
        XCTAssertNil(sut.subTitle, file: file, line: line)
        XCTAssertNil(sut.valueTitle, file: file, line: line)
        XCTAssertNil(sut.bottomImage, file: file, line: line)
        XCTAssertNil(sut.bottomSeparator, file: file, line: line)
        XCTAssertNil(sut.switchControl, file: file, line: line)
        XCTAssertNil(sut.onPress, file: file, line: line)
        XCTAssertNil(sut.onLongPress, file: file, line: line)
    }

    func assertGradient(
        _ sut: SUICardViewStateModel,
        equals colors: [UIColor],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectedColors = colors
        let actualColors = sut.activeGradientBorderColors
        XCTAssertEqual(
            actualColors,
            expectedColors,
            file: file,
            line: line
        )
    }
}
#endif
