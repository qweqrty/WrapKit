//
//  WebViewFlowiOS.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 10/2/25.
//

#if canImport(UIKit)
import Foundation
import UIKit

public class WebViewFlowiOS: WebViewFlow {
    public weak var navigationController: UINavigationController?
    private let factory: any WebViewFactory<UIViewController>
    
    public init(
        factory: any WebViewFactory<UIViewController>,
        navigationController: UINavigationController?
    ) {
        self.factory = factory
        self.navigationController = navigationController
    }
    
    public func navigateToWebView(
        url: URL,
        style: WebViewStyle = .init(),
        navigationPolicy: WebViewNavigationPolicy? = nil
    ) {
        let vc = factory.makeWebView(
            url: url,
            flow: self,
            style: style,
            navigationPolicy: navigationPolicy
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}
#endif
