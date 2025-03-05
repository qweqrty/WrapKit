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
        title: String?,
        url: URL,
        flow: any WebViewFlow,
        style: WebViewStyle
    ) -> Controller
}

#if canImport(UIKit)
import UIKit

public class WebViewFactoryiOS: WebViewFactory {
    public init() {}
    
    public func makeWebView(
        title: String? = nil,
        url: URL,
        flow: any WebViewFlow,
        style: WebViewStyle = .init()
    ) -> UIViewController {
        let presenter = WebViewPresenter(
            url: url,
            flow: flow,
            style: style
        )
        let contentView = WebViewContentView()
        let vc = WebViewVC(contentView: contentView, presenter: presenter)
        presenter.view = vc.weakReferenced.mainQueueDispatched
        presenter.navBarView = contentView.navigationBar.weakReferenced.mainQueueDispatched
        presenter.progressBarView = contentView.progressBarView.weakReferenced.mainQueueDispatched
        presenter.refreshControlView = contentView.refreshControl.weakReferenced.mainQueueDispatched
        vc.hidesBottomBarWhenPushed = style.hidesBottomBarWhenPushed
        return vc
    }
}
#endif
