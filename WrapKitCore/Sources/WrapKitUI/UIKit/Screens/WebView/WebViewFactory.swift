//
//  WebViewFactory.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

public protocol WebViewFactory<Controller> {
    associatedtype Controller
    func makeWebView(
        url: URL,
        flow: any WebViewFlow,
        style: WebViewStyle,
        navigationPolicy: WebViewNavigationPolicy?
    ) -> Controller
}

#if canImport(WebKit) && canImport(UIKit) && !os(watchOS)
import UIKit

public class WebViewFactoryiOS: WebViewFactory {
    public init() {}
    
    public func makeWebView(
        url: URL,
        flow: any WebViewFlow,
        style: WebViewStyle = .init(),
        navigationPolicy: WebViewNavigationPolicy? = nil
    ) -> UIViewController {
        let presenter = WebViewPresenter(
            url: url,
            flow: flow,
            style: style,
            navigationPolicy: navigationPolicy
        )
        let contentView = WebViewContentView()
        let vc = WebViewVC(
            contentView: contentView,
            presenter: presenter,
            lifeCycleViewOutput: presenter,
            onBackSwipeStateChange: style.onBackSwipeStateChange
        )
        presenter.view = vc.weakReferenced.mainQueueDispatched
        presenter.navBarView = contentView.navigationBar.weakReferenced.mainQueueDispatched
        presenter.progressBarView = contentView.progressBarView.weakReferenced.mainQueueDispatched
        presenter.refreshControlView = contentView.refreshControl.weakReferenced.mainQueueDispatched
        vc.hidesBottomBarWhenPushed = style.hidesBottomBarWhenPushed
        return vc
    }
}
#endif
