//
//  SUILabelViewModel.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/11/25.
//

#if canImport(Combine)
import Combine
import Dispatch
import Foundation

public final class SUILabelStateModel: ObservableObject {
    private struct PendingAnimationCheckpoint {
        let finalContent: TextOutputPresentableModel.TextModel
        let preservesCurrentStyle: Bool
        let timeline: AnimationTimeline
        let startedAt: Date
        let deadline: Date
        let completion: (() -> Void)?
        let outputSequence: UInt64
    }

    private struct OutputReplayCheckpoint {
        let presentable: TextOutputPresentableModel
        let isHidden: Bool
        let pendingAnimation: PendingAnimationCheckpoint?
        let latestAccessibilityOutputSequence: UInt64
        let latestContentOutputSequence: UInt64
        let latestVisibilityOutputSequence: UInt64
    }

    @Published var presentable: TextOutputPresentableModel = .text(nil)
    @Published var isHidden: Bool = false
    private(set) var animationRenderGeneration: UInt64 = 0
    
    @Published private var adapter: TextOutputSwiftUIAdapter
    private var outputReplayConsumer: TextOutputSwiftUIAdapter.OutputReplayConsumer?
    private var pendingAnimationCompletion: DispatchWorkItem?
    private var pendingAnimationCheckpoint: PendingAnimationCheckpoint?
    private var cancellables: Set<AnyCancellable> = []
    private var latestAccessibilityOutputSequence: UInt64 = 0
    private var latestContentOutputSequence: UInt64 = 0
    private var latestVisibilityOutputSequence: UInt64 = 0
    
    init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
        adapter.outputReplayPublisher(
            adapter.$displayModelState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    model: value.model,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayTextState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    content: .text(value.text),
                    preservesCurrentStyle: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayAttributesState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    content: .attributes(value.attributes),
                    preservesCurrentStyle: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayTextModelState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                guard let textModel = value.textModel else {
                    self.apply(
                        isHidden: true,
                        outputSequence: value.outputSequence
                    )
                    return
                }
                self.apply(
                    content: textModel,
                    preservesCurrentStyle: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayHtmlStringConfigState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    content: .attributedString(
                        value.htmlString,
                        config: value.config
                    ),
                    preservesCurrentStyle: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayHtmlStringState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    content: .attributedString(
                        value.htmlString,
                        config: .default
                    ),
                    preservesCurrentStyle: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayIdStartAmountEndAmountMapToStringAnimationStyleDurationCompletionState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    content: .animatedDecimal(
                        id: value.id,
                        from: value.startAmount,
                        to: value.endAmount,
                        mapToString: value.mapToString,
                        animationStyle: value.animationStyle,
                        duration: value.duration,
                        completion: value.completion
                    ),
                    preservesCurrentStyle: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    isHidden: value.isHidden,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayCheckpointRequestPublisher(consumer: outputReplayConsumer)
            .sink { [weak self] in self?.persistReplayCheckpoint() }
            .store(in: &cancellables)

        if let outputReplayCheckpoint {
            restore(outputReplayCheckpoint)
        }

        bufferedOutputReplayPublisher
            .sink { [weak adapter] event in
                adapter?.replayOutputEvent(event, consumer: outputReplayConsumer)
            }
            .store(in: &cancellables)

        persistReplayCheckpoint()
    }

    deinit {
        cancelPendingAnimationCompletion()
    }

    private func cancelPendingAnimationCompletion() {
        pendingAnimationCompletion?.cancel()
        pendingAnimationCompletion = nil
        pendingAnimationCheckpoint = nil
    }

    func animationRenderingDidAppear() {
        resumePendingAnimationRendering()
    }

    private func apply(
        model: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        apply(
            accessibilityIdentifier: model?.accessibilityIdentifier,
            accessibility: model?.accessibility,
            outputSequence: outputSequence
        )

        guard let model else {
            apply(isHidden: true, outputSequence: outputSequence)
            return
        }
        guard let content = model.model else {
            apply(isHidden: false, outputSequence: outputSequence)
            return
        }
        apply(
            content: content,
            preservesCurrentStyle: true,
            outputSequence: outputSequence
        )
    }

    private func apply(
        accessibilityIdentifier: String?,
        accessibility: Accessibility?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestAccessibilityOutputSequence else { return }
        latestAccessibilityOutputSequence = outputSequence
        presentable = .init(
            accessibilityIdentifier: accessibilityIdentifier,
            accessibility: accessibility,
            model: presentable.model
        )
        persistReplayCheckpoint()
    }

    private func apply(
        content: TextOutputPresentableModel.TextModel,
        preservesCurrentStyle: Bool,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestContentOutputSequence else { return }
        latestContentOutputSequence = outputSequence

        let animation = Self.animationPlan(for: content)
        if animation != nil {
            cancelPendingAnimationCompletion()
            animationRenderGeneration &+= 1
        }
        replaceContent(
            with: animation?.initialContent ?? content,
            preservesCurrentStyle: preservesCurrentStyle
        )
        apply(
            isHidden: Self.shouldHide(content),
            outputSequence: outputSequence
        )

        guard let animation else { return }
        let startedAt = Date()
        schedulePendingAnimation(PendingAnimationCheckpoint(
            finalContent: animation.finalContent,
            preservesCurrentStyle: preservesCurrentStyle,
            timeline: animation.timeline,
            startedAt: startedAt,
            deadline: startedAt.addingTimeInterval(max(animation.duration, 0)),
            completion: animation.completion,
            outputSequence: outputSequence
        ))
    }

    private func schedulePendingAnimation(_ checkpoint: PendingAnimationCheckpoint) {
        pendingAnimationCheckpoint = checkpoint
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.adapter.isActiveOutputReplayConsumer(
                self.outputReplayConsumer
            ) else { return }
            guard self.pendingAnimationCheckpoint?.outputSequence == checkpoint.outputSequence else {
                return
            }
            self.replaceContent(
                with: checkpoint.finalContent,
                preservesCurrentStyle: checkpoint.preservesCurrentStyle
            )
            self.isHidden = Self.shouldHide(checkpoint.finalContent)
            self.pendingAnimationCompletion = nil
            self.pendingAnimationCheckpoint = nil
            self.persistReplayCheckpoint()
            checkpoint.completion?()
        }
        pendingAnimationCompletion = work
        DispatchQueue.main.asyncAfter(
            deadline: .now() + max(checkpoint.deadline.timeIntervalSinceNow, 0),
            execute: work
        )
        persistReplayCheckpoint()
    }

