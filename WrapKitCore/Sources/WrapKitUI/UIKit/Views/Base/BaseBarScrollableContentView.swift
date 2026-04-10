//
//  BaseBarScrollableContentView.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 4/8/26.
//

#if canImport(UIKit)
import UIKit
import SnapKit

open class BaseBarScrollableContentView: ViewUIKit {

    public let headerStyle: HeaderPresentableModel.Style?
    public private(set) lazy var navigationBar = NavigationBar()

    public private(set) lazy var scrollView = UIScrollView()
    public private(set) lazy var contentView = ViewUIKit()

    open var refreshControl: UIRefreshControl? {
        get { scrollView.refreshControl }
        set { scrollView.refreshControl = newValue }
    }

    public init(contentInset: UIEdgeInsets = .zero, headerStyle: HeaderPresentableModel.Style? = nil) {
        self.headerStyle = headerStyle

        super.init(frame: .zero)

        scrollView.contentInset = contentInset
        initialSetup()
        
        if let headerStyle {
            navigationBar.display(style: headerStyle)
        }
        if #available(iOS 26, *), headerStyle?.backgroundColor == .clear {
            navigationBar.addScrollEdgeInteractionWith(scrollView, at: .top)
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let navBarBottom = max(0, navigationBar.frame.maxY - scrollView.frame.minY) / 2
        if navBarBottom != scrollView.contentInset.top {
            scrollView.contentInset.top = navBarBottom
        }
    }
}

extension BaseBarScrollableContentView {
    private func initialSetup() {
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        scrollView.keyboardDismissMode = .onDrag
        scrollView.showsVerticalScrollIndicator = false
        addSubviews(scrollView, navigationBar)
        scrollView.addSubview(contentView)
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // All contentView edges stay within the scrollView — this defines the scrollable content.
        // The top offset is set dynamically in layoutSubviews based on navbar height.
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
//            make.height.equalTo(safeAreaLayoutGuide.snp.height).priority(UILayoutPriority(rawValue: 250))
        }
    }
}

#endif
