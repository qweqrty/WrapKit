//
//  WebViewVC.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

#if canImport(UIKit)
#if canImport(MapKit)
import Foundation
import UIKit
import WebKit

open class WebViewVC: ViewController<WebViewContentView> {
    private let presenter: WebViewInput
    private static let estimatedProgressKeyPath = #keyPath(WKWebView.estimatedProgress)
    
    public init(
        contentView: WebViewContentView,
        presenter: WebViewInput,
        lifeCycleViewOutput: LifeCycleViewOutput?
    ) {
        self.presenter = presenter
        super.init(contentView: contentView, lifeCycleViewOutput: lifeCycleViewOutput)
        contentView.webView.navigationDelegate = self
        contentView.webView.uiDelegate = self
        contentView.webView.allowsBackForwardNavigationGestures = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        guard contentView.webView.observationInfo != nil else { return }
        contentView.webView.removeObserver(self, forKeyPath: Self.estimatedProgressKeyPath)
    }
}

extension WebViewVC: WebViewOutput {
    public func display(url: URL) {
        contentView.webView.load(URLRequest(url: url))
    }
    
    public func display(refreshModel: WebViewStyle.Refresh) {
        contentView.refreshControl.display(style: refreshModel.style)
        contentView.webView.scrollView.bounces = refreshModel.isEnabled
        contentView.webView.scrollView.refreshControl = refreshModel.isEnabled ? contentView.refreshControl : nil
        if refreshModel.isEnabled {
            contentView.refreshControl.addTarget(self, action: #selector(reloadWebView), for: .valueChanged)
        }
    }
    
    @objc func reloadWebView() {
        contentView.webView.reload()
        contentView.refreshControl.endRefreshing()
    }
    
    public func display(isProgressBarNeeded: Bool) {
        guard isProgressBarNeeded else { return }
        // TODO: Check observers removal
        if contentView.webView.observationInfo != nil {
            contentView.webView.removeObserver(self, forKeyPath: Self.estimatedProgressKeyPath)
        }
        contentView.webView.addObserver(
            self,
            forKeyPath: Self.estimatedProgressKeyPath,
            options: .new,
            context: nil
        )
    }
    
    public func display(backgroundColor: Color?) {
        guard let backgroundColor else { return }
        contentView.backgroundColor = backgroundColor
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == "estimatedProgress" else { return }
        contentView.progressBarView.display(progress: contentView.webView.estimatedProgress * 100)
        guard contentView.webView.estimatedProgress == 1 else { return }
        contentView.progressBarView.display(model: nil)
    }
}

extension WebViewVC: WKUIDelegate {
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension WebViewVC: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        contentView.refreshControl.display(isLoading: false)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        contentView.refreshControl.display(isLoading: true)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        contentView.refreshControl.display(isLoading: false)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        contentView.refreshControl.display(isLoading: false)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
        contentView.refreshControl.display(isLoading: false)
    }
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        let trigger: WebViewNavigationTrigger = navigationAction.navigationType == .linkActivated ? .linkActivated : .other
        let decision = presenter.decideNavigation(for: url, trigger: trigger)
        switch decision {
        case .allow:
            decisionHandler(.allow)
        case .cancelAndOpenExternally:
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case .cancel:
            decisionHandler(.cancel)
        }
    }
}

#endif
#endif
