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
public class WebViewOutputSwiftUIAdapter: ObservableObject, WebViewOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displayUrlState: DisplayUrlState? = nil
    public struct DisplayUrlState {
        public let url: URL
    }
    public func display(url: URL) {
        displayUrlState = .init(
            url: url
        )
    }
    @Published public var displayRefreshModelState: DisplayRefreshModelState? = nil
    public struct DisplayRefreshModelState {
        public let refreshModel: WebViewStyle.Refresh
    }
    public func display(refreshModel: WebViewStyle.Refresh) {
        displayRefreshModelState = .init(
            refreshModel: refreshModel
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
    @Published public var displayIsProgressBarNeededState: DisplayIsProgressBarNeededState? = nil
    public struct DisplayIsProgressBarNeededState {
        public let isProgressBarNeeded: Bool
    }
    public func display(isProgressBarNeeded: Bool) {
        displayIsProgressBarNeededState = .init(
            isProgressBarNeeded: isProgressBarNeeded
        )
    }
}
