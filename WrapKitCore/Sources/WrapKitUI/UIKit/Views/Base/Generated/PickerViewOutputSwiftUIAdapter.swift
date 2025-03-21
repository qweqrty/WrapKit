// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: PickerViewPresentableModel?
    }
    public func display(model: PickerViewPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displaySelectedRowState: DisplaySelectedRowState? = nil
    public struct DisplaySelectedRowState {
        public let selectedRow: PickerViewPresentableModel.SelectedRow?
    }
    public func display(selectedRow: PickerViewPresentableModel.SelectedRow?) {
        displaySelectedRowState = .init(
            selectedRow: selectedRow
        )
    }
}
