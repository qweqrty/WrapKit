//
//  SUIPickerStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 30/4/26.
//

import Combine
import SwiftUI

public final class SUIPickerStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var selectedRows: [Int: Int] = [:]
    @Published var componentsCount: Int = 0
    @Published var rows: [String] = []
    @Published var accessibilityIdentifier: String?

    @Published var didSelectAt: ((Int) -> Void)? = nil

    private let adapter: PickerViewOutputSwiftUIAdapter
    private var rowsCountProvider: (() -> Int)?
    private var titleProvider: ((Int) -> String?)?
    private var cancellables: Set<AnyCancellable> = []
    private var latestSelectedRowOutputSequence: UInt64 = 0

    public init(adapter: PickerViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
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

        adapter.$displaySelectedRowState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, let row = value.selectedRow else { return }
                self.apply(
                    selectedRow: row,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        if let directComponentsCount = adapter.componentsCount {
            componentsCount = max(directComponentsCount() ?? 0, 0)
        }
        rowsCountProvider = adapter.rowsCount ?? rowsCountProvider
        titleProvider = adapter.titleForRowAt ?? titleProvider
        didSelectAt = adapter.didSelectAt ?? didSelectAt
        reloadRows()

        adapter.$componentsCount
            .dropFirst()
            .sink { [weak self] value in
                guard let self else { return }
                self.componentsCount = max(value?() ?? 0, 0)
                self.normalizeSelectedRows()
            }
            .store(in: &cancellables)

        adapter.$rowsCount
            .dropFirst()
            .sink { [weak self] value in
                self?.rowsCountProvider = value
                self?.reloadRows()
            }
            .store(in: &cancellables)

        adapter.$titleForRowAt
            .dropFirst()
            .sink { [weak self] value in
                self?.titleProvider = value
                self?.reloadRows()
            }
            .store(in: &cancellables)

        adapter.$didSelectAt
            .dropFirst()
            .sink { [weak self] value in
                self?.didSelectAt = value
            }
            .store(in: &cancellables)
    }

    private func reloadRows() {
        let count = max(rowsCountProvider?() ?? 0, 0)
        rows = (0..<count).map { titleProvider?($0) ?? "" }
        normalizeSelectedRows()
    }

    private func normalizeSelectedRows() {
        guard componentsCount > 0, !rows.isEmpty else {
            selectedRows = [:]
            return
        }

        let lastRow = rows.count - 1
        selectedRows = selectedRows.reduce(into: [:]) { result, selection in
            let (component, row) = selection
            guard component >= 0, component < componentsCount else { return }
            result[component] = min(max(row, 0), lastRow)
        }
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
    }
}
