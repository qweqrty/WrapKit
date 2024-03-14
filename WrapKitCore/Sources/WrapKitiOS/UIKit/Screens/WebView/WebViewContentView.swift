//
//  WebViewContentView.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

#if canImport(UIKit)
import Foundation
import UIKit
import WebKit

open class WebViewContentView: UIView {
    public lazy var navigationBar = makeNavigationBar()
    public lazy var webView = makeWebView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WebViewContentView {
    func setupViews() {
        addSubviews(navigationBar, webView)
    }
    
    func setupConstraints() {
        navigationBar.anchor(
            .top(topAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
        
        webView.anchor(
            .top(navigationBar.bottomAnchor, constant: 8),
            .bottom(bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
    }
}

private extension WebViewContentView {
    func makeNavigationBar() -> NavigationBar {
        let navigationBar = NavigationBar()
        return navigationBar
    }
    
    func makeWebView() -> WKWebView {
        let view = WKWebView()
        view.allowsLinkPreview = false
        view.isOpaque = false
        return view
    }
}
#endif
