//
//  SUIProgressBarStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import Combine
import Foundation

public final class SUIProgressBarStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let isHidden: Bool
        let progress: CGFloat
        let style: ProgressBarStyle?
        let layoutHeight: CGFloat
        let animatesProgressChanges: Bool
    }

    @Published var isHidden: Bool = false
    @Published var progress: CGFloat = 0
    @Published var style: ProgressBarStyle? = nil
    @Published var layoutHeight: CGFloat = 4
    @Published var animatesProgressChanges = false

    private let adapter: ProgressBarOutputSwiftUIAdapter

    private var outputReplayConsumer: ProgressBarOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestProgressOutputSequence: UInt64 = 0
    private var latestStyleOutputSequence: UInt64 = 0
    
    public init(adapter: ProgressBarOutputSwiftUIAdapter) {
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
                    isHidden: value.model == nil,
                    outputSequence: value.outputSequence
                )
                guard let model = value.model else { return }
                self?.apply(
                    progress: model.progress,
                    animated: false,
                    outputSequence: value.outputSequence
                )
                if let style = model.style {
                    self?.apply(
                        style: style,
                        outputSequence: value.outputSequence
                    )
                }
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayProgressState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    progress: value.progress,
                    animated: true,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayStyleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.apply(
                    style: value.style,
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

    private func apply(
        isHidden: Bool,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    private func apply(
        progress: CGFloat,
        animated: Bool,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestProgressOutputSequence else { return }
        latestProgressOutputSequence = outputSequence
        animatesProgressChanges = animated
        self.progress = progress
        persistReplayCheckpoint()
    }

    private func apply(
        style: ProgressBarStyle?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestStyleOutputSequence else { return }
        latestStyleOutputSequence = outputSequence
        self.style = style
        if let height = style?.height {
            layoutHeight = height
        }
        persistReplayCheckpoint()
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            isHidden: isHidden,
            progress: progress,
            style: style,
            layoutHeight: layoutHeight,
            animatesProgressChanges: animatesProgressChanges
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isHidden = checkpoint.isHidden
        progress = checkpoint.progress
        style = checkpoint.style
        layoutHeight = checkpoint.layoutHeight
        animatesProgressChanges = checkpoint.animatesProgressChanges
    }
}
