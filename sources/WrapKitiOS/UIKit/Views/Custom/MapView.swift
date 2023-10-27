//
//  MapView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

open class MapView<ContentView: UIView>: UIView {
    public let contentView: ContentView
    public let actionsStackView = WrapperView(contentView: StackView(axis: .vertical))
    public lazy var locationView = makeImageView(UIImage(systemName: "location"))
    public lazy var plusView = makeImageView(UIImage(systemName: "plus"))
    public let separatorView = UIView(backgroundColor: .lightGray)
    public lazy var minusView = makeImageView(UIImage(systemName: "minus"))
    
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

@available(iOS 13.0, *)
struct MapViewFullRepresentable: UIViewRepresentable {
    var someView: UIView = .init()
    func makeUIView(context: Context) -> MapView<UIView> {
        let view = MapView(mapView: someView)
        view.backgroundColor = .red
        return view
    }
    
    func updateUIView(_ uiView: MapView<UIView>, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct MapView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
            MapViewFullRepresentable()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
    }
}
#endif