    private func apply(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        if !isHidden, self.isHidden {
            resumePendingAnimationRendering()
        }
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    private func resumePendingAnimationRendering(at date: Date = Date()) {
        guard let checkpoint = pendingAnimationCheckpoint else { return }
        animationRenderGeneration &+= 1
        replaceContent(
            with: checkpoint.timeline.resumedContent(
                startedAt: checkpoint.startedAt,
                deadline: checkpoint.deadline,
                date: date,
                finalContent: checkpoint.finalContent
            ),
            preservesCurrentStyle: checkpoint.preservesCurrentStyle
        )
    }

    private func replaceContent(
        with replacement: TextOutputPresentableModel.TextModel,
        preservesCurrentStyle: Bool
    ) {
        let current = presentable
        let updatedModel: TextOutputPresentableModel.TextModel

        if !preservesCurrentStyle || replacement.isTextStyled {
            updatedModel = replacement
        } else if case let .some(.textStyled(
            _,
            cornerStyle,
            insets,
            height,
            backgroundColor
        )) = current.model {
            updatedModel = .textStyled(
                text: replacement,
                cornerStyle: cornerStyle,
                insets: insets,
                height: height,
                backgroundColor: backgroundColor
            )
        } else {
            updatedModel = replacement
        }

        presentable = .init(
            accessibilityIdentifier: current.accessibilityIdentifier,
            accessibility: current.accessibility,
            model: updatedModel
        )
        persistReplayCheckpoint()
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            presentable: presentable,
            isHidden: isHidden,
            pendingAnimation: pendingAnimationCheckpoint,
            latestAccessibilityOutputSequence: latestAccessibilityOutputSequence,
            latestContentOutputSequence: latestContentOutputSequence,
            latestVisibilityOutputSequence: latestVisibilityOutputSequence
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        presentable = checkpoint.presentable
        isHidden = checkpoint.isHidden
        latestAccessibilityOutputSequence = checkpoint.latestAccessibilityOutputSequence
        latestContentOutputSequence = checkpoint.latestContentOutputSequence
        latestVisibilityOutputSequence = checkpoint.latestVisibilityOutputSequence
        if let pendingAnimation = checkpoint.pendingAnimation {
            pendingAnimationCheckpoint = pendingAnimation
            resumePendingAnimationRendering()
            schedulePendingAnimation(pendingAnimation)
        }
    }

    private struct AnimationPlan {
        let initialContent: TextOutputPresentableModel.TextModel
        let finalContent: TextOutputPresentableModel.TextModel
        let timeline: AnimationTimeline
        let duration: TimeInterval
        let completion: (() -> Void)?
    }

    private enum AnimationTimeline {
        case decimal(
            id: String?,
            from: Decimal,
            to: Decimal,
            mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
            animationStyle: LabelAnimationStyle
        )
        case double(
            id: String?,
            from: Double,
            to: Double,
            mapToString: ((Double) -> TextOutputPresentableModel.TextModel)?,
            animationStyle: LabelAnimationStyle
        )

        func resumedContent(
            startedAt: Date,
            deadline: Date,
            date: Date,
            finalContent: TextOutputPresentableModel.TextModel
        ) -> TextOutputPresentableModel.TextModel {
            let totalDuration = max(deadline.timeIntervalSince(startedAt), 0)
            let remainingDuration = max(deadline.timeIntervalSince(date), 0)
            guard remainingDuration > 0, totalDuration > 0 else { return finalContent }

            let elapsed = min(max(date.timeIntervalSince(startedAt), 0), totalDuration)
            let progress = min(max(elapsed / totalDuration, 0), 1)

            switch self {
            case let .decimal(id, from, to, mapToString, animationStyle):
                let current = from + Decimal(progress) * (to - from)
                return .animatedDecimal(
                    id: id,
                    from: current,
                    to: to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: remainingDuration,
                    completion: nil
                )
            case let .double(id, from, to, mapToString, animationStyle):
                let current = from + progress * (to - from)
                return .animated(
                    id: id,
                    current,
                    to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: remainingDuration,
                    completion: nil
                )
            }
        }
    }

    private static func animationPlan(
        for content: TextOutputPresentableModel.TextModel
    ) -> AnimationPlan? {
        switch content {
        case let .animatedDecimal(
            id,
            from,
            to,
            mapToString,
            animationStyle,
            duration,
            completion
        ):
            return AnimationPlan(
                initialContent: .animatedDecimal(
                    id: id,
                    from: from,
                    to: to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: duration,
                    completion: nil
                ),
                finalContent: .animatedDecimal(
                    id: id,
                    from: to,
                    to: to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: 0,
                    completion: nil
                ),
                timeline: .decimal(
                    id: id,
                    from: from,
                    to: to,
                    mapToString: mapToString,
                    animationStyle: animationStyle
                ),
                duration: duration,
                completion: completion
            )
        case let .animated(
            id,
            from,
            to,
            mapToString,
            animationStyle,
            duration,
            completion
        ):
            return AnimationPlan(
                initialContent: .animated(
                    id: id,
                    from,
                    to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: duration,
                    completion: nil
                ),
                finalContent: .animated(
                    id: id,
                    to,
                    to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: 0,
                    completion: nil
                ),
                timeline: .double(
                    id: id,
                    from: from,
                    to: to,
                    mapToString: mapToString,
                    animationStyle: animationStyle
                ),
                duration: duration,
                completion: completion
            )
        case let .textStyled(
            text,
            cornerStyle,
            insets,
            height,
            backgroundColor
        ):
            guard let nested = animationPlan(for: text) else { return nil }
            return AnimationPlan(
                initialContent: .textStyled(
                    text: nested.initialContent,
                    cornerStyle: cornerStyle,
                    insets: insets,
                    height: height,
                    backgroundColor: backgroundColor
                ),
                // UIKit's running animation updates only the label text. If another
                // styled value arrives before completion, that newer style stays in
                // place when the old animation writes its final text.
                finalContent: nested.finalContent,
                timeline: nested.timeline,
                duration: nested.duration,
                completion: nested.completion
            )
        case .text, .attributes, .attributedString:
            return nil
        }
    }

    private static func shouldHide(_ model: TextOutputPresentableModel.TextModel?) -> Bool {
        guard let model else { return true }

        switch model {
        case .text(let text):
            let normalized = text?.removingPercentEncoding ?? text ?? ""
            return normalized.isEmpty
        case .attributes(let attributes):
            return attributes.isEmpty
        case .attributedString(let htmlString, _):
            return htmlString?.isEmpty ?? true
        case .animatedDecimal, .animated:
            return false
        case .textStyled(let text, _, _, _, _):
            return shouldHide(text)
        }
    }
}

private extension TextOutputPresentableModel.TextModel {
    var isTextStyled: Bool {
        if case .textStyled = self {
            return true
        }
        return false
    }
}

#endif
