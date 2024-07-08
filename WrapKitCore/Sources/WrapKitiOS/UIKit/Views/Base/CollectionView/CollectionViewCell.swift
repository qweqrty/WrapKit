//
//  CollectionViewCell.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class CollectionViewCell<ContentView: UIView>: UICollectionViewCell {
    public let mainContentView: ContentView
    
    public var mainContentViewConstraints: AnchoredConstraints?

    public override init(frame: CGRect) {
        self.mainContentView = ContentView()
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        backgroundView = nil
        backgroundColor = .clear
        contentView.addSubview(mainContentView)
        mainContentView.anchor(
            .top(contentView.topAnchor),
            .leading(contentView.leadingAnchor),
            .trailing(contentView.trailingAnchor),
            .bottom(contentView.bottomAnchor)
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
