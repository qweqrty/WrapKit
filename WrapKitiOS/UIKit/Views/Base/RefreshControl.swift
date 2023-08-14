//
//  RefreshControl.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class RefreshControl: UIRefreshControl {
    public init(tintColor: UIColor, zPosition: CGFloat = 0) {
        super.init()
        
        self.tintColor = tintColor
        self.layer.zPosition = zPosition
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
