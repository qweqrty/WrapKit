//
//  WebViewStyle.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 7/2/25.
//

import Foundation

public struct WebViewStyle {
    public enum Header {
        case `default`(title: String? = nil, leadingCard: CardViewPresentableModel)
        case custom(HeaderPresentableModel)
        case hidden
    }
    
    public struct Refresh: HashableWithReflection {
        public let isEnabled: Bool
        public let style: RefreshControlPresentableModel.Style
        
        public init(isEnabled: Bool = false, style: RefreshControlPresentableModel.Style = .init()) {
            self.isEnabled = isEnabled
            self.style = style
        }
    }
    
    public let title: String?
    public let header: Header
    public let progressBarModel: ProgressBarPresentableModel?
    public let hidesBottomBarWhenPushed: Bool
    public let refresh: Refresh
    public let backgroundColor: Color?
    
    public init(
        title: String? = nil,
        header: Header? = nil,
        progressBarModel: ProgressBarPresentableModel? = nil,
        hidesBottomBarWhenPushed: Bool = true,
        refresh: Refresh = .init(),
        backgroundColor: Color? = nil,
        leadingCard: CardViewPresentableModel? = nil
    ) {
        self.title = title
        if let header = header {
            self.header = header
        } else if let leadingCard = leadingCard {
            self.header = .default(title: title, leadingCard: leadingCard)
        } else {
            self.header = .hidden
        }
        
        self.progressBarModel = progressBarModel
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.refresh = refresh
        self.backgroundColor = backgroundColor
    }
}
