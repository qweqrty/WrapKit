//
//  SUIPickerStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 30/4/26.
//

import Combine

public final class SUIPickerStateModel: ObservableObject {
    @Published var isHidden: Bool = false
    @Published var selectedRow: Int = 0
    @Published var rows: [String] = []

    var didSelectAt: ((Int) -> Void)? = nil

    private let adapter: PickerViewOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: PickerViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.isHidden = value.model == nil
                guard let model = value.model else { return }
                self.didSelectAt = model.didSelectAt
                self.reloadRows(from: model)
                if let selectedRow = model.selectedRow {
                    self.selectedRow = selectedRow.row
                }
            }
            .store(in: &cancellables)

        adapter.$displaySelectedRowState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let row = value.selectedRow else { return }
                self?.selectedRow = row.row
            }
            .store(in: &cancellables)
    }

    private func reloadRows(from model: PickerViewPresentableModel) {
        let count = model.rowsCount?() ?? 0
        rows = (0..<count).compactMap { model.titleForRowAt?($0) }
        didSelectAt = model.didSelectAt
    }
}
