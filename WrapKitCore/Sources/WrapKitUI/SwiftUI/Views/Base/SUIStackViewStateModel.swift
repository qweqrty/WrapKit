//
//  SUIStackViewStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

final class SUIStackViewStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let axis: StackViewAxis
        let distribution: StackViewDistribution
        let alignment: StackViewAlignment
        let spacing: CGFloat
        let layoutMargins: EdgeInsets
        let isHidden: Bool
    }

    @Published var axis: StackViewAxis
    @Published var distribution: StackViewDistribution
    @Published var alignment: StackViewAlignment
    @Published var spacing: CGFloat
    @Published var layoutMargins: EdgeInsets
    @Published var isHidden: Bool

    private let adapter: StackViewOutputSwiftUIAdapter

    private var outputReplayConsumer: StackViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestAxisOutputSequence: UInt64 = 0
    private var latestDistributionOutputSequence: UInt64 = 0
    private var latestAlignmentOutputSequence: UInt64 = 0
    private var latestSpacingOutputSequence: UInt64 = 0
    private var latestLayoutMarginsOutputSequence: UInt64 = 0
    private var latestVisibilityOutputSequence: UInt64 = 0

    init(
        adapter: StackViewOutputSwiftUIAdapter,
        axis: StackViewAxis,
        distribution: StackViewDistribution,
        alignment: StackViewAlignment,
        spacing: CGFloat,
        layoutMargins: EdgeInsets,
        isHidden: Bool
    ) {
        self.adapter = adapter
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        self.layoutMargins = layoutMargins
        self.isHidden = isHidden
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
            .sink { [weak self] state in
                self?.display(
                    model: state.model,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySpacingState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    spacing: state.spacing,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayAxisState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    axis: state.axis,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayDistributionState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    distribution: state.distribution,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayAlignmentState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    alignment: state.alignment,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayLayoutMarginsState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    layoutMargins: state.layoutMargins,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    isHidden: state.isHidden,
                    outputSequence: state.outputSequence
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
}

private extension SUIStackViewStateModel {
    func display(
        model: StackViewPresentableModel,
        outputSequence: UInt64
    ) {
        if let axis = model.axis {
            display(axis: axis, outputSequence: outputSequence)
        }
        if let distribution = model.distribution {
            display(distribution: distribution, outputSequence: outputSequence)
        }
        if let alignment = model.alignment {
            display(alignment: alignment, outputSequence: outputSequence)
        }
        if let layoutMargins = model.layoutMargins {
            display(layoutMargins: layoutMargins, outputSequence: outputSequence)
        }
        display(spacing: model.spacing, outputSequence: outputSequence)
    }

    func display(axis: StackViewAxis, outputSequence: UInt64) {
        guard outputSequence >= latestAxisOutputSequence else { return }
        latestAxisOutputSequence = outputSequence
        self.axis = axis
        persistReplayCheckpoint()
    }

    func display(distribution: StackViewDistribution, outputSequence: UInt64) {
        guard outputSequence >= latestDistributionOutputSequence else { return }
        latestDistributionOutputSequence = outputSequence
        self.distribution = distribution
        persistReplayCheckpoint()
    }

    func display(alignment: StackViewAlignment, outputSequence: UInt64) {
        guard outputSequence >= latestAlignmentOutputSequence else { return }
        latestAlignmentOutputSequence = outputSequence
        self.alignment = alignment
        persistReplayCheckpoint()
    }

    func display(spacing: CGFloat?, outputSequence: UInt64) {
        guard let spacing else { return }
        guard outputSequence >= latestSpacingOutputSequence else { return }
        latestSpacingOutputSequence = outputSequence
        self.spacing = spacing
        persistReplayCheckpoint()
    }

    func display(layoutMargins: EdgeInsets, outputSequence: UInt64) {
        guard outputSequence >= latestLayoutMarginsOutputSequence else { return }
        latestLayoutMarginsOutputSequence = outputSequence
        self.layoutMargins = layoutMargins
        persistReplayCheckpoint()
    }

    func display(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            axis: axis,
            distribution: distribution,
            alignment: alignment,
            spacing: spacing,
            layoutMargins: layoutMargins,
            isHidden: isHidden
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        axis = checkpoint.axis
        distribution = checkpoint.distribution
        alignment = checkpoint.alignment
        spacing = checkpoint.spacing
        layoutMargins = checkpoint.layoutMargins
        isHidden = checkpoint.isHidden
    }
}

#endif
