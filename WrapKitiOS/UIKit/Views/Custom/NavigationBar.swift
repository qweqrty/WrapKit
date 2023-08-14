//
//  NavigationBar.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class NavigationBar: UIView {
    public lazy var leadingStackView = StackView(axis: .horizontal, spacing: 12)
    public lazy var centerView = UIView()
    public lazy var trailingStackView = StackView(axis: .horizontal, spacing: 12)
    public lazy var mainStackView = StackView(axis: .horizontal, spacing: 8)
    
    public lazy var backButton = makeBackButton(imageName: "longBackArrow")
    public lazy var titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 18), textColor: .black, numberOfLines: 1),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 14), textColor: .black, numberOfLines: 1)
    )
    public lazy var closeButton = makeBackButton(imageName: "closeBtn", isHidden: true)
    
    private(set) var mainStackViewConstraints: AnchoredConstraints?
    
    private let height: CGFloat = 52
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        addSubviews(mainStackView)
        mainStackView.addArrangedSubview(leadingStackView)
        mainStackView.addArrangedSubview(centerView)
        mainStackView.addArrangedSubview(trailingStackView)
        leadingStackView.addArrangedSubview(backButton)
        centerView.addSubview(titleViews)
        trailingStackView.addArrangedSubview(closeButton)
        
        backButton.anchor(.width(36))
        closeButton.anchor(.width(36))
    }
    
    private func setupConstraints() {
        mainStackView.anchor(.height(height))
        mainStackViewConstraints = mainStackView.anchor(
            .top(safeAreaLayoutGuide.topAnchor),
            .leading(leadingAnchor, constant: 12),
            .trailing(trailingAnchor, constant: 12),
            .bottom(bottomAnchor)
        )
        trailingStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleViews.fillSuperview()
        titleViews.anchor(
            .centerX(centerXAnchor),
            .centerY(centerYAnchor)
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NavigationBar {
    func makeBackButton(imageName: String, isHidden: Bool = false) -> Button {
        let btn = Button(
            image: UIImage(named: imageName)!,
            tintColor: .black,
            isHidden: isHidden
        )
        return btn
    }
}
#endif
