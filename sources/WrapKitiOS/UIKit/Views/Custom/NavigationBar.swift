//
//  NavigationBar.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

open class NavigationBar: UIView {
    public lazy var leadingStackView = StackView(axis: .horizontal, spacing: 12)
    public lazy var centerView = UIView()
    public lazy var trailingStackView = StackView(axis: .horizontal, spacing: 12, isHidden: true)
    public lazy var mainStackView = StackView(axis: .horizontal, spacing: 8)
    
    public lazy var backButton = makeBackButton(imageName: "arrow.left")
    public lazy var titleViews = VKeyValueFieldView(
        keyLabel: Label(font: .systemFont(ofSize: 18), textColor: .black, textAlignment: .center, numberOfLines: 1),
        valueLabel: Label(isHidden: true, font: .systemFont(ofSize: 14), textColor: .black, numberOfLines: 1)
    )
    public lazy var closeButton = makeBackButton(imageName: "xmark")
    
    public var mainStackViewConstraints: AnchoredConstraints?
    
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
        titleViews.anchor(
            .top(centerView.topAnchor),
            .bottom(centerView.bottomAnchor),
            .leadingLessThanEqual(centerView.leadingAnchor),
            .trailingGreaterThanEqual(centerView.trailingAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NavigationBar {
    func makeBackButton(imageName: String, isHidden: Bool = false) -> Button {
        let btn = Button(
            image: UIImage(systemName: imageName),
            tintColor: .black,
            isHidden: isHidden
        )
        return btn
    }
}

@available(iOS 13.0, *)
struct NavigationBarRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> NavigationBar {
        let view = NavigationBar()
        view.trailingStackView.isHidden = false
        return view
    }
    
    func updateUIView(_ uiView: NavigationBar, context: Context) {
        // Leave this empty
    }
}

struct NavigationBarKeyLabelValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> NavigationBar {
        let view = NavigationBar()
        view.trailingStackView.isHidden = false
        view.titleViews.keyLabel.text = "Key Label"
        view.titleViews.valueLabel.text = "Value Labels"
        view.titleViews.valueLabel.isHidden = false
        return view
    }
    
    func updateUIView(_ uiView: NavigationBar, context: Context) {
        // Leave this empty
    }
}

struct NavigationBarKeyLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> NavigationBar {
        let view = NavigationBar()
        view.trailingStackView.isHidden = false
        view.titleViews.keyLabel.text = "Key Label"
        view.titleViews.valueLabel.isHidden = false
        return view
    }
    
    func updateUIView(_ uiView: NavigationBar, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct NavigationBar_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        VStack {
            NavigationBarRepresentable()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
            
            NavigationBarKeyLabelValueLabelRepresentable()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
            
            NavigationBarKeyLabelRepresentable()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
        }
    }
}
#endif
