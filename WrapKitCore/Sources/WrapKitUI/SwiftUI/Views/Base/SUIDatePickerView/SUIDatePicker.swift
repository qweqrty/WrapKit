//
//  SUIDatePicker.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 27/4/26.
//

import SwiftUI

public struct SUIDatePicker: View {
    @ObservedObject var stateModel: SUIDatePickerStateModel

    public init(adapter: DatePickerViewOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }

    public var body: some View {
        SUIDatePickerView(
            date: stateModel.date,
            minimumDate: stateModel.minimumDate,
            maximumDate: stateModel.maximumDate,
            mode: stateModel.mode,
            dateChanged: stateModel.dateChanged
        )
    }
}

public struct SUIDatePickerView: View {
    let minimumDate: Date?
    let maximumDate: Date?
    let mode: DatePickerMode
    let dateChanged: ((Date) -> Void)?

    @State private var internalDate: Date

    public init(
        date: Date = Date(),
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        mode: DatePickerMode = .date,
        dateChanged: ((Date) -> Void)? = nil
    ) {
        self._internalDate = State(initialValue: date)
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.mode = mode
        self.dateChanged = dateChanged
    }

    public var body: some View {
        DatePicker(
            "",
            selection: Binding(
                get: { internalDate },
                set: { newDate in
                    internalDate = newDate
                    dateChanged?(newDate)
                }
            ),
            in: dateRange,
            displayedComponents: displayedComponents
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .onChange(of: internalDate) { _ in }
    }

    private var dateRange: ClosedRange<Date> {
        let min = minimumDate ?? Date.distantPast
        let max = maximumDate ?? Date.distantFuture
        return min...max
    }

    private var displayedComponents: DatePickerComponents {
        switch mode {
        case .time:
            return .hourAndMinute
        case .date:
            return .date
        case .dateAndTime:
            return [.date, .hourAndMinute]
        case .countDownTimer:
            return .hourAndMinute
        }
    }
}

#Preview {
    SUIDatePickerView(
        date: Date(),
        minimumDate: nil,
        maximumDate: nil,
        mode: .date,
        dateChanged: { print($0) }
    )
}
