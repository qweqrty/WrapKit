//
//  RefreshControl.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

extension RefreshControl: LoadingOutput {
    public func display(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

open class RefreshControl: UIRefreshControl {
    public struct Style {
        public let tintColor: UIColor?
        public let zPosition: CGFloat
        
        public init(tintColor: UIColor? = nil, zPosition: CGFloat = 0) {
            self.tintColor = tintColor
            self.zPosition = zPosition
        }
    }
    
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
    
    convenience public init(style: Style = .init()) {
        self.init(tintColor: style.tintColor ?? .black, zPosition: style.zPosition)
    }
    
    @objc private func didRefresh() {
        onRefresh?()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
