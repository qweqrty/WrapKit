//
//  SUIPickerView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 30/4/26.
//


import SwiftUI

public struct SUIPickerView: View {
    @StateObject var stateModel: SUIPickerStateModel

    public init(adapter: PickerViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        if !stateModel.isHidden {
            SUIPickerContent(
                componentsCount: stateModel.componentsCount,
                rows: stateModel.rows,
                selectedRows: $stateModel.selectedRows,
                accessibilityIdentifier: stateModel.accessibilityIdentifier,
                didSelectAt: stateModel.didSelectAt
            )
        }
    }
}

public struct SUIPickerContent: View {
    let componentsCount: Int
    let rows: [String]
    @Binding var selectedRows: [Int: Int]
    let accessibilityIdentifier: String?
    let didSelectAt: ((Int) -> Void)?

    public init(
        componentsCount: Int = 1,
        rows: [String],
        selectedRows: Binding<[Int: Int]>,
        accessibilityIdentifier: String? = nil,
        didSelectAt: ((Int) -> Void)? = nil
    ) {
        self.componentsCount = componentsCount
        self.rows = rows
        self._selectedRows = selectedRows
        self.accessibilityIdentifier = accessibilityIdentifier
        self.didSelectAt = didSelectAt
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<componentsCount, id: \.self) { component in
                Picker("", selection: selectedRowBinding(for: component)) {
                    ForEach(0..<rows.count, id: \.self) { index in
                        Text(rows[index]).tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: selectedRows[component] ?? 0) { newIndex in
                    didSelectAt?(newIndex)
                }
            }
        }
        .ifLet(accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier)
        }
    }

    private func selectedRowBinding(for component: Int) -> Binding<Int> {
        Binding(
            get: { selectedRows[component] ?? 0 },
            set: { selectedRows[component] = $0 }
        )
    }
}

public extension SUIPickerContent {
    init(
        rows: [String],
        selectedRow: Binding<Int>,
        didSelectAt: ((Int) -> Void)? = nil
    ) {
        self.init(
            componentsCount: 1,
            rows: rows,
            selectedRows: Binding(
                get: { [0: selectedRow.wrappedValue] },
                set: { selectedRow.wrappedValue = $0[0] ?? 0 }
            ),
            didSelectAt: didSelectAt
        )
    }
}

#Preview {
    SUIPickerContent(
        componentsCount: 2,
        rows: ["One", "Two", "Three"],
        selectedRows: .constant([0: 0, 1: 1]),
        didSelectAt: { print($0) }
    )
}
