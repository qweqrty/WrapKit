// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif

public final class WebViewOutputSpy: WebViewOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case display(url: URL)
        case display(refreshModel: WebViewStyle.Refresh)
        case display(backgroundColor: Color?)
        case display(isProgressBarNeeded: Bool)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayUrl: [URL] = []
    public private(set) var capturedDisplayRefreshModel: [WebViewStyle.Refresh] = []
    public private(set) var capturedDisplayBackgroundColor: [Color?] = []
    public private(set) var capturedDisplayIsProgressBarNeeded: [Bool] = []


    // MARK: - WebViewOutput methods
    public func display(url: URL) {
        capturedDisplayUrl.append(url)
        messages.append(.display(url: url))
    }
    public func display(refreshModel: WebViewStyle.Refresh) {
        capturedDisplayRefreshModel.append(refreshModel)
        messages.append(.display(refreshModel: refreshModel))
    }
    public func display(backgroundColor: Color?) {
        capturedDisplayBackgroundColor.append(backgroundColor)
        messages.append(.display(backgroundColor: backgroundColor))
    }
    public func display(isProgressBarNeeded: Bool) {
        capturedDisplayIsProgressBarNeeded.append(isProgressBarNeeded)
        messages.append(.display(isProgressBarNeeded: isProgressBarNeeded))
    }

    // MARK: - Properties
}
