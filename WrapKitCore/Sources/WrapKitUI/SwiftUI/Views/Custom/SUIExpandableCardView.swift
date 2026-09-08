import Foundation

#if canImport(SwiftUI)
import SwiftUI
import Combine

public struct SUIExpandableCardView: View {
    @StateObject private var stateModel: SUIExpandableCardViewStateModel
    private let stackSpacing: CGFloat
    private let primeCardHeight: CGFloat?
    private let secondaryCardHeight: CGFloat?

    public init(adapter: ExpandableCardViewOutputSwiftUIAdapter) {
        self.init(
            adapter: adapter,
            stackSpacing: 0,
            primeCardHeight: nil,
            secondaryCardHeight: nil
        )
    }

    public init(
        adapter: ExpandableCardViewOutputSwiftUIAdapter,
        stackSpacing: CGFloat,
        primeCardHeight: CGFloat?,
        secondaryCardHeight: CGFloat?
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.stackSpacing = stackSpacing
        self.primeCardHeight = primeCardHeight
        self.secondaryCardHeight = secondaryCardHeight
    }

    public var body: some View {
        if !stateModel.isHidden {
            VStack(spacing: stackSpacing) {
                cardView(
                    model: stateModel.primeModel,
                    adapter: stateModel.primeCardAdapter,
                    height: primeCardHeight
                )

                if stateModel.secondaryModel != nil {
                    cardView(
                        model: stateModel.secondaryModel,
                        adapter: stateModel.secondaryCardAdapter,
                        height: secondaryCardHeight
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private func cardView(
        model: CardViewPresentableModel?,
        adapter: CardViewOutputSwiftUIAdapter,
        height: CGFloat?
    ) -> some View {
        if model != nil {
            let card = SUICardView(adapter: adapter)
            if let height {
                card
                    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .top)
            } else {
                card
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}

final class SUIExpandableCardViewStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let primeModel: CardViewPresentableModel?
        let secondaryModel: CardViewPresentableModel?
        let isHidden: Bool
        let primeCardAdapter: CardViewOutputSwiftUIAdapter
        let secondaryCardAdapter: CardViewOutputSwiftUIAdapter
        let latestModelOutputSequence: UInt64
        let latestVisibilityOutputSequence: UInt64
    }

    @Published var primeModel: CardViewPresentableModel?
    @Published var secondaryModel: CardViewPresentableModel?
    @Published var isHidden: Bool = false

    let primeCardAdapter: CardViewOutputSwiftUIAdapter
    let secondaryCardAdapter: CardViewOutputSwiftUIAdapter

    private let adapter: ExpandableCardViewOutputSwiftUIAdapter
    private var outputReplayConsumer: ExpandableCardViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestModelOutputSequence: UInt64 = 0
    private var latestVisibilityOutputSequence: UInt64 = 0

    init(adapter: ExpandableCardViewOutputSwiftUIAdapter) {
        self.adapter = adapter
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(
            consumer: outputReplayConsumer
        )
        primeCardAdapter = outputReplayCheckpoint?.primeCardAdapter
            ?? CardViewOutputSwiftUIAdapter()
        secondaryCardAdapter = outputReplayCheckpoint?.secondaryCardAdapter
            ?? CardViewOutputSwiftUIAdapter()

        adapter.outputReplayPublisher(
            adapter.$displayModelState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                apply(
                    model: state.model,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayIsHiddenState,
            consumer: outputReplayConsumer
        )
            .sink { [weak self] state in
                guard let self, let state else { return }
                apply(
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

    private func apply(
        model: Pair<CardViewPresentableModel, CardViewPresentableModel?>,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestModelOutputSequence else { return }
        latestModelOutputSequence = outputSequence

        primeModel = model.first
        secondaryModel = model.second

        primeCardAdapter.display(model: model.first)
        secondaryCardAdapter.display(model: model.second)
        persistReplayCheckpoint()
    }

    private func apply(isHidden: Bool, outputSequence: UInt64) {
        guard outputSequence >= latestVisibilityOutputSequence else { return }
        latestVisibilityOutputSequence = outputSequence
        self.isHidden = isHidden
        persistReplayCheckpoint()
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(
            consumer: outputReplayConsumer,
            OutputReplayCheckpoint(
                primeModel: primeModel,
                secondaryModel: secondaryModel,
                isHidden: isHidden,
                primeCardAdapter: primeCardAdapter,
                secondaryCardAdapter: secondaryCardAdapter,
                latestModelOutputSequence: latestModelOutputSequence,
                latestVisibilityOutputSequence: latestVisibilityOutputSequence
            )
        )
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        primeModel = checkpoint.primeModel
        secondaryModel = checkpoint.secondaryModel
        isHidden = checkpoint.isHidden
        latestModelOutputSequence = checkpoint.latestModelOutputSequence
        latestVisibilityOutputSequence = checkpoint.latestVisibilityOutputSequence
    }
}

#endif
