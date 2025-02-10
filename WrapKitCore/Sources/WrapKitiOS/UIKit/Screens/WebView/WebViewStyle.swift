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
    
    public struct Refresh {
        public let isEnabled: Bool
        public let style: RefreshControl.Style
        
        public init(isEnabled: Bool = false, style: RefreshControl.Style = .init()) {
            self.isEnabled = isEnabled
            self.style = style
        }
    }
    
    public let title: String?
    public let header: Header
    public let progressBarModel: ProgressBarPresentableModel?
    public let hidesBottomBarWhenPushed: Bool
    public let refresh: Refresh
    
    public init(
        title: String? = nil,
        header: Header? = nil,
        progressBarModel: ProgressBarPresentableModel? = nil,
        hidesBottomBarWhenPushed: Bool = false,
        refresh: Refresh = .init()
    ) {
        self.title = title
        self.header = header ?? .default(title: title)
        self.progressBarModel = progressBarModel
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.refresh = refresh
    }
}
