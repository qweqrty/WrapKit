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

public protocol WebViewInput {
    func decideNavigation(for url: URL, trigger: WebViewNavigationTrigger) -> WebViewNavigationDecision
}

open class WebViewPresenter: WebViewInput {
    public var view: WebViewOutput?
    public var navBarView: HeaderOutput?
    public var progressBarView: ProgressBarOutput?
    public var refreshControlView: LoadingOutput?
    
    private var flow: WebViewFlow
    private var url: URL
    private var style: WebViewStyle
    private var navigationPolicy: WebViewNavigationPolicy?
    
    public init(
        url: URL,
        flow: WebViewFlow,
        style: WebViewStyle,
        navigationPolicy: WebViewNavigationPolicy?
    ) {
        self.url = url
        self.flow = flow
        self.style = style
        self.navigationPolicy = navigationPolicy
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
    
    public func handleNavigation(to url: URL) {
        view?.display(url: url)
    }
    
    public func decideNavigation(for url: URL, trigger: WebViewNavigationTrigger) -> WebViewNavigationDecision {
        let decision = navigationPolicy?.decideNavigation(for: url, trigger: trigger) ?? .allow
        
        if decision == .allow && trigger == .linkActivated {
            handleNavigation(to: url)
        }
        
        return decision
    }
}

extension WebViewPresenter: LifeCycleViewOutput {
    public func viewDidLoad() {
        setupNavigationBar()
        view?.display(refreshModel: style.refresh)
        view?.display(isProgressBarNeeded: style.progressBarModel != nil)
        progressBarView?.display(model: style.progressBarModel)
        view?.display(url: url)
        view?.display(backgroundColor: style.backgroundColor)
    }
}
