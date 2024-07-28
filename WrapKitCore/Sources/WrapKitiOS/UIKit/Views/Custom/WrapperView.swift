//
//  WrapperView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class WrapperView<ContentView: UIView>: View {
    public let contentView: ContentView
    
    public var contentViewConstraints: AnchoredConstraints?
    
    public init(
        contentView: ContentView = ContentView(),
        backgroundColor: UIColor = .clear,
        isHidden: Bool = false,
        isUserInteractionEnabled: Bool = true,
        contentViewConstraints: ((ContentView, UIView) -> AnchoredConstraints)
    ) {
        self.contentView = contentView
        super.init(frame: .zero)
        addSubview(contentView)
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.backgroundColor = backgroundColor
        self.contentViewConstraints = contentViewConstraints(contentView, self)
        self.isHidden = isHidden
    }
    
    public override init(frame: CGRect) {
        contentView = ContentView()
        super.init(frame: frame)
        addSubview(contentView)
        contentViewConstraints = contentView.fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
