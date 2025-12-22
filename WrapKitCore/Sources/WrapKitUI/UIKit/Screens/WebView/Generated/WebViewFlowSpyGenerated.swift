// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif

public final class WebViewFlowSpy: WebViewFlow {

    public init() {}

    public enum Message: HashableWithReflection {
        case navigateToWebViewUrl(url: URL, style: WebViewStyle, navigationPolicy: WebViewNavigationPolicy?)
        case navigateBack
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedNavigateToWebViewUrl: [(url: URL, style: WebViewStyle, navigationPolicy: WebViewNavigationPolicy?)] = []
    public private(set) var capturedNavigateBackCallCount = 0


    // MARK: - WebViewFlow methods
    public func navigateToWebView(url: URL, style: WebViewStyle, navigationPolicy: WebViewNavigationPolicy?) {
        capturedNavigateToWebViewUrl.append((url: url, style: style, navigationPolicy: navigationPolicy))
        messages.append(.navigateToWebViewUrl(url: url, style: style, navigationPolicy: navigationPolicy))
    }
    public func navigateBack() {
        capturedNavigateBackCallCount += 1
        messages.append(.navigateBack)
    }

    // MARK: - Properties
}
