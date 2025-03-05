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
        title: String? = nil,
        url: URL,
        style: WebViewStyle = .init()
    ) {
        let vc = factory.makeWebView(
            title: title,
            url: url,
            flow: self,
            style: style
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}
#endif
