//
//  SUIDatePicker.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 27/4/26.
//

import SwiftUI

public struct SUIDatePicker: View {
    @StateObject var stateModel: SUIDatePickerStateModel

    public init(adapter: DatePickerViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        SUIDatePickerView(
            date: stateModel.date,
            minimumDate: stateModel.minimumDate,
            maximumDate: stateModel.maximumDate,
            mode: stateModel.mode,
            setDateAnimated: stateModel.setDateAnimated,
            dateChanged: stateModel.dateChanged
        )
    }
}

public struct SUIDatePickerView: View {
    let date: Date
    let minimumDate: Date?
    let maximumDate: Date?
    let mode: DatePickerMode
    let setDateAnimated: Bool
    let dateChanged: ((Date) -> Void)?

    @State private var internalDate: Date

    public init(
        date: Date = Date(),
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        mode: DatePickerMode = .date,
        setDateAnimated: Bool = false,
        dateChanged: ((Date) -> Void)? = nil
    ) {
        self.date = date
        self._internalDate = State(initialValue: date)
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.mode = mode
        self.setDateAnimated = setDateAnimated
        self.dateChanged = dateChanged
    }

    public var body: some View {
        pickerContent
            .onChange(of: date) { newDate in
                updateInternalDate(newDate)
            }
    }

    @ViewBuilder
    private var pickerContent: some View {
#if os(iOS)
        if mode == .countDownTimer {
            SUIDatePickerCountDownView(
                date: $internalDate,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                setDateAnimated: setDateAnimated,
                dateChanged: dateChanged
            )
        } else {
            swiftUIDatePicker
        }
#else
        swiftUIDatePicker
#endif
    }

    private var swiftUIDatePicker: some View {
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
    }

    private func updateInternalDate(_ newDate: Date) {
        guard internalDate != newDate else { return }
        if setDateAnimated {
            withAnimation {
                internalDate = newDate
            }
        } else {
            internalDate = newDate
        }
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
            // SwiftUI has no countdown-timer DatePicker mode. iOS uses the
            // UIKit-backed branch above; other platforms retain a usable fallback.
            return .hourAndMinute
        }
    }
}

#if os(iOS)
import UIKit

struct SUIDatePickerCountDownView: UIViewRepresentable {
    @Binding var date: Date
    let minimumDate: Date?
    let maximumDate: Date?
    let setDateAnimated: Bool
    let dateChanged: ((Date) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker(frame: .zero)
        picker.datePickerMode = .countDownTimer
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateDidChange(_:)),
            for: .valueChanged
        )
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: Context) {
        context.coordinator.parent = self
        picker.minimumDate = minimumDate
        picker.maximumDate = maximumDate
        guard picker.date != date else { return }
        picker.setDate(date, animated: setDateAnimated)
    }

    final class Coordinator: NSObject {
        var parent: SUIDatePickerCountDownView

        init(parent: SUIDatePickerCountDownView) {
            self.parent = parent
        }

        @objc func dateDidChange(_ picker: UIDatePicker) {
            parent.date = picker.date
            parent.dateChanged?(picker.date)
        }
    }
}
#endif

#Preview {
    SUIDatePickerView(
        date: Date(),
        minimumDate: nil,
        maximumDate: nil,
        mode: .date,
        dateChanged: { print($0) }
    )
}
