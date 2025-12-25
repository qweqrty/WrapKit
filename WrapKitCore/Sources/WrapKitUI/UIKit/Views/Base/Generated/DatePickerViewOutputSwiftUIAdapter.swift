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
public class DatePickerViewOutputSwiftUIAdapter: ObservableObject, DatePickerViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayDateChangedState: DisplayDateChangedState? = nil
    public struct DisplayDateChangedState {
        public let dateChanged: ((Date) -> Void)?
    }
    public func display(dateChanged: ((Date) -> Void)?) {
        displayDateChangedState = .init(
            dateChanged: dateChanged
        )
    }
    @Published public var displayDateState: DisplayDateState? = nil
    public struct DisplayDateState {
        public let date: Date
    }
    public func display(date: Date) {
        displayDateState = .init(
            date: date
        )
    }
    @Published public var displaySetDateAnimatedState: DisplaySetDateAnimatedState? = nil
    public struct DisplaySetDateAnimatedState {
        public let setDate: Date
        public let animated: Bool
    }
    public func display(setDate: Date, animated: Bool) {
        displaySetDateAnimatedState = .init(
            setDate: setDate, 
            animated: animated
        )
    }
    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: DatePickerPresentableModel
    }
    public func display(model: DatePickerPresentableModel) {
        displayModelState = .init(
            model: model
        )
    }
}
