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
    
    public required init?(coder: NSCoder) {
        self.contentView = StackView(axis: .horizontal)
        super.init(coder: coder)
    }
}

extension ScrollableHStackView {
    private func initialSetup() {
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
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
