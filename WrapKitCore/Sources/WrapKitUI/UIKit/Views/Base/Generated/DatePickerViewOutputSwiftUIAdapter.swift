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
}
