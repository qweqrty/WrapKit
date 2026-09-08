//
//  SUIDatePickerStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 27/4/26.
//

import Combine
import Foundation

public final class SUIDatePickerStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let date: Date
        let minimumDate: Date?
        let maximumDate: Date?
        let mode: DatePickerMode
        let dateChanged: ((Date) -> Void)?
    }

    @Published var date: Date = Date()
    @Published var minimumDate: Date? = nil
    @Published var maximumDate: Date? = nil
    @Published var mode: DatePickerMode = .date
    @Published var dateChanged: ((Date) -> Void)? = nil
    @Published var setDateAnimated: Bool = false

    private let adapter: DatePickerViewOutputSwiftUIAdapter

    private var outputReplayConsumer: DatePickerViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var cancellables: Set<AnyCancellable> = []
    private var latestDateOutputSequence: UInt64 = 0
    private var latestDateChangedOutputSequence: UInt64 = 0

    public init(adapter: DatePickerViewOutputSwiftUIAdapter) {
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
                self.applyDate(
                    value.model.value,
                    animated: false,
                    outputSequence: value.outputSequence
                )
                self.minimumDate = value.model.minimumDate
                self.maximumDate = value.model.maximumDate
                self.mode = value.model.mode
                self.applyDateChanged(
                    value.model.dateChanged,
                    outputSequence: value.outputSequence
                )
                self.persistReplayCheckpoint()
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayDateState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyDate(
                    value.date,
                    animated: false,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySetDateAnimatedState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyDate(
                    value.setDate,
                    animated: value.animated,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displayDateChangedState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyDateChanged(
                    value.dateChanged,
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

    private func applyDate(
        _ date: Date,
        animated: Bool,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestDateOutputSequence else { return }
        latestDateOutputSequence = outputSequence
        setDateAnimated = animated
        self.date = date
        persistReplayCheckpoint()
    }

    private func applyDateChanged(
        _ dateChanged: ((Date) -> Void)?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestDateChangedOutputSequence else { return }
        latestDateChangedOutputSequence = outputSequence
        self.dateChanged = dateChanged
        persistReplayCheckpoint()
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            date: date,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            mode: mode,
            dateChanged: dateChanged
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        date = checkpoint.date
        minimumDate = checkpoint.minimumDate
        maximumDate = checkpoint.maximumDate
        mode = checkpoint.mode
        dateChanged = checkpoint.dateChanged
        setDateAnimated = false
    }
}
