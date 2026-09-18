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
public class TooltipViewOutputSwiftUIAdapter: ObservableObject, TooltipViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayTooltipModelState: DisplayTooltipModelState? = nil
    public struct DisplayTooltipModelState {
        public let tooltipModel: TooltipViewPresentableModel?
    }
    public func display(tooltipModel: TooltipViewPresentableModel?) {
        displayTooltipModelState = .init(
            tooltipModel: tooltipModel
        )
    }
}
