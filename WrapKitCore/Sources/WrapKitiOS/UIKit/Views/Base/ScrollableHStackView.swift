//
//  ScrollableHStackView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ScrollableHStackView: UIScrollView {
    public let contentView: StackView
    
    public init(spacing: CGFloat = 0, contentInset: UIEdgeInsets = .zero) {
        self.contentView = StackView(axis: .horizontal, spacing: spacing)
        super.init(frame: .zero)
        self.contentInset = contentInset
        initialSetup()
    }
    
    public override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            adjustForRTL()
        }
    }
    public required init?(coder: NSCoder) {
        self.contentView = StackView(axis: .horizontal)
        super.init(coder: coder)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceRightToLeft : .forceLeftToRight
    }
    
    private func adjustForRTL() {
        if semanticContentAttribute == .forceRightToLeft {
            transform = CGAffineTransform(scaleX: -1, y: 1)
            contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            transform = .identity
            contentView.transform = .identity
        }
    }
}

extension ScrollableHStackView {
    private func initialSetup() {
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        clipsToBounds = false
        keyboardDismissMode = .onDrag
        showsHorizontalScrollIndicator = false
        addSubview(contentView)
    }
    
    private func setupConstraints() {
        contentView.fillSuperview()
        contentView.anchor(
            .centerY(centerYAnchor),
            .heightTo(heightAnchor, 1),
            .widthTo(widthAnchor, 1, priority: .defaultLow)
        )
    }
}
#endif
