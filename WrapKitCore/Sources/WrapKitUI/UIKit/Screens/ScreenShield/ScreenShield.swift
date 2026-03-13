#if os(iOS)
import UIKit

public final class ScreenShield {
    public static let shared = ScreenShield()

    private init() {}

    public func protect(view: UIView) {
        DispatchQueue.main.async {
            view.setScreenCaptureProtection()
        }
    }
}

public extension UIView {
    private enum Constants {
        static let secureTextFieldTag = 54_321
    }

    func setScreenCaptureProtection() {
        if viewWithTag(Constants.secureTextFieldTag) is UITextField {
            return
        }

        guard superview != nil else {
            subviews.forEach { $0.setScreenCaptureProtection() }
            return
        }

        let secureTextField = UITextField()
        secureTextField.backgroundColor = .clear
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        secureTextField.tag = Constants.secureTextFieldTag
        secureTextField.isSecureTextEntry = true
        secureTextField.isUserInteractionEnabled = false

        insertSubview(secureTextField, at: 0)

        layer.superlayer?.addSublayer(secureTextField.layer)
        secureTextField.layer.sublayers?.last?.addSublayer(layer)

        NSLayoutConstraint.activate([
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
#endif
