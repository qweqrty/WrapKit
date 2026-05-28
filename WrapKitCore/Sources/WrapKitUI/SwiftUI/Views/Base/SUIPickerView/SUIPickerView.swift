//
//  SUIPickerView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 30/4/26.
//


import SwiftUI

public struct SUIPickerView: View {
    @ObservedObject var stateModel: SUIPickerStateModel

    public init(adapter: PickerViewOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }

    public var body: some View {
        if !stateModel.isHidden {
            SUIPickerContent(
                rows: stateModel.rows,
                selectedRow: $stateModel.selectedRow,
                didSelectAt: stateModel.didSelectAt
            )
        }
    }
}

public struct SUIPickerContent: View {
    let rows: [String]
    @Binding var selectedRow: Int
    let didSelectAt: ((Int) -> Void)?

    public init(
        rows: [String],
        selectedRow: Binding<Int>,
        didSelectAt: ((Int) -> Void)? = nil
    ) {
        self.rows = rows
        self._selectedRow = selectedRow
        self.didSelectAt = didSelectAt
    }

    public var body: some View {
        Picker("", selection: $selectedRow) {
            ForEach(0..<rows.count, id: \.self) { index in
                Text(rows[index]).tag(index)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .onChange(of: selectedRow) { newIndex in
            didSelectAt?(newIndex)
        }
    }
}

#Preview {
    SUIPickerContent(
        rows: ["One", "Two", "Three"],
        selectedRow: .constant(0),
        didSelectAt: { print($0) }
    )
}