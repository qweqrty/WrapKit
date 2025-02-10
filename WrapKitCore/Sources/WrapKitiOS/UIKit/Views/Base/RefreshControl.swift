//
//  RefreshControl.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public struct RefreshControlStyle {
    public let tintColor: Color?
    public let zPosition: CGFloat
    
    public init(tintColor: Color? = nil, zPosition: CGFloat = 0) {
        self.tintColor = tintColor
        self.zPosition = zPosition
    }
}

#if canImport(UIKit)
import UIKit

extension RefreshControl: LoadingOutput {
    public func display(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

open class RefreshControl: UIRefreshControl {
    public var isLoading: Bool? = false {
        didSet {
            isLoading ?? false ? beginRefreshing() : endRefreshing()
        }
    }
    
    public var onRefresh: (() -> Void)?
    
    public init(tintColor: UIColor? = nil, zPosition: CGFloat = 0) {
        super.init()
        
        self.tintColor = tintColor
        self.layer.zPosition = zPosition
        addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    convenience public init(style: RefreshControlStyle = .init()) {
        self.init(tintColor: style.tintColor, zPosition: style.zPosition)
    }
    
    @objc private func didRefresh() {
        onRefresh?()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func display(style: RefreshControlStyle) {
        self.tintColor = style.tintColor
        self.layer.zPosition = style.zPosition
    }
}
#endif
