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
    lazy var contentStackView = StackView(axis: .vertical)
    public lazy var navigationBar = NavigationBar()
    public lazy var progressBarView = ProgressBarView()
    public lazy var webView = makeWebView()
    public lazy var refreshControl = RefreshControl()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        backgroundColor = .white
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WebViewContentView {
    func setupViews() {
        addSubviews(contentStackView)
        contentStackView.addArrangedSubviews(navigationBar, progressBarView, webView)
    }
    
    func setupConstraints() {
        progressBarView.constrainHeight(2)
        contentStackView.fillSuperview()
    }
}

private extension WebViewContentView {
    func makeWebView() -> WKWebView {
        let view = WKWebView()
        view.allowsLinkPreview = false
        view.isOpaque = false
        return view
    }
}
#endif
