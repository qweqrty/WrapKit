//
//  ScrollableContentView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class ScrollableContentView: UIScrollView {
    public let contentView = View()
    private(set) var contentViewConstraints: AnchoredConstraints?
    
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
        contentViewConstraints = contentView.anchor(
            .top(topAnchor),
            .leading(leadingAnchor),
            .leading(trailingAnchor),
            .bottom(bottomAnchor),
            .widthTo(widthAnchor, 1),
            .heightTo(safeAreaLayoutGuide.heightAnchor, 1, priority: UILayoutPriority(rawValue: 250))
        )
    }
}
#endif
