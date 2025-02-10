//
//  WebViewPresenter.swift
//  WrapKit
//
//  Created by Stas Lee on 12/1/24.
//

import Foundation

public protocol WebViewOutput: AnyObject {
    func display(url: URL)
    func display(refreshModel: WebViewStyle.Refresh)
    func display(backgroundColor: Color?)
    func display(isProgressBarNeeded: Bool)
}

open class WebViewPresenter {
    public var view: WebViewOutput?
    public var navBarView: HeaderOutput?
    public var progressBarView: ProgressBarOutput?
    public var refreshControlView: LoadingOutput?
    
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

extension WebViewPresenter: LifeCycleViewInput {
    public func viewDidLoad() {
        setupNavigationBar()
        view?.display(url: url)
        view?.display(refreshModel: style.refresh)
        view?.display(isProgressBarNeeded: style.progressBarModel != nil)
        progressBarView?.display(model: style.progressBarModel)
    }
}

