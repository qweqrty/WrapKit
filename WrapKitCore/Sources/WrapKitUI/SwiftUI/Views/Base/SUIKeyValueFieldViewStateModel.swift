//
//  SUIKeyValueFieldViewStateModel.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import Combine

final class SUIKeyValueFieldViewStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let keyTitle: TextOutputPresentableModel?
        let valueTitle: TextOutputPresentableModel?
        let bottomImage: ImageViewPresentableModel?
        let isHidden: Bool
        let isKeySlotHidden: Bool
        let isValueSlotHidden: Bool
        let isBottomImageSlotHidden: Bool
        let keyTitleAdapter: TextOutputSwiftUIAdapter
        let valueTitleAdapter: TextOutputSwiftUIAdapter
        let bottomImageAdapter: ImageViewOutputSwiftUIAdapter
    }

    @Published var keyTitle: TextOutputPresentableModel?
    @Published var valueTitle: TextOutputPresentableModel?
    @Published var bottomImage: ImageViewPresentableModel?
    @Published var isHidden: Bool
    @Published private(set) var isKeySlotHidden = false
    @Published private(set) var isValueSlotHidden = false
    @Published private(set) var isBottomImageSlotHidden = true

    let keyTitleStateModel: SUILabelStateModel
    let valueTitleStateModel: SUILabelStateModel
    let bottomImageAdapter: ImageViewOutputSwiftUIAdapter

    private let displaysBottomImage: Bool
    private let adapter: KeyValueFieldViewOutputSwiftUIAdapter
    private let keyTitleAdapter: TextOutputSwiftUIAdapter
    private let valueTitleAdapter: TextOutputSwiftUIAdapter
    private var outputReplayConsumer: KeyValueFieldViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestKeyTitleOutputSequence: UInt64 = 0
    private var latestValueTitleOutputSequence: UInt64 = 0
    private var latestBottomImageOutputSequence: UInt64 = 0

    init(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter,
        displaysBottomImage: Bool,
        isHidden: Bool
    ) {
        self.adapter = adapter
        self.displaysBottomImage = displaysBottomImage
        self.isHidden = isHidden
        let outputReplayConsumer = adapter.claimOutputReplayConsumer()
        self.outputReplayConsumer = outputReplayConsumer
        let outputReplayCheckpoint = adapter.outputReplayCheckpoint(
            as: OutputReplayCheckpoint.self,
            consumer: outputReplayConsumer
        )
        let bufferedOutputReplayPublisher = adapter.bufferedOutputReplayPublisher(consumer: outputReplayConsumer)
        keyTitleAdapter = outputReplayCheckpoint?.keyTitleAdapter
            ?? TextOutputSwiftUIAdapter()
        valueTitleAdapter = outputReplayCheckpoint?.valueTitleAdapter
            ?? TextOutputSwiftUIAdapter()
        bottomImageAdapter = outputReplayCheckpoint?.bottomImageAdapter
            ?? ImageViewOutputSwiftUIAdapter()
        keyTitleStateModel = SUILabelStateModel(adapter: keyTitleAdapter)
        valueTitleStateModel = SUILabelStateModel(adapter: valueTitleAdapter)

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
            adapter.$displayKeyTitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    keyTitle: state.keyTitle,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayValueTitleState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    valueTitle: state.valueTitle,
                    outputSequence: state.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayBottomImageState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.display(
                    bottomImage: state.bottomImage,
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

private extension SUIKeyValueFieldViewStateModel {
    func display(
        model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?,
        outputSequence: UInt64
    ) {
        display(
            keyTitle: model?.first,
            outputSequence: outputSequence
        )
        display(
            valueTitle: model?.second,
            outputSequence: outputSequence
        )
    }

    func display(
        keyTitle: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestKeyTitleOutputSequence else { return }
        latestKeyTitleOutputSequence = outputSequence
        self.keyTitle = keyTitle
        isKeySlotHidden = keyTitle == nil
        keyTitleAdapter.display(model: keyTitle)
        updateVisibility()
    }

    func display(
        valueTitle: TextOutputPresentableModel?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestValueTitleOutputSequence else { return }
        latestValueTitleOutputSequence = outputSequence
        self.valueTitle = valueTitle
        isValueSlotHidden = valueTitle == nil
        valueTitleAdapter.display(model: valueTitle)
        updateVisibility()
    }

    func display(
        bottomImage: ImageViewPresentableModel?,
        outputSequence: UInt64
    ) {
        guard displaysBottomImage else { return }
        guard outputSequence >= latestBottomImageOutputSequence else { return }
        latestBottomImageOutputSequence = outputSequence

        self.bottomImage = bottomImage
        isBottomImageSlotHidden = bottomImage == nil
        bottomImageAdapter.display(model: bottomImage)
        updateVisibility()
    }

    func updateVisibility() {
        let bottomSlotIsHidden = !displaysBottomImage || isBottomImageSlotHidden
        isHidden = isKeySlotHidden && isValueSlotHidden && bottomSlotIsHidden
        persistReplayCheckpoint()
    }

    func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            keyTitle: keyTitle,
            valueTitle: valueTitle,
            bottomImage: bottomImage,
            isHidden: isHidden,
            isKeySlotHidden: isKeySlotHidden,
            isValueSlotHidden: isValueSlotHidden,
            isBottomImageSlotHidden: isBottomImageSlotHidden,
            keyTitleAdapter: keyTitleAdapter,
            valueTitleAdapter: valueTitleAdapter,
            bottomImageAdapter: bottomImageAdapter
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        keyTitle = checkpoint.keyTitle
        valueTitle = checkpoint.valueTitle
        bottomImage = displaysBottomImage ? checkpoint.bottomImage : nil
        isHidden = checkpoint.isHidden
        isKeySlotHidden = checkpoint.isKeySlotHidden
        isValueSlotHidden = checkpoint.isValueSlotHidden
        isBottomImageSlotHidden = displaysBottomImage
            ? checkpoint.isBottomImageSlotHidden
            : true
        updateVisibility()
    }
}

#endif
