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
    public let scrollView: T

    open var additionalInsets: UIEdgeInsets = .zero
    
    public init(
        scrollView: T = .init(),
        headerStyle: HeaderPresentableModel.Style? = nil
    ) {
        self.headerStyle = headerStyle
        self.scrollView = scrollView
        super.init(frame: .zero)

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
            scrollView.contentInset = .init(
                top: additionalInsets.top + navBarBottom,
                left: additionalInsets.left,
                bottom: additionalInsets.bottom,
                right: additionalInsets.right
            )
        }
    }
}

extension BaseBarScrollableContentView {
    private func initialSetup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubviews(scrollView, navigationBar)
    }
    
    private func setupConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

#endif
