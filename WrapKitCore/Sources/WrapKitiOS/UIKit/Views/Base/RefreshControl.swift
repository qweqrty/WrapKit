//
//  RefreshControl.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class RefreshControl: UIRefreshControl {
    public var onRefresh: (() -> Void)?
    
    public init(tintColor: UIColor, zPosition: CGFloat = 0) {
        super.init()
        
        self.tintColor = tintColor
        self.layer.zPosition = zPosition
        addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    @objc private func didRefresh() {
        onRefresh?()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
public extension UIRefreshControl {
    func with(tintColor: UIColor) -> Self {
        self.tintColor = tintColor
        return self
    }
    
    func with(zPosition: CGFloat) -> Self {
        self.layer.zPosition = zPosition
        return self
    }
}

#endif
