//
//  CommonLoadingiOSDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

#if canImport(UIKit)
import UIKit

public class CommonLoadingiOSAdapter: CommonLoadingOutput {
    private let onView: UIView
    private let loadingView: UIView
    private let size: CGSize
    
    public init(
        onView: UIView,
        loadingView: UIView,
        size: CGSize
    ) {
        self.onView = onView
        self.loadingView = loadingView
        self.size = size
    }
    
    public func display(isLoading: Bool) {
        isLoading ? onView.showLoadingView(
            loadingView,
            backgroundColor: .clear,
            size: size
        ) : onView.hideLoadingView()
    }
}
#endif
