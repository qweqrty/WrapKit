//
//  RetryView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

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
        loadingControl.anchor(
            .centerX(centerXAnchor),
            .centerY(centerYAnchor)
        )
    }
}

@available(iOS 13.0, *)
struct RetryViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> RetryView {
        let view = RetryView(frame: .zero)
        view.loadingControl.color = .red
        view.loadingControl.style = .large
        return view
    }
    
    func updateUIView(_ uiView: RetryView, context: Context) {
        // Leave this empty
    }
}


@available(iOS 13.0, *)
struct RetryView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        VStack {
            RetryViewRepresentable()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
        }
    }
}
#endif
