//
//  TableViewCell.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class TableViewCell<ContentView: UIView>: UITableViewCell {
    public let mainContentView = ContentView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundView = nil
        backgroundColor = .clear
        contentView.addSubview(mainContentView)
        mainContentView.fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
#endif
