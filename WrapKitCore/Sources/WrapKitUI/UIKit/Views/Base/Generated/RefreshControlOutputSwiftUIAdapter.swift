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
public class RefreshControlOutputSwiftUIAdapter: ObservableObject, RefreshControlOutput {
        @Published public var onRefresh: [(() -> Void)?]? = nil

    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let model: RefreshControlPresentableModel?
    }
    public func display(model: RefreshControlPresentableModel?) {
        displayModelState = .init(
            model: model
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let style: RefreshControlPresentableModel.Style
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        displayStyleState = .init(
            style: style
        )
    }
    @Published public var displayOnRefreshState: DisplayOnRefreshState? = nil
    public struct DisplayOnRefreshState {
        public let onRefresh: (() -> Void)?
    }
    public func display(onRefresh: (() -> Void)?) {
        displayOnRefreshState = .init(
            onRefresh: onRefresh
        )
    }
    @Published public var displayAppendingOnRefreshState: DisplayAppendingOnRefreshState? = nil
    public struct DisplayAppendingOnRefreshState {
        public let appendingOnRefresh: (() -> Void)?
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        displayAppendingOnRefreshState = .init(
            appendingOnRefresh: appendingOnRefresh
        )
    }
    @Published public var displayIsLoadingState: DisplayIsLoadingState? = nil
    public struct DisplayIsLoadingState {
        public let isLoading: Bool
    }
    public func display(isLoading: Bool) {
        displayIsLoadingState = .init(
            isLoading: isLoading
        )
    }
}
