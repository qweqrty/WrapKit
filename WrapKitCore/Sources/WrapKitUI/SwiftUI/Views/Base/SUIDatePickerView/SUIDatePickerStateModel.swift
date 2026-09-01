//
//  SUIDatePickerStateModel.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 27/4/26.
//

import Combine
import Foundation

public final class SUIDatePickerStateModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var minimumDate: Date? = nil
    @Published var maximumDate: Date? = nil
    @Published var mode: DatePickerMode = .date
    @Published var dateChanged: ((Date) -> Void)? = nil
    @Published var setDateAnimated: Bool = false

    private let adapter: DatePickerViewOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []
    private var latestDateOutputSequence: UInt64 = 0
    private var latestDateChangedOutputSequence: UInt64 = 0

    public init(adapter: DatePickerViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
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
            }
            .store(in: &cancellables)

        adapter.$displayDateState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyDate(
                    value.date,
                    animated: false,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.$displaySetDateAnimatedState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyDate(
                    value.setDate,
                    animated: value.animated,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)

        adapter.$displayDateChangedState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.applyDateChanged(
                    value.dateChanged,
                    outputSequence: value.outputSequence
                )
            }
            .store(in: &cancellables)
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
    }

    private func applyDateChanged(
        _ dateChanged: ((Date) -> Void)?,
        outputSequence: UInt64
    ) {
        guard outputSequence >= latestDateChangedOutputSequence else { return }
        latestDateChangedOutputSequence = outputSequence
        self.dateChanged = dateChanged
    }
}
