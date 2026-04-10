//
//  BaseBarScrollableContentView.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 4/8/26.
//

#if canImport(UIKit)
import UIKit
import SnapKit

open class BaseBarScrollableContentView<T: UIScrollView>: ViewUIKit {

    public let headerStyle: HeaderPresentableModel.Style?
    public private(set) lazy var navigationBar = NavigationBar()

    public let scrollableContentView: T

    public init(
        scrollableContentView: T = .init(),
        headerStyle: HeaderPresentableModel.Style? = nil
    ) {
        self.headerStyle = headerStyle
        self.scrollableContentView = scrollableContentView
        super.init(frame: .zero)

        initialSetup()
        
        if let headerStyle {
            navigationBar.display(style: headerStyle)
        }
        if #available(iOS 26, *), headerStyle?.backgroundColor == .clear {
            navigationBar.addScrollEdgeInteractionWith(scrollableContentView, at: .top)
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let navBarBottom = max(0, navigationBar.frame.maxY - scrollableContentView.frame.minY) / 2
        if navBarBottom != scrollableContentView.contentInset.top {
            scrollableContentView.contentInset.top = navBarBottom
        }
    }
}

extension BaseBarScrollableContentView {
    private func initialSetup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubviews(scrollableContentView, navigationBar)
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        scrollableContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

#endif
