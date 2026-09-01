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
public class RefreshControlOutputSwiftUIAdapter: ObservableObject, RefreshControlOutput, LoadingOutput {
        @Published public var onRefresh: [(() -> Void)?]? = []

    @Published public var isLoading: Bool? = nil

    private var nextOutputSequence: UInt64 = 0



    // Initializer
    public init(
    ) {
    }

    @Published public var displayModelState: DisplayModelState? = nil
    public struct DisplayModelState {
        public let outputSequence: UInt64
        public let model: RefreshControlPresentableModel?
    }
    public func display(model: RefreshControlPresentableModel?) {
        self.onRefresh = [model?.onRefresh]
        if let isLoading = model?.isLoading {
            self.isLoading = isLoading
        }
        nextOutputSequence &+= 1
        displayModelState = .init(
            outputSequence: nextOutputSequence,
            model: model
        )
    }
    @Published public var displayStyleState: DisplayStyleState? = nil
    public struct DisplayStyleState {
        public let outputSequence: UInt64
        public let style: RefreshControlPresentableModel.Style
    }
    public func display(style: RefreshControlPresentableModel.Style) {
        nextOutputSequence &+= 1
        displayStyleState = .init(
            outputSequence: nextOutputSequence,
            style: style
        )
    }
    @Published public var displayOnRefreshState: DisplayOnRefreshState? = nil
    public struct DisplayOnRefreshState {
        public let onRefresh: (() -> Void)?
    }
    public func display(onRefresh: (() -> Void)?) {
        self.onRefresh = [onRefresh]
        displayOnRefreshState = .init(
            onRefresh: onRefresh
        )
    }
    @Published public var displayAppendingOnRefreshState: DisplayAppendingOnRefreshState? = nil
    public struct DisplayAppendingOnRefreshState {
        public let appendingOnRefresh: (() -> Void)?
    }
    public func display(appendingOnRefresh: (() -> Void)?) {
        var callbacks = self.onRefresh ?? []
        callbacks.append(appendingOnRefresh)
        self.onRefresh = callbacks
        displayAppendingOnRefreshState = .init(
            appendingOnRefresh: appendingOnRefresh
        )
    }
    @Published public var displayIsLoadingState: DisplayIsLoadingState? = nil
    public struct DisplayIsLoadingState {
        public let isLoading: Bool
    }
    public func display(isLoading: Bool) {
        self.isLoading = isLoading
        displayIsLoadingState = .init(
            isLoading: isLoading
        )
    }
}
