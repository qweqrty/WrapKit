//
//  CommonLoadingiOSDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

#if canImport(UIKit)
import UIKit

class CommonLoadingiOSAdapter: CommonLoadingOutput {
    private let view: UIView
    private let style: NVActivityIndicatorType
    private let tintColor: UIColor
    private let size: CGSize

    public init(
        view: UIView,
        style: NVActivityIndicatorType = .circleStrokeSpin,
        tintColor: UIColor,
        size: CGSize
    ) {
        self.view = view
        self.style = style
        self.tintColor = tintColor
        self.size = size
    }
    
    func display(isLoading: Bool) {
        view.showLoadingView(
            NVActivityIndicatorView(
                frame: .zero,
                type: style,
                color: tintColor
            ),
            backgroundColor: .clear,
            size: .init(width: 20, height: 20)
        )
    }
}
#endif
