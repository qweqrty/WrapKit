//
//  TableViewCell.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class TableViewCell<ContentView: UIView>: UITableViewCell {
    public let mainContentView: ContentView
    public var mainContentViewConstraints: AnchoredConstraints?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.mainContentView = ContentView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundView = nil
        backgroundColor = .clear
        contentView.addSubview(mainContentView)
        mainContentViewConstraints = mainContentView.anchor(
            .top(contentView.topAnchor),
            .leading(contentView.leadingAnchor),
            .trailing(contentView.trailingAnchor),
            .bottom(contentView.bottomAnchor)
        )
    }
    
    public required init?(coder: NSCoder) {
        self.mainContentView = ContentView()
        super.init(coder: coder)
    }

    // Override hitTest to check for views with `onPress` closure
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
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

    private func checkForPressableView(in view: UIView, at point: CGPoint) -> UIView? {
        let convertedPoint = view.convert(point, from: self)

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
