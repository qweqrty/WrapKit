//
//  WebViewStyle.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

public struct WebViewStyle {
    public enum Header {
        case `default`(title: String? = nil)
        case custom(HeaderPresentableModel)
        case hidden
    }
    
    public let title: String?
    public let header: Header
    public let progressBarModel: ProgressBarPresentableModel?
    public let hidesBottomBarWhenPushed: Bool
    public let refreshEnabled: Bool
    
    public init(
        title: String? = nil,
        header: Header? = nil,
        progressBarModel: ProgressBarPresentableModel? = nil,
        hidesBottomBarWhenPushed: Bool = false,
        refreshEnabled: Bool = false
    ) {
        self.title = title
        self.header = header ?? .default(title: title)
        self.progressBarModel = progressBarModel
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.refreshEnabled = refreshEnabled
    }
}
