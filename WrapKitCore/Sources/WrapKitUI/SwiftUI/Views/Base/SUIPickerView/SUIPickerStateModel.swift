//
//  SUIPickerStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 30/4/26.
//

import Combine
import SwiftUI

public final class SUIPickerStateModel: ObservableObject {
    private struct OutputReplayCheckpoint {
        let isHidden: Bool
        let selectedRows: [Int: Int]
        let componentsCount: Int
        let rows: [String]
        let accessibilityIdentifier: String?
    }

    @Published var isHidden: Bool = false
    @Published var selectedRows: [Int: Int] = [:] {
        didSet { persistReplayCheckpoint() }
    }
    @Published var componentsCount: Int = 0
    @Published var rows: [String] = []
    @Published var accessibilityIdentifier: String?

    @Published var didSelectAt: ((Int) -> Void)? = nil

    private let adapter: PickerViewOutputSwiftUIAdapter

    private var outputReplayConsumer: PickerViewOutputSwiftUIAdapter.OutputReplayConsumer?
    private var rowsCountProvider: (() -> Int)?
    private var titleProvider: ((Int) -> String?)?
    private var cancellables: Set<AnyCancellable> = []
    private var latestSelectedRowOutputSequence: UInt64 = 0

    public init(adapter: PickerViewOutputSwiftUIAdapter) {
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
                defer { self.persistReplayCheckpoint() }
                self.isHidden = value.model == nil
                guard let model = value.model else {
                    self.latestSelectedRowOutputSequence = max(
                        self.latestSelectedRowOutputSequence,
                        value.outputSequence
                    )
                    self.componentsCount = 0
                    self.rows = []
                    self.selectedRows = [:]
                    self.rowsCountProvider = nil
                    self.titleProvider = nil
                    self.didSelectAt = nil
                    self.accessibilityIdentifier = nil
                    return
                }
                self.didSelectAt = model.didSelectAt
                self.rowsCountProvider = model.rowsCount
                self.titleProvider = model.titleForRowAt
                self.componentsCount = max(model.componentsCount?() ?? 0, 0)
                self.accessibilityIdentifier = model.accessibilityIdentifier
                self.reloadRows()
                if let selectedRow = model.selectedRow {
                    self.apply(
                        selectedRow: selectedRow,
                        outputSequence: value.outputSequence
                    )
                }
            }
            .store(in: &cancellables)

        adapter.outputReplayPublisher(
            adapter.$displaySelectedRowState,
            consumer: outputReplayConsumer
        )
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, let row = value.selectedRow else { return }
                self.apply(
                    selectedRow: row,
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

        componentsCount = max(adapter.componentsCount?() ?? 0, 0)
        rowsCountProvider = adapter.rowsCount
        titleProvider = adapter.titleForRowAt
        didSelectAt = adapter.didSelectAt
        reloadRows()

        adapter.activeOutputReplayPublisher(
            adapter.$componentsCount,
            consumer: outputReplayConsumer,
            dropFirst: true
        )
            .sink { [weak self] value in
                guard let self else { return }
                self.componentsCount = max(value?() ?? 0, 0)
                self.normalizeSelectedRows()
                self.persistReplayCheckpoint()
            }
            .store(in: &cancellables)

        adapter.activeOutputReplayPublisher(
            adapter.$rowsCount,
            consumer: outputReplayConsumer,
            dropFirst: true
        )
            .sink { [weak self] value in
                self?.rowsCountProvider = value
                self?.reloadRows()
            }
            .store(in: &cancellables)

        adapter.activeOutputReplayPublisher(
            adapter.$titleForRowAt,
            consumer: outputReplayConsumer,
            dropFirst: true
        )
            .sink { [weak self] value in
                self?.titleProvider = value
                self?.reloadRows()
            }
            .store(in: &cancellables)

        adapter.activeOutputReplayPublisher(
            adapter.$didSelectAt,
            consumer: outputReplayConsumer,
            dropFirst: true
        )
            .sink { [weak self] value in
                self?.didSelectAt = value
                self?.persistReplayCheckpoint()
            }
            .store(in: &cancellables)

        persistReplayCheckpoint()
    }

    private func reloadRows() {
        let count = max(rowsCountProvider?() ?? 0, 0)
        rows = (0..<count).map { titleProvider?($0) ?? "" }
        normalizeSelectedRows()
        persistReplayCheckpoint()
    }

    private func normalizeSelectedRows() {
        guard componentsCount > 0, !rows.isEmpty else {
            selectedRows = [:]
            persistReplayCheckpoint()
            return
        }

        let lastRow = rows.count - 1
        selectedRows = selectedRows.reduce(into: [:]) { result, selection in
            let (component, row) = selection
            guard component >= 0, component < componentsCount else { return }
            result[component] = min(max(row, 0), lastRow)
        }
        persistReplayCheckpoint()
    }

    private func apply(
        selectedRow: PickerViewPresentableModel.SelectedRow,
        outputSequence: UInt64
    ) {
        guard selectedRow.component >= 0,
              selectedRow.component < componentsCount,
              selectedRow.row >= 0,
              selectedRow.row < rows.count
        else { return }
        guard outputSequence >= latestSelectedRowOutputSequence else { return }
        latestSelectedRowOutputSequence = outputSequence

        if selectedRow.animated {
            withAnimation {
                selectedRows[selectedRow.component] = selectedRow.row
            }
        } else {
            selectedRows[selectedRow.component] = selectedRow.row
        }
        selectedRow.selectedRowCompletion?(selectedRows[selectedRow.component] ?? selectedRow.row)
        persistReplayCheckpoint()
    }

    private func persistReplayCheckpoint() {
        adapter.updateOutputReplayCheckpoint(consumer: outputReplayConsumer, OutputReplayCheckpoint(
            isHidden: isHidden,
            selectedRows: selectedRows,
            componentsCount: componentsCount,
            rows: rows,
            accessibilityIdentifier: accessibilityIdentifier
        ))
    }

    private func restore(_ checkpoint: OutputReplayCheckpoint) {
        isHidden = checkpoint.isHidden
        selectedRows = checkpoint.selectedRows
        componentsCount = checkpoint.componentsCount
        rows = checkpoint.rows
        accessibilityIdentifier = checkpoint.accessibilityIdentifier
    }
}
