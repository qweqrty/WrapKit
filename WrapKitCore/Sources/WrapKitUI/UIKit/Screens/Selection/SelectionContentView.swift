//
//  SelectionContentView.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
import Foundation
import UIKit

public class SelectionContentView: UIView {
    static let searchBarHeight: CGFloat = 44
    static let maxSearchBarTopSpacing: CGFloat = 8
    
    public lazy var lineView = ViewUIKit(backgroundColor: config.content.lineColor)
    public lazy var navigationBar = NavigationBar()
    public lazy var tableStackView = StackView(axis: .vertical)
    public lazy var emptyView = {
        let view = EmptyView()
        view.isHidden = true
        return view
    }()
    public lazy var tableView = makeTableView()
    public lazy var searchBar = makeSearchBar()
    
    public lazy var buttonsStackView = StackView(axis: .horizontal, spacing: 12)
    public lazy var resetButton = Button()
    public lazy var selectButton = Button()
    public lazy var spacerView = UIView()
    public lazy var refreshControl = RefreshControl(tintColor: config.content.refreshColor)
    
    public var searchBarConstraints: AnchoredConstraints?
    public var tableStackViewConstraints: AnchoredConstraints?
    
    public let config: SelectionConfiguration
    
    public init(config: SelectionConfiguration) {
        self.config = config
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        backgroundColor = config.content.backgroundColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        round(corners: [.topLeft, .topRight], radius: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectionContentView {
    func setupSubviews() {
        addSubviews(lineView, navigationBar, searchBar, tableStackView, spacerView, buttonsStackView)
        tableStackView.addArrangedSubviews(
            tableView,
            emptyView
        )
        buttonsStackView.addArrangedSubview(resetButton)
        buttonsStackView.addArrangedSubview(selectButton)
        bringSubviewToFront(navigationBar)
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
            .top(navigationBar.bottomAnchor, constant: Self.maxSearchBarTopSpacing),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12),
            .height(Self.searchBarHeight)
        )
        tableStackViewConstraints = tableStackView.anchor(
            .top(searchBar.bottomAnchor, constant: 16),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12)
        )
        spacerView.anchor(
            .top(tableStackView.bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
        buttonsStackView.anchor(
            .top(spacerView.bottomAnchor),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12),
            .bottom(bottomAnchor)
        )
    }
}

private extension SelectionContentView {
    func makeTableView() -> TableView {
        let tableView = TableView(adjustHeight: true)
        tableView.register(SelectionCell.self)
        return tableView
    }
    
    func makeSearchBar() -> SearchBar {
        let searchBar = SearchBar(
            textfield: Textfield(
                appearance: config.searchBar.textfieldAppearence
            )
        )
        searchBar.textfield.leadingView = WrapperView(
            contentView: ImageView(
                image: config.searchBar.searchImage,
                tintColor: config.searchBar.tintColor
            ),
            contentViewConstraints: { contentView, wrapperView in
                contentView.fillSuperview()
            }
        )
        return searchBar
    }
}
#endif

