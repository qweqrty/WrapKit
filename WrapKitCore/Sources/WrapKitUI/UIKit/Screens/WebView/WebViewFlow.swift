//
//  WebViewFlow.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

public protocol WebViewFlow: AnyObject {
    func navigateToWebView(title: String?, url: URL, style: WebViewStyle)
    func navigateBack()
}
