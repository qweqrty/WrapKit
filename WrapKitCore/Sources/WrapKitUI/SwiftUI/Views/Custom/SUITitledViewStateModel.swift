//
//  SUITitledViewStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

final class SUITitledViewStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let isHidden: Bool
        let isUserInteractionEnabled: Bool
        let titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
        let bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
        let titlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
        let bottomTitlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
    }

    @Published var isHidden = false
    @Published var isUserInteractionEnabled = true

    let titlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter
    let bottomTitlesAdapter: KeyValueFieldViewOutputSwiftUIAdapter

    private var titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    private var bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    private let adapter: TitledOutputSwiftUIAdapter
    private var outputReplayConsumer: TitledOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestVisibilityOutputSequence: UInt64 = 0
    private var latestInteractionOutputSequence: UInt64 = 0
    private var latestTitlesOutputSequence: UInt64 = 0
    private var latestLeadingBottomTitleOutputSequence: UInt64 = 0
    private var latestTrailingBottomTitleOutputSequence: UInt64 = 0

    init(adapter: TitledOutputSwiftUIAdapter) {
        self.adapter = adapter
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
        titlesAdapter = outputReplayCheckpoint?.titlesAdapter
            ?? KeyValueFieldViewOutputSwiftUIAdapter()
        bottomTitlesAdapter = outputReplayCheckpoint?.bottomTitlesAdapter
            ?? KeyValueFieldViewOutputSwiftUIAdapter()

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
            adapter.$displayTitlesState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    titles: state.titles,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBottomTitlesState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    bottomTitles: state.bottomTitles,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayLeadingBottomTitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    leadingBottomTitle: state.leadingBottomTitle,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayTrailingBottomTitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    trailingBottomTitle: state.trailingBottomTitle,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsUserInteractionEnabledState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    isUserInteractionEnabled: state.isUserInteractionEnabled,
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

private extension SUITitledViewStateModel {
    func display(
        model: TitledViewPresentableModel?,
        outputSequence: UInt64
    ) {
        display(isHidden: model == nil, outputSequence: outputSequence)
        guard let model else {
            display(titles: nil, outputSequence: outputSequence)
            display(bottomTitles: nil, outputSequence: outputSequence)
            return
        }

        display(titles: model.titles, outputSequence: outputSequence)
        display(bottomTitles: model.bottomTitles, outputSequence: outputSequence)
        display(
            isUserInteractionEnabled: model.isUserInteractionEnabled,
            outputSequence: outputSequence
        )
    }

    func display(
        titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestTitlesOutputSequence else { return }
        latestTitlesOutputSequence = outputSequence
        self.titles = titles
        titlesAdapter.display(model: titles)
        persistReplayCheckpoint()
    }

    func display(
        bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?,
        outputSequence: UInt64
    ) {
        let updatesLeading = outputSequence >= latestLeadingBottomTitleOutputSequence
        let updatesTrailing = outputSequence >= latestTrailingBottomTitleOutputSequence
        guard updatesLeading || updatesTrailing else { return }

        if updatesLeading {
            latestLeadingBottomTitleOutputSequence = outputSequence
        }
        if updatesTrailing {
            latestTrailingBottomTitleOutputSequence = outputSequence
        }

        if updatesLeading, updatesTrailing {
            self.bottomTitles = bottomTitles
        } else {
            self.bottomTitles = .init(
                updatesLeading ? bottomTitles?.first : self.bottomTitles?.first,
                updatesTrailing ? bottomTitles?.second : self.bottomTitles?.second
            )
        }
        bottomTitlesAdapter.display(model: self.bottomTitles)
        persistReplayCheckpoint()
    }

    func display(
        leadingBottomTitle: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestLeadingBottomTitleOutputSequence else { return }
        latestLeadingBottomTitleOutputSequence = outputSequence
        bottomTitles = .init(leadingBottomTitle, bottomTitles?.second)
        bottomTitlesAdapter.display(keyTitle: leadingBottomTitle)
        persistReplayCheckpoint()
    }

    func display(
        trailingBottomTitle: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestTrailingBottomTitleOutputSequence else { return }
        latestTrailingBottomTitleOutputSequence = outputSequence
        bottomTitles = .init(bottomTitles?.first, trailingBottomTitle)
        bottomTitlesAdapter.display(valueTitle: trailingBottomTitle)
        persistReplayCheckpoint()
    }

    func display(isUserInteractionEnabled: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestInteractionOutputSequence else { return }
        latestInteractionOutputSequence = outputSequence
        self.isUserInteractionEnabled = isUserInteractionEnabled
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
            isHidden: isHidden,
            isUserInteractionEnabled: isUserInteractionEnabled,
            titles: titles,
            bottomTitles: bottomTitles,
            titlesAdapter: titlesAdapter,
            bottomTitlesAdapter: bottomTitlesAdapter
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isHidden = checkpoint.isHidden
        isUserInteractionEnabled = checkpoint.isUserInteractionEnabled
        titles = checkpoint.titles
        bottomTitles = checkpoint.bottomTitles
    }
}

#endif
