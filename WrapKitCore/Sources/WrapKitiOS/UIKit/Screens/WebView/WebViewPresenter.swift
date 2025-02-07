//
//  WebViewPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

import Foundation

public protocol WebViewOutput: AnyObject {
    func display(url: URL)
    func display(refreshEnabled: Bool)
}

public protocol WebViewInput {
    func viewDidLoad()
}

open class WebViewPresenter {
    public weak var view: WebViewOutput?
    public weak var navBarView: HeaderOutput?
    public weak var progressBarView: ProgressBarOutput?
    public weak var refreshControlView: LoadingOutput?
    
    private var flow: WebViewFlow
    private var url: URL
    private var style: WebViewStyle
    
    public init(
        url: URL,
        flow: WebViewFlow,
        style: WebViewStyle
    ) {
        self.url = url
        self.flow = flow
        self.style = style
    }
    
    private func setupNavigationBar() {
        switch style.header {
        case .default(let title):
            navBarView?.display(model: .defaultWebViewHeader(title: title, onPress: flow.navigateBack))
        case .custom(let model):
            navBarView?.display(model: model)
        case .hidden:
            navBarView?.display(model: nil)
        }
    }
}

extension WebViewPresenter: WebViewInput {
    public func viewDidLoad() {
        view?.display(url: url)
        view?.display(refreshEnabled: style.refreshEnabled)
        progressBarView?.display(model: style.progressBarModel)
        setupNavigationBar()
    }
}

