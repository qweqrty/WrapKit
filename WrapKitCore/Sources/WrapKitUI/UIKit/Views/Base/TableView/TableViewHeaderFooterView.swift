//
//  TableViewHeaderFooterView.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 17/4/25.
//

#if canImport(UIKit)
import UIKit

open class TableViewHeaderFooterView<ContentView: UIView>: UITableViewHeaderFooterView {
    public let mainContentView: ContentView
    public var mainContentViewConstraints: AnchoredConstraints?

    public override init(reuseIdentifier: String?) {
        self.mainContentView = ContentView()
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundView = nil
        contentView.backgroundColor = .clear
        contentView.addSubview(mainContentView)
        mainContentViewConstraints = mainContentView.fillSuperview()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
