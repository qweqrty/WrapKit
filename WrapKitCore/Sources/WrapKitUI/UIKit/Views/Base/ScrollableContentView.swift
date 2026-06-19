//
//  ScrollableContentView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ScrollableContentView: UIScrollView {
    public let contentView = ViewUIKit()
    private var minHeightConstraint: NSLayoutConstraint?
    
    public init(contentInset: UIEdgeInsets = .zero) {
        super.init(frame: .zero)
        
        self.contentInset = contentInset
        initialSetup()
    }
    
    public init() {
        super.init(frame: .zero)
        initialSetup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension ScrollableContentView {
    private func initialSetup() {
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        keyboardDismissMode = .onDrag
        showsVerticalScrollIndicator = false
        addSubview(contentView)
    }
    
    private func setupConstraints() {
        contentView.fillSuperview()
        contentView.anchor(.widthTo(widthAnchor, 1))
        
        let constraint = contentView.heightAnchor.constraint(
            equalTo: safeAreaLayoutGuide.heightAnchor
        )
        constraint.priority = UILayoutPriority(250)
        constraint.isActive = true
        minHeightConstraint = constraint
    }
    
    open override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        let extraTop = max(0, adjustedContentInset.top - safeAreaInsets.top)
        let extraBottom = max(0, adjustedContentInset.bottom - safeAreaInsets.bottom)
        minHeightConstraint?.constant = -(extraTop + extraBottom)
    }
}
#endif
