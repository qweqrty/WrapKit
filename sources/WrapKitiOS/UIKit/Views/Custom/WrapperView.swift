//
//  WrapperView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class WrapperView<ContentView: UIView>: View {
    public var padding: UIEdgeInsets = .zero {
        didSet {
            contentViewConstraints?.top?.constant = padding.top
            contentViewConstraints?.leading?.constant = padding.left
            contentViewConstraints?.trailing?.constant = -padding.right
            contentViewConstraints?.bottom?.constant = -padding.bottom
        }
    }
    public let contentView: ContentView
    
    public var contentViewConstraints: AnchoredConstraints?
    
    public init(contentView: ContentView = ContentView(), backgroundColor: UIColor = .clear, padding: UIEdgeInsets = .zero, isHidden: Bool = false) {
        self.contentView = contentView
        super.init(frame: .zero)
        addSubview(contentView)
        self.padding = padding
        self.backgroundColor = backgroundColor
        contentViewConstraints = contentView.fillSuperview(padding: self.padding)
        self.isHidden = isHidden
    }
    
    public override init(frame: CGRect) {
        contentView = ContentView()
        super.init(frame: frame)
        addSubview(contentView)
        contentViewConstraints = contentView.fillSuperview(padding: self.padding)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
