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
    
    // Override hitTest to check for views with `onPress` closure
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // First, check if the mainContentView itself has an `onPress` closure
        let convertedPoint = mainContentView.convert(point, from: self)
        if let mainPressableView = (mainContentView as? View),
            mainPressableView.onPress != nil,
           mainContentView.point(inside: convertedPoint, with: event) {
            return mainContentView
        } else if let mainPressableView = (mainContentView as? ImageView),
                    mainPressableView.onPress != nil,
                  mainContentView.point(inside: convertedPoint, with: event) {
            return mainContentView
        }
        
        return checkForPressableView(in: mainContentView, at: point) ?? super.hitTest(point, with: event)
    }

    // Recursively check if any view (or its subviews) has `onPress` closure
    private func checkForPressableView(in view: UIView, at point: CGPoint) -> UIView? {
        // Convert the point to the view's coordinate space
        let convertedPoint = view.convert(point, from: self)

        // Check if the point is inside the view and if it has `onPress`
        if let pressableView = view as? View, pressableView.onPress != nil, pressableView.point(inside: convertedPoint, with: nil) {
            return pressableView
        } else if let pressableView = view as? ImageView, pressableView.onPress != nil, pressableView.point(inside: convertedPoint, with: nil) {
            return pressableView
        }

        for subview in view.subviews {
            if let pressableSubview = checkForPressableView(in: subview, at: convertedPoint) {
                return pressableSubview
            }
        }

        return nil
    }
}
#endif
