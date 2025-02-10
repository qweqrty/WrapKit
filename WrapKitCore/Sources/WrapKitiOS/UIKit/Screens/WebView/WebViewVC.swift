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
    public init(contentView: WebViewContentView, presenter: LifeCycleViewInput) {
        super.init(contentView: contentView, lifeCycleViewInput: presenter)
        contentView.webView.navigationDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
    
    public func display(isProgressBarNeeded: Bool) {
        guard isProgressBarNeeded else { return }
        
        contentView.webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
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
        contentView.progressBarView.display(progress: .percentage(contentView.webView.estimatedProgress))
        guard contentView.webView.estimatedProgress == 1 else { return }
        contentView.progressBarView.display(model: nil)
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
        contentView.refreshControl.display(isLoading: true)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
        contentView.refreshControl.display(isLoading: false)
    }
}

#endif
#endif
