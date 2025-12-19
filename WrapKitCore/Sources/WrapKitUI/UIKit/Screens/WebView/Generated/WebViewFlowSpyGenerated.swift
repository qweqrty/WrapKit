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
    public private(set) var capturedNavigateToWebViewUrlUrl: [URL] = []
    public private(set) var capturedNavigateToWebViewUrlStyle: [WebViewStyle] = []
    public private(set) var capturedNavigateToWebViewUrlNavigationPolicy: [WebViewNavigationPolicy?] = []


    // MARK: - WebViewFlow methods
    public func navigateToWebView(url: URL, style: WebViewStyle, navigationPolicy: WebViewNavigationPolicy?) {
        capturedNavigateToWebViewUrlUrl.append(url)
        capturedNavigateToWebViewUrlStyle.append(style)
        capturedNavigateToWebViewUrlNavigationPolicy.append(navigationPolicy)
        messages.append(.navigateToWebViewUrl(url: url, style: style, navigationPolicy: navigationPolicy))
    }
    public func navigateBack() {
        messages.append(.navigateBack)
    }

    // MARK: - Properties
}
