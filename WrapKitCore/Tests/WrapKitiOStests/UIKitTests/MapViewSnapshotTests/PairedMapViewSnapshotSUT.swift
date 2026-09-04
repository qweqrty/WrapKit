import UIKit
import WrapKit

/// UIKit-only snapshot fixture. MapView does not expose a shared Output contract yet, so a separate
/// SwiftUI state model would not prove that the same presenter can drive both implementations.
final class PairedMapViewSnapshotSUT {
    let uiKitView: MapView<UIView>

    init(uiKitView: MapView<UIView> = MapView<UIView>(mapView: UIView())) {
        self.uiKitView = uiKitView
    }

    func setContentBackgroundColor(_ color: UIColor) {
        uiKitView.contentView.backgroundColor = color
    }

    func setGradientBackground(first: UIColor, second: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [first.cgColor, second.cgColor]
        gradientLayer.frame = uiKitView.contentView.bounds
        uiKitView.contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setPinsBackground(_ color: UIColor, alpha: CGFloat) {
        uiKitView.contentView.backgroundColor = color.withAlphaComponent(alpha)

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
    }

    func setLocationButtonHidden(_ isHidden: Bool) {
        uiKitView.locationView.isHidden = isHidden
    }

    func setActionsBackgroundColor(_ color: UIColor) {
        uiKitView.actionsStackView.backgroundColor = color
    }

    func setActionsHidden(_ isHidden: Bool) {
        uiKitView.actionsStackView.isHidden = isHidden
    }

    func setPlusButtonBackgroundColor(_ color: UIColor) {
        uiKitView.plusView.backgroundColor = color
    }

    func setMinusButtonBackgroundColor(_ color: UIColor) {
        uiKitView.minusView.backgroundColor = color
    }

    func setSeparatorColor(_ color: UIColor) {
        uiKitView.separatorView.backgroundColor = color
    }

    func setSeparatorHidden(_ isHidden: Bool) {
        uiKitView.separatorView.isHidden = isHidden
    }
}
