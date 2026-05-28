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

    private let adapter: DatePickerViewOutputSwiftUIAdapter
    private var cancellables: Set<AnyCancellable> = []

    public init(adapter: DatePickerViewOutputSwiftUIAdapter) {
        self.adapter = adapter

        adapter.$displayModelState
            .compactMap { $0 }
            .sink { [weak self] value in
                guard let self else { return }
                self.date = value.model.value
                self.minimumDate = value.model.minimumDate
                self.maximumDate = value.model.maximumDate
                self.mode = value.model.mode
                self.dateChanged = value.model.dateChanged
            }
            .store(in: &cancellables)

        adapter.$displayDateState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.date = value.date
            }
            .store(in: &cancellables)

        adapter.$displaySetDateAnimatedState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.date = value.setDate
            }
            .store(in: &cancellables)

        adapter.$displayDateChangedState
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.dateChanged = value.dateChanged
            }
            .store(in: &cancellables)
    }
}
