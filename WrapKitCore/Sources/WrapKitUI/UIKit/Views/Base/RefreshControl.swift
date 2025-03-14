//
//  RefreshControl.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

import Foundation

public struct RefreshControlPresentableModel {
    public struct Style {
        public let tintColor: Color?
        public let zPosition: CGFloat
        
        public init(tintColor: Color? = nil, zPosition: CGFloat = 0) {
            self.tintColor = tintColor
            self.zPosition = zPosition
        }
    }
    
    public let style: Style?
    public let onRefresh: (() -> Void)?
    public let isLoading: Bool?
    
    public init(
        style: Style? = nil,
        onRefresh: (() -> Void)? = nil,
        isLoading: Bool? = nil
    ) {
        self.style = style
        self.onRefresh = onRefresh
        self.isLoading = isLoading
    }
}

public protocol RefreshControlOutput: AnyObject {
    var onRefresh: [(() -> Void)?]? { get set }
    
    func display(model: RefreshControlPresentableModel?)
    func display(style: RefreshControlPresentableModel.Style)
    func display(onRefresh: (() -> Void)?)
    func display(appendingOnRefresh: (() -> Void)?)
    func display(isLoading: Bool)
}

#if canImport(UIKit)
import UIKit

extension RefreshControl: RefreshControlOutput {
    public func display(model: RefreshControlPresentableModel?) {
        if let style = model?.style { display(style: style) }
        display(onRefresh: model?.onRefresh)
        if let isLoading = model?.isLoading {
            display(isLoading: isLoading)
        }
    }
    
    public func display(onRefresh: (() -> Void)?) {
        self.onRefresh?.removeAll()
        self.onRefresh?.append(onRefresh)
    }
    
    public func display(appendingOnRefresh: (() -> Void)?) {
        self.onRefresh?.append(appendingOnRefresh)
    }
}

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
    
    public var onRefresh: [(() -> Void)?]? = [(() -> Void)?]()
    
    public init(tintColor: UIColor? = nil, zPosition: CGFloat = 0) {
        super.init()
        
        self.tintColor = tintColor
        self.layer.zPosition = zPosition
        addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    convenience public init(style: RefreshControlPresentableModel.Style = .init()) {
        self.init(tintColor: style.tintColor, zPosition: style.zPosition)
    }
    
    @objc private func didRefresh() {
        onRefresh?.forEach {
            $0?()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func display(style: RefreshControlPresentableModel.Style) {
        self.tintColor = style.tintColor
        self.layer.zPosition = style.zPosition
    }
}
#endif
