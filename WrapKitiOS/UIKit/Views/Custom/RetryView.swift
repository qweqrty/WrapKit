//
//  RetryView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class RetryView: View {
    public let loadingControl: UIActivityIndicatorView
    
    public override init(frame: CGRect) {
        if #available(iOS 13.0, *) {
            loadingControl = UIActivityIndicatorView(style: .medium)
        } else {
            loadingControl = UIActivityIndicatorView(style: .white)
        }

        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        loadingControl.hidesWhenStopped = false
    }
    
    public func setTransform(inTransform:CGAffineTransform, scaleFactor:CGFloat) {
        loadingControl.transform = CGAffineTransform.init(scaleX: scaleFactor, y: scaleFactor)
        if scaleFactor == 1 {
            loadingControl.startAnimating()
        } else {
            loadingControl.stopAnimating()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RetryView {
    func setupSubviews() {
        addSubview(loadingControl)
    }
    
    func setupConstraints() {
        print("Dwdw 1 \(loadingControl.intrinsicContentSize)")
        print("Dwdw 1 \(loadingControl.frame)")
        print("Dwdw 1 \(loadingControl.bounds)")
        loadingControl.anchor(
            .centerX(centerXAnchor),
            .centerY(centerYAnchor)
        )
    }
}
#endif
