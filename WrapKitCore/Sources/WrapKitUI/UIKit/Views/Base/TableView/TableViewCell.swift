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
    public var onPrepareForReuse: ((TableViewCell<ContentView>) -> Void)?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.mainContentView = ContentView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundView = nil
        backgroundColor = .clear
        separatorInset = .init(top: .zero, left: UIScreen.main.bounds.width, bottom: .zero, right: .zero) // needed to ignore AlgaComponents XSeparatorStyle
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
        onPrepareForReuse?(self)
    }
}

public extension TableViewCell {
    func setFirstLast(indexPath: IndexPath, in tableView: UITableView, cornerRadius: CGFloat) {
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        let isFirst = indexPath.row == 0
        mainContentView.applyCornerStyle(.corners(.init(top: isFirst ? cornerRadius : .zero, bottom: isLast ? cornerRadius : .zero)))
    }
}

#endif
