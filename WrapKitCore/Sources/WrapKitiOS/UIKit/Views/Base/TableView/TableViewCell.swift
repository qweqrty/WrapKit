//
//  TableViewCell.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
import Combine

open class TableViewCell<ContentView: UIView>: UITableViewCell {
    public let mainContentView: ContentView
    public var mainContentViewConstraints: AnchoredConstraints?
    
    public var cancellables = Set<AnyCancellable>()

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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables.removeAll()
    }
}

#endif
