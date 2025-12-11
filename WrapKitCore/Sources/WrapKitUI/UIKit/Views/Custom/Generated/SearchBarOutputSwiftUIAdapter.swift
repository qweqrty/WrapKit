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
public class SearchBarOutputSwiftUIAdapter: ObservableObject, SearchBarOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: SearchBarPresentableModel?
    }
    public func display(model: SearchBarPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayTextFieldState: DisplayTextFieldState? = nil
    public struct DisplayTextFieldState {
        public let textField: TextInputPresentableModel?
    }
    public func display(textField: TextInputPresentableModel?) {
        displayTextFieldState = .init(
            textField: textField
        )
    }
    @Published public var displayLeftViewState: DisplayLeftViewState? = nil
    public struct DisplayLeftViewState {
        public let leftView: ButtonPresentableModel?
    }
    public func display(leftView: ButtonPresentableModel?) {
        displayLeftViewState = .init(
            leftView: leftView
        )
    }
    @Published public var displayRightViewState: DisplayRightViewState? = nil
    public struct DisplayRightViewState {
        public let rightView: ButtonPresentableModel?
    }
    public func display(rightView: ButtonPresentableModel?) {
        displayRightViewState = .init(
            rightView: rightView
        )
    }
    @Published public var displayPlaceholderState: DisplayPlaceholderState? = nil
    public struct DisplayPlaceholderState {
        public let placeholder: String?
    }
    public func display(placeholder: String?) {
        displayPlaceholderState = .init(
            placeholder: placeholder
        )
    }
    @Published public var displayBackgroundColorState: DisplayBackgroundColorState? = nil
    public struct DisplayBackgroundColorState {
        public let backgroundColor: Color?
    }
    public func display(backgroundColor: Color?) {
        displayBackgroundColorState = .init(
            backgroundColor: backgroundColor
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
}
