//
//  LoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol LoadingOutput: AnyObject {
    var isLoading: Bool? { get set }
    
    func display(isLoading: Bool)
}

#if canImport(UIKit)
import UIKit

public class CommonLoadingiOSAdapter: LoadingOutput {
    public func display(isLoading: Bool) {
        self.isLoading = isLoading
        isLoading ? onView?.showLoadingView(
            loadingView,
            backgroundColor: backgroundColor,
            size: size
        ) : onView?.hideLoadingView()
    }
    
    public var isLoading: Bool? = false
    
    private weak var onView: UIView?
    private let loadingView: UIView
    private let size: CGSize
    private let backgroundColor: UIColor
    
    public init(
        onView: UIView,
        loadingView: UIView,
        backgroundColor: UIColor = .clear,
        size: CGSize
    ) {
        self.onView = onView
        self.loadingView = loadingView
        self.size = size
        self.backgroundColor = backgroundColor
    }
}

public extension LoadingOutput where Self == CommonLoadingiOSAdapter {
    static func NVActivityLoader(
        onView: UIView,
        type: NVActivityIndicatorType = .circleStrokeSpin,
        size: CGSize = .init(width: 80, height: 80),
        loadingViewColor: UIColor,
        wrapperViewColor: UIColor
    ) -> LoadingOutput {
        let loadingView = WrapperView(
            contentView: NVActivityIndicatorView(
                frame: .zero,
                type: type,
                color: loadingViewColor
            ),
            backgroundColor: wrapperViewColor,
            contentViewConstraints: { contentView, wrapperView in
                contentView.fillSuperview(padding: .init(top: 25, left: 25, bottom: 25, right: 25))
            }
        )
        loadingView.cornerRadius = 12
        loadingView.contentView.startAnimating()
        return CommonLoadingiOSAdapter(
            onView: onView,
            loadingView: loadingView,
            size: size
        )
    }
}
#endif
