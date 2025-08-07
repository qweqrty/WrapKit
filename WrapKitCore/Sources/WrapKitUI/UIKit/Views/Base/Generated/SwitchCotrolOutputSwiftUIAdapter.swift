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
public class SwitchCotrolOutputSwiftUIAdapter: ObservableObject, SwitchCotrolOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: SwitchControlPresentableModel?
    }
    public func display(model: SwitchControlPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil
    public struct DisplayOnPressState {
        public let onPress: ((SwitchCotrolOutput) -> Void)?
    }
    public func display(onPress: ((SwitchCotrolOutput) -> Void)?) {
        displayOnPressState = .init(
            onPress: onPress
        )
    }
    @Published public var displayIsOnState: DisplayIsOnState? = nil
    public struct DisplayIsOnState {
        public let isOn: Bool
    }
    public func display(isOn: Bool) {
        displayIsOnState = .init(
            isOn: isOn
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let style: SwitchControlPresentableModel.Style
    }
    public func display(style: SwitchControlPresentableModel.Style) {
        displayStyleState = .init(
            style: style
        )
    }
    @Published public var displayIsEnabledState: DisplayIsEnabledState? = nil
    public struct DisplayIsEnabledState {
        public let isEnabled: Bool
    }
    public func display(isEnabled: Bool) {
        displayIsEnabledState = .init(
            isEnabled: isEnabled
        )
    }
    @Published public var displayIsHiddenState: DisplayIsHiddenState? = nil
    public struct DisplayIsHiddenState {
        public let isHidden: Bool
    }
    public func display(isHidden: Bool) {
        displayIsHiddenState = .init(
            isHidden: isHidden
        )
    }
    @Published public var displayIsLoadingShimmerStyleState: DisplayIsLoadingShimmerStyleState? = nil
    public struct DisplayIsLoadingShimmerStyleState {
        public let isLoading: Bool
        public let shimmerStyle: ShimmerView.Style?
    }
    public func display(isLoading: Bool, shimmerStyle: ShimmerView.Style?) {
        displayIsLoadingShimmerStyleState = .init(
            isLoading: isLoading, 
            shimmerStyle: shimmerStyle
        )
    }
}
