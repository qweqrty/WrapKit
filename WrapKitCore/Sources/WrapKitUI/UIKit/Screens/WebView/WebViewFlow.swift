//
//  WebViewFlow.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

public protocol WebViewFlow: AnyObject {
    func navigateToWebView(
        url: URL,
        style: WebViewStyle,
        navigationPolicy: WebViewNavigationPolicy?
    )
    func navigateBack()
}
