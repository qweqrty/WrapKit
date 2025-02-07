//
//  WebViewFlow.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

#if canImport(UIKit)
import UIKit

public protocol WebViewFlow: AnyObject {
    func navigateToWebView(title: String?, url: URL, style: WebViewStyle)
    func navigateBack()
}

public class WebViewFlowImpl: WebViewFlow {
    private let factory: WebViewFactory
    private let navigationController: UINavigationController
    
    public init(factory: WebViewFactory, navigationController: UINavigationController) {
        self.factory = factory
        self.navigationController = navigationController
    }
    
    public func navigateToWebView(title: String?, url: URL, style: WebViewStyle = .init()) {
        let vc = factory.makeWebView(title: title, url: url, flow: self, style: style)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
#endif
