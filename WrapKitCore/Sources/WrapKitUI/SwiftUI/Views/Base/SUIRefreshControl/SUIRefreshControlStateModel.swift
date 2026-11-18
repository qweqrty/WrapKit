//
//  SUIRefreshControlStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 23/4/26.
//

import Combine
import Foundation

public final class SUIRefreshControlStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let isLoading: Bool
        let tintColor: Color?
        let zPosition: CGFloat
    }

    @Published var isLoading: Bool = false {
        didSet {
            if !isLoading {
                isAwaitingRefreshOutput = false
            }
        }
    }
    @Published var tintColor: Color? = nil
    @Published var zPosition: CGFloat = -1
    var onRefreshCallbacks: [(() -> Void)?] {
        adapter.refreshCallbacks(consumer: outputReplayConsumer)
    }

    private let adapter: RefreshControlOutputSwiftUIAdapter
    private var isAwaitingRefreshOutput = false

    private var outputReplayConsumer: RefreshControlOutputSwiftUIAdapter.OutputReplayConsumer?
    private var latestStyleOutputSequence: UInt64 = 0
    private var cancellables: Set<AnyCancellable> = []
    
    public init(adapter: RefreshControlOutputSwiftUIAdapter) {
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
                guard let self else { return }
                if let style = value.model?.style,
                   value.outputSequence >= self.latestStyleOutputSequence {
                    self.latestStyleOutputSequence = value.outputSequence
                    self.tintColor = style.tintColor
                    self.zPosition = style.zPosition
                }
                if let isLoading = value.model?.isLoading {
                    self.isLoading = isLoading
                }
                self.persistReplayCheckpoint()
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayStyleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self,
                      value.outputSequence >= self.latestStyleOutputSequence else { return }
                self.latestStyleOutputSequence = value.outputSequence
                self.tintColor = value.style.tintColor
                self.zPosition = value.style.zPosition
                self.persistReplayCheckpoint()
            }
            .store(in: &cancellables)
        
        adapter.outputReplayPublisher(
            adapter.$displayIsLoadingState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.isLoading = value.isLoading
                self?.persistReplayCheckpoint()
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

        adapter.activeOutputReplayPublisher(
            adapter.$isLoading,
            consumer: outputReplayConsumer,
            dropFirst: false
        )
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
                self?.persistReplayCheckpoint()
            }
            .store(in: &cancellables)

        persistReplayCheckpoint()
    }
    
    func triggerRefresh() {
        guard adapter.isActiveOutputReplayConsumer(outputReplayConsumer) else { return }
        isAwaitingRefreshOutput = true
        adapter.invokeRefreshCallbacks(consumer: outputReplayConsumer)
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            isLoading: isLoading,
            tintColor: tintColor,
            zPosition: zPosition
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isLoading = checkpoint.isLoading
        tintColor = checkpoint.tintColor
        zPosition = checkpoint.zPosition
    }

    func waitForLoadingToFinish() async {
        while isLoading || isAwaitingRefreshOutput {
            guard !Task.isCancelled else { return }
            do {
                try await Task.sleep(nanoseconds: 100_000_000)
            } catch {
                return
            }
        }
    }
}
