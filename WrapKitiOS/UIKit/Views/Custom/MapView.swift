//
//  MapView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit

open class MapView<ContentView: UIView>: UIView {
    public let contentView: ContentView
    public let actionsStackView = WrapperView(contentView: StackView(axis: .vertical))
    public lazy var locationView = makeImageView(UIImage(named: "cursorIc"))
    public lazy var plusView = makeImageView(UIImage(named: "plusIc"))
    public let separatorView = UIView(backgroundColor: .lightGray)
    public lazy var minusView = makeImageView(UIImage(named: "minusIc"))
    
    public init(mapView: ContentView) {
        self.contentView = mapView
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        actionsStackView.contentView.isUserInteractionEnabled = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        actionsStackView.layer.cornerRadius = 8
        actionsStackView.layer.masksToBounds = true
        actionsStackView.clipsToBounds = true
        locationView.layer.cornerRadius = 8
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapView {
    func setupSubviews() {
        addSubview(contentView)
        contentView.addSubviews(locationView, actionsStackView)
        actionsStackView.contentView.addArrangedSubview(plusView)
        actionsStackView.contentView.addArrangedSubview(separatorView)
        actionsStackView.contentView.addArrangedSubview(minusView)
    }
    
    func setupConstraints() {
        contentView.fillSuperview()
        separatorView.constrainHeight(2)
        locationView.anchor(
            .bottom(actionsStackView.topAnchor, constant: 10),
            .trailing(actionsStackView.trailingAnchor),
            .leading(actionsStackView.leadingAnchor)
        )
        
        actionsStackView.anchor(
            .width(36),
            .trailing(contentView.trailingAnchor, constant: 12),
            .bottom(contentView.bottomAnchor, constant: 12)
        )
        locationView.constrainHeight(36)
        plusView.constrainHeight(36)
        minusView.constrainHeight(36)
    }
}

private extension MapView {
    func makeImageView(_ image: UIImage? = nil) -> Button {
        let view = Button(
            image: image,
            tintColor: .gray,
            contentInset: .init(top: 6, left: 6, bottom: 6, right: 6)
        )
        view.backgroundColor = .white
        return view
    }
}
#endif
