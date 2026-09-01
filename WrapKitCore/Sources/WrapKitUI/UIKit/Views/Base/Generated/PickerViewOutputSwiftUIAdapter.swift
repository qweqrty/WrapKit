// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
public class PickerViewOutputSwiftUIAdapter: ObservableObject, PickerViewOutput {
        @Published public var componentsCount: (() -> Int?)? = nil
        @Published public var rowsCount: (() -> Int)? = nil
        @Published public var titleForRowAt: ((Int) -> String?)? = nil
        @Published public var didSelectAt: ((Int) -> Void)? = nil


    private var nextOutputSequence: UInt64 = 0



    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let outputSequence: UInt64
        public let model: PickerViewPresentableModel?
    }
    public func display(model: PickerViewPresentableModel?) {
        self.componentsCount = model?.componentsCount
        self.rowsCount = model?.rowsCount
        self.titleForRowAt = model?.titleForRowAt
        self.didSelectAt = model?.didSelectAt
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displaySelectedRowState: DisplaySelectedRowState? = nil
    public struct DisplaySelectedRowState {
        public let outputSequence: UInt64
        public let selectedRow: PickerViewPresentableModel.SelectedRow?
    }
    public func display(selectedRow: PickerViewPresentableModel.SelectedRow?) {
        guard let selectedRow,
              let componentsCount = componentsCount?(),
              let rowsCount = rowsCount?(),
              selectedRow.component >= 0,
              selectedRow.component < componentsCount,
              selectedRow.row >= 0,
              selectedRow.row < rowsCount else { return }
        nextOutputSequence &+= 1
        displaySelectedRowState = .init(
            outputSequence: nextOutputSequence,
            selectedRow: selectedRow
        )
    }
}
