//
//  CollectionReusableView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class CollectionReusableView<ContentView: UIView>: UICollectionReusableView {
    public let contentView = ContentView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(contentView)
        contentView.fillSuperview()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
