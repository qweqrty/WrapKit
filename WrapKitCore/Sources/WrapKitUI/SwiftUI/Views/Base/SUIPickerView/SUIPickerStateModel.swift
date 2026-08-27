//
//  SUIPickerStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 30/4/26.
//

import Combine

public final class SUIPickerStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var selectedRows: [Int: Int] = [:]
    @Published var componentsCount: Int = 0
    @Published var rows: [String] = []
    @Published var accessibilityIdentifier: String?

    var didSelectAt: ((Int) -> Void)? = nil

    private let adapter: PickerViewOutputSwiftUIAdapter
    private var rowsCountProvider: (() -> Int)?
    private var titleProvider: ((Int) -> String?)?
    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: PickerViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isHidden = value.model == nil
                guard let model = value.model else {
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
                    self.apply(selectedRow: selectedRow)
                }
            }
            .store(in: &cancellables)

        adapter.$displaySelectedRowState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self, let row = value.selectedRow else { return }
                self.apply(selectedRow: row)
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
                self?.componentsCount = max(value?() ?? 0, 0)
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
        let count = rowsCountProvider?() ?? 0
        rows = (0..<count).compactMap { titleProvider?($0) }
    }

    private func apply(selectedRow: PickerViewPresentableModel.SelectedRow) {
        guard selectedRow.component >= 0,
              selectedRow.component < componentsCount,
              selectedRow.row >= 0,
              selectedRow.row < rows.count
        else { return }

        selectedRows[selectedRow.component] = selectedRow.row
        selectedRow.selectedRowCompletion?(selectedRows[selectedRow.component] ?? selectedRow.row)
    }
}
