//
//  CommonLoadingiOSDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

#if canImport(UIKit)
import UIKit

public extension CommonLoadingOutput where Self == CommonLoadingiOSAdapter {
static func defaultLoader(
    onView: UIView,
    size: CGSize = .init(width: 80, height: 80),
    loadingViewColor: UIColor,
    wrapperViewColor: UIColor
  ) -> CommonLoadingOutput {
    let loadingView = WrapperView(
      contentView: NVActivityIndicatorView(
        frame: .zero,
        type: .circleStrokeSpin,
        color: loadingViewColor
      ),
      backgroundColor: wrapperViewColor,
      padding: .init(top: 25, left: 25, bottom: 25, right: 25)
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
