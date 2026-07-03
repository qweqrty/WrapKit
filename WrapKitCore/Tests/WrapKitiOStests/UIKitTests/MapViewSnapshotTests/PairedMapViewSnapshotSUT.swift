//
//  PairedMapViewSnapshotSUT.swift
//  WrapKitTests
//

import SwiftUI
import UIKit
import WrapKit
import WrapKitTestUtils

final class PairedMapViewSnapshotSUT {
    let uiKitView: MapView<UIView>
    let stateModel: SUIMapViewStateModel

    init(
        uiKitView: MapView<UIView> = MapView<UIView>(mapView: UIView()),
        stateModel: SUIMapViewStateModel = SUIMapViewStateModel()
    ) {
        self.uiKitView = uiKitView
        self.stateModel = stateModel
    }

    func setContentBackgroundColor(_ color: UIColor) {
        uiKitView.contentView.backgroundColor = color
        stateModel.content = .color(color)
    }

    func setGradientBackground(first: UIColor, second: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            first.cgColor,
            second.cgColor
        ]
        gradientLayer.frame = uiKitView.contentView.bounds
        uiKitView.contentView.layer.insertSublayer(gradientLayer, at: 0)
        stateModel.content = .image(makeGradientImage(from: gradientLayer))
    }

    func setPinsBackground(_ color: UIColor, alpha: CGFloat) {
        uiKitView.contentView.backgroundColor = color.withAlphaComponent(alpha)
        stateModel.content = .pins(backgroundColor: color, alpha: alpha)

        for index in 0..<3 {
            let pin = UIView()
            pin.backgroundColor = .systemRed
            pin.layer.cornerRadius = 10
            uiKitView.contentView.addSubview(pin)
            pin.anchor(
                .top(uiKitView.contentView.topAnchor, constant: CGFloat(30 + index * 40)),
                .leading(uiKitView.contentView.leadingAnchor, constant: CGFloat(50 + index * 60)),
                .width(20),
                .height(20)
            )
        }
    }

    private func makeGradientImage(from gradientLayer: CAGradientLayer) -> UIImage {
        let format = UIGraphicsImageRendererFormat(for: uiKitView.traitCollection)
        format.scale = UIScreen.main.scale
        format.preferredRange = .extended
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(bounds: gradientLayer.bounds, format: format)
        return renderer.image { context in
            gradientLayer.render(in: context.cgContext)
        }
    }

    func setLocationButton(
        backgroundColor: UIColor,
        borderWidth: CGFloat = 0,
        borderColor: UIColor? = nil,
        isHidden: Bool? = nil
    ) {
        uiKitView.locationView.backgroundColor = backgroundColor
        uiKitView.locationView.layer.borderWidth = borderWidth
        uiKitView.locationView.layer.borderColor = borderColor?.cgColor
        if let isHidden {
            uiKitView.locationView.isHidden = isHidden
        }
        stateModel.locationButton = .init(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            isHidden: isHidden ?? stateModel.locationButton.isHidden
        )
    }

    func setLocationButtonHidden(_ isHidden: Bool) {
        uiKitView.locationView.isHidden = isHidden
        stateModel.locationButton.isHidden = isHidden
    }

    func setActionsBackgroundColor(_ color: UIColor) {
        uiKitView.actionsStackView.backgroundColor = color
        stateModel.actionsBackgroundColor = color
    }

    func setActionsHidden(_ isHidden: Bool) {
        uiKitView.actionsStackView.isHidden = isHidden
        stateModel.isActionsHidden = isHidden
    }

    func setPlusButtonBackgroundColor(_ color: UIColor) {
        uiKitView.plusView.backgroundColor = color
        stateModel.plusButton.backgroundColor = color
    }

    func setMinusButtonBackgroundColor(_ color: UIColor) {
        uiKitView.minusView.backgroundColor = color
        stateModel.minusButton.backgroundColor = color
    }

    func setSeparatorColor(_ color: UIColor) {
        uiKitView.separatorView.backgroundColor = color
        stateModel.separatorColor = color
    }

    func setSeparatorHidden(_ isHidden: Bool) {
        uiKitView.separatorView.isHidden = isHidden
        stateModel.isSeparatorHidden = isHidden
    }

    @available(iOS 17.0, *)
    func swiftUISnapshot(for colorScheme: ColorScheme) -> UIImage {
        let rootView = VStack(spacing: 0) {
            SUIMapView(stateModel: stateModel)
                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(SwiftUIColor.clear)
        .ignoresSafeArea(.all)

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        return hostingController.snapshot(
            for: .iPhone(style: colorScheme == .dark ? .dark : .light)
        )
    }
}
