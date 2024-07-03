//
//  SelectionContentView.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation
import UIKit

public class SelectionContentView: UIView {
    lazy var scrollableView = ScrollableContentView()
    lazy var lineView = View(backgroundColor: UIColor.lightGray)
    lazy var navigationBar = makeNavigationBar()
    lazy var tableView = makeTableView()
    lazy var searchBar = makeSearchBar()
    
    lazy var stackView = StackView(axis: .horizontal, spacing: 12)
    lazy var resetButton = makeActionButton(isReset: true)
    lazy var selectButton = makeActionButton(isReset: false)
    lazy var spacerView = UIView()
    
    var searchBarConstraints: AnchoredConstraints?
    var tableViewConstraints: AnchoredConstraints?
    
    public init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionContentView {
    func setupSubviews() {
        addSubviews(lineView, navigationBar, searchBar, tableView, spacerView, stackView)
        stackView.addArrangedSubview(resetButton)
        stackView.addArrangedSubview(selectButton)
    }
    
    func setupConstraints() {
        lineView.anchor(
            .height(4),
            .widthTo(widthAnchor, 40/375),
            .top(topAnchor, constant: 12),
            .centerX(centerXAnchor)
        )
        navigationBar.anchor(
            .top(lineView.bottomAnchor, constant: 8),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
        resetButton.anchor(
            .height(48),
            .widthTo(widthAnchor, 133/375, priority: .defaultHigh)
        )
        selectButton.anchor(.height(48))
        searchBarConstraints = searchBar.anchor(
            .top(navigationBar.bottomAnchor, constant: 8),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12),
            .height(44)
        )
        stackView.anchor(
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12),
            .bottom(bottomAnchor, constant: 24 + 24)//CGFloat.safeBottomAreaHeight)
        )
        tableViewConstraints = tableView.anchor(
            .top(searchBar.bottomAnchor, constant: 16),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12)
        )
        spacerView.anchor(
            .top(tableView.bottomAnchor),
            .bottom(bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
    }
}

private extension SelectionContentView {
    func makeTableView() -> TableView {
        let tableView = TableView(adjustHeight: true)
        tableView.register(SelectionCell.self)
        return tableView
    }
    
    func makeNavigationBar() -> NavigationBar {
//        let view = NavigationBar()
//        view.titleViews.keyLabel.font = .systemFont(ofSize: 16)
//        view.titleViews.keyLabel.textColor = UIColor.black.color
//        view.titleViews.stackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
//        view.leadingStackView.isHidden = true
//        view.trailingStackView.isHidden = false
//        return view
        let navigationBar = NavigationBar()
        navigationBar.titleViews.keyLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        navigationBar.backButton.setImage(UIImage(named: "icChevronLeft"), for: .normal)
        return navigationBar
    }
    
    func makeButton(imageName: String) -> Button {
        let btn = Button(image: UIImage(named: imageName)!, tintColor: .black)
        return btn
    }
    
    func makeActionButton(isReset: Bool) -> Button {
        let button = Button(
            textColor: isReset ? UIColor.black : UIColor.lightText,
            titleLabelFont: .systemFont(ofSize: 16),
            backgroundColor: isReset ? UIColor.darkGray : UIColor.white
        )
        button.layer.cornerRadius = 16
        button.layer.borderColor = isReset ? UIColor.lightGray.cgColor : UIColor.clear.cgColor
        button.layer.borderWidth = isReset ? 1 : 0
        return button
    }
    
    func makeSearchBar() -> SearchBar {
        let searchBar = SearchBar(
            textfield: Textfield(
                appearance: .init(
                    colors: .init(
                        textColor: .black,
                        selectedBorderColor: .black,
                        selectedBackgroundColor: .black,
                        errorBorderColor: .black,
                        errorBackgroundColor: .black,
                        deselectedBorderColor: .black,
                        deselectedBackgroundColor: .black
                    ),
                    font: .systemFont(ofSize: 16)
                ),
                placeholder: nil
            )
        )
        searchBar.textfield.leadingView = WrapperView(contentView: ImageView(
            image: UIImage(named: "plusIc")!,
            tintColor: UIColor.darkGray
        ))
        return searchBar
    }
}
