//
//  TagFlowLayout.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/9/25.
//

#if canImport(UIKit)
import Foundation
import UIKit

public class TagFlowLayout: UICollectionViewFlowLayout {
    public class Row {
        public var attributes = [UICollectionViewLayoutAttributes]()
        public let spacing: CGFloat

        public init(spacing: CGFloat) {
            self.spacing = spacing
        }

        public func add(attribute: UICollectionViewLayoutAttributes) {
            attributes.append(attribute)
        }

        public func tagLayout(collectionViewWidth: CGFloat) {
            let padding = 0
            var offset = padding
            for attribute in attributes {
                attribute.frame.origin.x = CGFloat(offset)
                offset += Int(attribute.frame.width + spacing)
            }
        }
    }
    
    private let spacing: CGFloat
    
    public init(estimatedItemSize: CGSize = UICollectionViewFlowLayout.automaticSize, spacing: CGFloat = 8) {
        self.spacing = spacing
        super.init()
        self.estimatedItemSize = estimatedItemSize
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard scrollDirection == .vertical else { return super.layoutAttributesForElements(in: rect) }
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        var rows = [Row]()
        var currentRowY: CGFloat = -1

        for attribute in attributes {
            if currentRowY != attribute.frame.origin.y {
                currentRowY = attribute.frame.origin.y
                rows.append(Row(spacing: spacing))
            }
            rows.last?.add(attribute: attribute)
        }

        rows.forEach {
            $0.tagLayout(collectionViewWidth: collectionView?.frame.width ?? 0)
        }
        return rows.flatMap { $0.attributes }
    }
    
    public override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
