#if canImport(SwiftUI) && canImport(UIKit)
    import Foundation
    @testable import WrapKit
    import XCTest

    @MainActor
    final class SwiftUIOutputReplayClosureStoreTests: XCTestCase {
        func test_buttonGranularNilKeepsOldPublicDataButRevokesItsAction() throws {
            final class ActionOwner {}

            let adapter = ButtonOutputSwiftUIAdapter()
            var calls = 0
            weak var weakOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                weakOwner = owner
                adapter.display(model: .init(
                    title: "Retained title",
                    onPress: {
                        _ = owner
                        calls += 1
                    }
                ))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)
            let oldAction = try XCTUnwrap(oldState.model?.onPress)

            XCTAssertNotNil(weakOwner)
            oldAction()
            XCTAssertEqual(calls, 1)

            adapter.display(onPress: nil)

            XCTAssertEqual(oldState.model?.title, "Retained title")
            XCTAssertNil(weakOwner)
            oldAction()
            XCTAssertEqual(calls, 1)
        }

        func test_headerGranularNilRevokesNestedActionButNilModelKeepsUIKitActionSemantics() throws {
            final class ActionOwner {}

            let adapter = HeaderOutputSwiftUIAdapter()
            var calls = 0
            weak var weakOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                weakOwner = owner
                adapter.display(model: .init(
                    primeTrailingImage: .init(
                        title: "Retained button",
                        onPress: {
                            _ = owner
                            calls += 1
                        }
                    )
                ))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)

            adapter.display(model: nil)
            oldState.model.primeTrailingImage?.onPress?()
            XCTAssertEqual(calls, 1)
            XCTAssertNotNil(weakOwner)

            adapter.display(primeTrailingImage: nil)
            XCTAssertNil(weakOwner)
            oldState.model.primeTrailingImage?.onPress?()
            XCTAssertEqual(calls, 1)
        }

        func test_headerCenterBranchReplacementRevokesOldActionsButKeepsPendingCompletion() throws {
            final class ActionOwner {}
            final class CompletionOwner {}

            let adapter = HeaderOutputSwiftUIAdapter()
            var actionCalls = 0
            var completionCalls = 0
            weak var weakActionOwner: ActionOwner?
            weak var weakCompletionOwner: CompletionOwner?
            do {
                let actionOwner = ActionOwner()
                let completionOwner = CompletionOwner()
                weakActionOwner = actionOwner
                weakCompletionOwner = completionOwner
                adapter.display(centerView: .keyValue(.init(
                    .attributes([.init(text: "Action", onTap: {
                        _ = actionOwner
                        actionCalls += 1
                    })]),
                    .animatedDecimal(
                        from: 0,
                        to: 1,
                        mapToString: nil,
                        animationStyle: .none,
                        duration: 1,
                        completion: {
                            _ = completionOwner
                            completionCalls += 1
                        }
                    )
                )))
            }
            let oldCenter = try XCTUnwrap(adapter.displayCenterViewState?.centerView)
            let oldAction = try XCTUnwrap(textAction(in: keyValueFirst(in: oldCenter)))

            XCTAssertNotNil(weakActionOwner)
            XCTAssertNotNil(weakCompletionOwner)
            oldAction()
            XCTAssertEqual(actionCalls, 1)

            adapter.display(centerView: .titledImage(.init(nil, .text("Replacement"))))

            XCTAssertNil(weakActionOwner)
            XCTAssertNotNil(weakCompletionOwner)
            oldAction()
            XCTAssertEqual(actionCalls, 1)

            animationCompletion(in: keyValueSecond(in: oldCenter))?()
            XCTAssertEqual(completionCalls, 1)
            XCTAssertNil(weakCompletionOwner)
        }

        func test_headerNilCenterRevokesTitledImageActionsAndReleasesTheirOwner() throws {
            final class ActionOwner {}

            let adapter = HeaderOutputSwiftUIAdapter()
            var calls = 0
            weak var weakOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                weakOwner = owner
                adapter.display(centerView: .titledImage(.init(
                    .init(
                        onPress: {
                            _ = owner
                            calls += 1
                        }
                    ),
                    .attributes([.init(text: "Action", onTap: {
                        _ = owner
                        calls += 1
                    })])
                )))
            }
            let oldCenter = try XCTUnwrap(adapter.displayCenterViewState?.centerView)
            let imageAction = try XCTUnwrap(titledImage(in: oldCenter)?.first?.onPress)
            let titleAction = try XCTUnwrap(
                textAction(in: titledImage(in: oldCenter)?.second?.model)
            )

            XCTAssertNotNil(weakOwner)
            imageAction()
            titleAction()
            XCTAssertEqual(calls, 2)

            adapter.display(centerView: nil)

            XCTAssertNil(weakOwner)
            imageAction()
            titleAction()
            XCTAssertEqual(calls, 2)
        }

        func test_nestedAnimatedLabelCompletionRunsOnceAcrossStateModelRemount() throws {
            final class CompletionOwner {}

            let adapter = EmptyViewOutputSwiftUIAdapter()
            var completionCount = 0
            weak var weakOwner: CompletionOwner?
            do {
                let owner = CompletionOwner()
                weakOwner = owner
                adapter.display(model: .init(
                    title: .init(
                        model: .textStyled(
                            text: .animatedDecimal(
                                from: 0,
                                to: 1,
                                mapToString: nil,
                                animationStyle: .none,
                                duration: 0,
                                completion: {
                                    _ = owner
                                    completionCount += 1
                                }
                            )
                        )
                    )
                ))
            }

            var firstStateModel: SUIEmptyViewStateModel? = .init(adapter: adapter)
            let firstCompletion = animationCompletion(in: firstStateModel?.title?.model)
            firstCompletion?()
            XCTAssertEqual(completionCount, 1)
            XCTAssertNil(weakOwner)

            firstStateModel = nil
            let remountedStateModel = SUIEmptyViewStateModel(adapter: adapter)
            let remountedCompletion = animationCompletion(in: remountedStateModel.title?.model)
            remountedCompletion?()
            firstCompletion?()

            XCTAssertEqual(completionCount, 1)
        }

        func test_expandableCardReplacementRevokesRetainedOldActionAndRemountKeepsLatestAction() throws {
            final class ActionOwner {}

            let adapter = ExpandableCardViewOutputSwiftUIAdapter()
            var calls: [String] = []
            weak var weakOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                weakOwner = owner
                adapter.display(model: Pair(
                    CardViewPresentableModel(onPress: {
                        _ = owner
                        calls.append("old")
                    }),
                    nil
                ))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)
            var firstExpandableStateModel: SUIExpandableCardViewStateModel? = .init(
                adapter: adapter
            )
            let primeCardAdapter = try XCTUnwrap(firstExpandableStateModel?.primeCardAdapter)
            var firstCardStateModel: SUICardViewStateModel? = .init(adapter: primeCardAdapter)
            let oldChildAction = try XCTUnwrap(firstCardStateModel?.onPress)

            adapter.display(model: Pair(
                CardViewPresentableModel(onPress: { calls.append("latest") }),
                nil
            ))

            XCTAssertNil(weakOwner)
            oldState.model.first.onPress?()
            oldChildAction()
            XCTAssertTrue(calls.isEmpty)

            firstCardStateModel?.onPress?()
            firstCardStateModel = nil
            firstExpandableStateModel = nil

            let remountedExpandableStateModel = SUIExpandableCardViewStateModel(
                adapter: adapter
            )
            XCTAssertTrue(remountedExpandableStateModel.primeCardAdapter === primeCardAdapter)
            let remountedCardStateModel = SUICardViewStateModel(
                adapter: remountedExpandableStateModel.primeCardAdapter
            )
            remountedCardStateModel.onPress?()

            XCTAssertEqual(calls, ["latest", "latest"])
        }

        func test_expandableCardRemountKeepsSecondaryLabelAnimationDeadlineAndCompletion() throws {
            let adapter = ExpandableCardViewOutputSwiftUIAdapter()
            let completion = expectation(description: "Nested secondary label animation completes")
            var completionCalls = 0
            let duration: TimeInterval = 0.75
            let startedAt = Date()
            adapter.display(model: Pair(
                CardViewPresentableModel(),
                CardViewPresentableModel(subTitle: .animatedDecimal(
                    from: 0,
                    to: 1,
                    mapToString: nil,
                    animationStyle: .none,
                    duration: duration,
                    completion: {
                        completionCalls += 1
                        completion.fulfill()
                    }
                ))
            ))

            var firstExpandableStateModel: SUIExpandableCardViewStateModel? = .init(
                adapter: adapter
            )
            let secondaryCardAdapter = try XCTUnwrap(
                firstExpandableStateModel?.secondaryCardAdapter
            )
            var firstCardStateModel: SUICardViewStateModel? = .init(
                adapter: secondaryCardAdapter
            )

            RunLoop.main.run(until: Date().addingTimeInterval(0.45))
            XCTAssertEqual(completionCalls, 0)

            firstCardStateModel = nil
            firstExpandableStateModel = nil

            var remountedExpandableStateModel: SUIExpandableCardViewStateModel? = .init(
                adapter: adapter
            )
            XCTAssertTrue(
                remountedExpandableStateModel?.secondaryCardAdapter === secondaryCardAdapter
            )
            var remountedCardStateModel: SUICardViewStateModel? = .init(
                adapter: try XCTUnwrap(remountedExpandableStateModel?.secondaryCardAdapter)
            )

            wait(for: [completion], timeout: 0.55)

            let elapsed = Date().timeIntervalSince(startedAt)
            XCTAssertEqual(completionCalls, 1)
            XCTAssertGreaterThanOrEqual(elapsed, duration - 0.1)
            XCTAssertLessThan(
                elapsed,
                duration + 0.35,
                "Remount must resume the original deadline instead of starting a new animation."
            )
            XCTAssertEqual(
                remountedCardStateModel?.subTitleStateModel.presentable.model?.text,
                "1"
            )

            remountedCardStateModel = nil
            remountedExpandableStateModel = nil
            let secondExpandableStateModel = SUIExpandableCardViewStateModel(adapter: adapter)
            let secondCardStateModel = SUICardViewStateModel(
                adapter: secondExpandableStateModel.secondaryCardAdapter
            )
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))

            XCTAssertEqual(completionCalls, 1)
            XCTAssertEqual(secondCardStateModel.subTitleStateModel.presentable.model?.text, "1")
        }

        func test_labelContentReplacementRevokesRetainedAttributeAction() throws {
            final class ActionOwner {}

            let adapter = TextOutputSwiftUIAdapter()
            var calls = 0
            weak var weakOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                weakOwner = owner
                adapter.display(model: .init(model: .attributes([
                    .init(text: "Link", onTap: {
                        _ = owner
                        calls += 1
                    })
                ])))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)
            let oldAction = try XCTUnwrap(textAction(in: oldState.model?.model))

            XCTAssertNotNil(weakOwner)
            oldAction()
            XCTAssertEqual(calls, 1)

            adapter.display(text: "Replacement")

            XCTAssertNil(weakOwner)
            oldAction()
            XCTAssertEqual(calls, 1)
        }

        func test_labelContentReplacementKeepsPendingAnimationCallbacksUntilNextAnimation() throws {
            final class AnimationOwner {}

            let adapter = TextOutputSwiftUIAdapter()
            var completionCalls = 0
            weak var weakOwner: AnimationOwner?
            do {
                let owner = AnimationOwner()
                weakOwner = owner
                adapter.display(model: .init(model: .animatedDecimal(
                    from: 0,
                    to: 1,
                    mapToString: {
                        _ = owner
                        return .text($0.asString())
                    },
                    animationStyle: .none,
                    duration: 0,
                    completion: {
                        _ = owner
                        completionCalls += 1
                    }
                )))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)

            adapter.display(text: "Replacement")

            XCTAssertNotNil(weakOwner)
            if case .animatedDecimal(_, _, _, let mapToString, _, _, _) = oldState.model?.model {
                XCTAssertEqual(mapToString?(0).text, Decimal.zero.asString())
            } else {
                XCTFail("Expected retained animation model")
            }

            adapter.display(model: .animatedDecimal(
                from: 0,
                to: 2,
                mapToString: nil,
                animationStyle: .none,
                duration: 0,
                completion: nil
            ))

            XCTAssertNil(weakOwner)
            if case .animatedDecimal(_, _, _, let mapToString, _, _, let completion) = oldState.model?.model {
                XCTAssertNil(mapToString?(0).text)
                completion?()
            } else {
                XCTFail("Expected retained animation model")
            }
            XCTAssertEqual(completionCalls, 0)
        }

        func test_labelAnimationReplacementRevokesMappedResultCallbacks() throws {
            final class ActionOwner {}

            let adapter = TextOutputSwiftUIAdapter()
            var actionCalls = 0
            weak var weakOwner: ActionOwner?
            do {
                let owner = ActionOwner()
                weakOwner = owner
                adapter.display(model: .init(model: .animatedDecimal(
                    from: 0,
                    to: 1,
                    mapToString: { _ in
                        .attributes([.init(text: "Mapped action", onTap: {
                            _ = owner
                            actionCalls += 1
                        })])
                    },
                    animationStyle: .none,
                    duration: 0,
                    completion: nil
                )))
            }

            let oldState = try XCTUnwrap(adapter.displayModelState)
            guard case .animatedDecimal(_, _, _, let mapToString, _, _, _) = oldState.model?.model else {
                return XCTFail("Expected retained animation model")
            }
            let mappedResult = try XCTUnwrap(mapToString?(0))
            let mappedAction = try XCTUnwrap(textAction(in: mappedResult))

            XCTAssertNotNil(weakOwner)
            mappedAction()
            XCTAssertEqual(actionCalls, 1)

            adapter.display(model: .animatedDecimal(
                from: 0,
                to: 2,
                mapToString: nil,
                animationStyle: .none,
                duration: 0,
                completion: nil
            ))

            XCTAssertNil(weakOwner)
            mappedAction()
            XCTAssertEqual(actionCalls, 1)
        }

        func test_pickerModelReplacementRevokesRetainedProvidersAndAction() throws {
            final class CallbackOwner {}

            let adapter = PickerViewOutputSwiftUIAdapter()
            var actionCalls = 0
            weak var weakOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                weakOwner = owner
                adapter.display(model: .init(
                    componentsCount: { _ = owner; return 1 },
                    rowsCount: { _ = owner; return 1 },
                    titleForRowAt: { _ = owner; return "Row \($0)" },
                    didSelectAt: { _ = owner; actionCalls += $0 }
                ))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)

            XCTAssertNotNil(weakOwner)
            XCTAssertEqual(oldState.model?.componentsCount?(), 1)
            XCTAssertEqual(oldState.model?.rowsCount?(), 1)
            XCTAssertEqual(oldState.model?.titleForRowAt?(0), "Row 0")
            oldState.model?.didSelectAt?(1)
            XCTAssertEqual(actionCalls, 1)

            adapter.display(model: nil)

            XCTAssertNil(weakOwner)
            XCTAssertNil(oldState.model?.componentsCount?())
            XCTAssertEqual(oldState.model?.rowsCount?(), 0)
            XCTAssertNil(oldState.model?.titleForRowAt?(0))
            oldState.model?.didSelectAt?(1)
            XCTAssertEqual(actionCalls, 1)
        }

        func test_refreshReplacementRevokesRetainedModelCallback() throws {
            final class CallbackOwner {}

            let adapter = RefreshControlOutputSwiftUIAdapter()
            var calls = 0
            weak var weakOwner: CallbackOwner?
            do {
                let owner = CallbackOwner()
                weakOwner = owner
                adapter.display(model: .init(onRefresh: {
                    _ = owner
                    calls += 1
                }))
            }
            let oldState = try XCTUnwrap(adapter.displayModelState)
            let oldRefresh = try XCTUnwrap(oldState.model?.onRefresh)

            XCTAssertNotNil(weakOwner)
            oldRefresh()
            XCTAssertEqual(calls, 1)

            adapter.display(onRefresh: nil)

            XCTAssertNil(weakOwner)
            oldRefresh()
            XCTAssertEqual(calls, 1)
        }
    }

    private extension SwiftUIOutputReplayClosureStoreTests {
        func keyValueFirst(
            in centerView: HeaderPresentableModel.CenterView
        ) -> TextOutputPresentableModel.TextModel? {
            guard case .keyValue(let pair) = centerView else { return nil }
            return pair.first?.model
        }

        func keyValueSecond(
            in centerView: HeaderPresentableModel.CenterView
        ) -> TextOutputPresentableModel.TextModel? {
            guard case .keyValue(let pair) = centerView else { return nil }
            return pair.second?.model
        }

        func titledImage(
            in centerView: HeaderPresentableModel.CenterView
        ) -> Pair<ImageViewPresentableModel?, TextOutputPresentableModel?>? {
            guard case .titledImage(let pair) = centerView else { return nil }
            return pair
        }

        func textAction(
            in model: TextOutputPresentableModel.TextModel?
        ) -> (() -> Void)? {
            switch model {
            case .attributes(let attributes):
                return attributes.first?.onTap
            case .textStyled(let nested, _, _, _, _):
                return textAction(in: nested)
            default:
                return nil
            }
        }

        func animationCompletion(
            in model: TextOutputPresentableModel.TextModel?
        ) -> (() -> Void)? {
            guard let model else { return nil }
            switch model {
            case .animatedDecimal(_, _, _, _, _, _, let completion):
                return completion
            case .animated(_, _, _, _, _, _, let completion):
                return completion
            case .textStyled(let text, _, _, _, _):
                return animationCompletion(in: text)
            case .text, .attributes, .attributedString:
                return nil
            }
        }
    }
#endif
