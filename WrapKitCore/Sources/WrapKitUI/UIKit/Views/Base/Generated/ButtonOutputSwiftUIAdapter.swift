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
public class ButtonOutputSwiftUIAdapter: ObservableObject, ButtonOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: ButtonPresentableModel?
    }
    public func display(model: ButtonPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayEnabledState: DisplayEnabledState? = nil
    public struct DisplayEnabledState {
        public let enabled: Bool
    }
    public func display(enabled: Bool) {
        displayEnabledState = .init(
            enabled: enabled
        )
    }
    @Published public var displayImageState: DisplayImageState? = nil
    public struct DisplayImageState {
        public let image: Image?
    }
    public func display(image: Image?) {
        displayImageState = .init(
            image: image
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let style: ButtonStyle?
    }
    public func display(style: ButtonStyle?) {
        displayStyleState = .init(
            style: style
        )
    }
    @Published public var displayTitleState: DisplayTitleState? = nil
    public struct DisplayTitleState {
        public let title: String?
    }
    public func display(title: String?) {
        displayTitleState = .init(
            title: title
        )
    }
    @Published public var displaySpacingState: DisplaySpacingState? = nil
    public struct DisplaySpacingState {
        public let spacing: CGFloat
    }
    public func display(spacing: CGFloat) {
        displaySpacingState = .init(
            spacing: spacing
        )
    }
    @Published public var displayOnPressState: DisplayOnPressState? = nil
    public struct DisplayOnPressState {
        public let onPress: (() -> Void)?
    }
    public func display(onPress: (() -> Void)?) {
        displayOnPressState = .init(
            onPress: onPress
        )
    }
    @Published public var displayHeightState: DisplayHeightState? = nil
    public struct DisplayHeightState {
        public let height: CGFloat
    }
    public func display(height: CGFloat) {
        displayHeightState = .init(
            height: height
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
}
