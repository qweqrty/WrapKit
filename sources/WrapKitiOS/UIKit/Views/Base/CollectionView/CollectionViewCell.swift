//
//  CollectionViewCell.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class CollectionViewCell<ContentView: UIView>: UICollectionViewCell {
    public let mainContentView = ContentView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        backgroundView = nil
        backgroundColor = .clear
        contentView.addSubview(mainContentView)
        mainContentView.fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
