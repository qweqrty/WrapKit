#if os(iOS)
import UIKit

public final class ScreenShield {
    public static let shared = ScreenShield()
    private let maxAttempts = 5

    private init() {}

    public func protect(view: UIView) {
        protect(view: view, attempt: 0)
    }

    private func protect(view: UIView, attempt: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay(for: attempt)) { [weak view] in
            guard let view else { return }

            if view.setScreenCaptureProtection() {
                return
            }

            guard attempt < self.maxAttempts else { return }
            self.protect(view: view, attempt: attempt + 1)
        }
    }

    private func retryDelay(for attempt: Int) -> TimeInterval {
        if attempt == 0 {
            return 0
        }

        return 0.15
    }
}

public extension UIView {
    private enum Constants {
        static let secureTextFieldTag = 54_321
    }

    @discardableResult
    func setScreenCaptureProtection() -> Bool {
        if viewWithTag(Constants.secureTextFieldTag) is UITextField {
            return true
        }

        guard superview != nil else {
            let childApplied = subviews.contains { $0.setScreenCaptureProtection() }
            return childApplied
        }

        guard let superlayer = layer.superlayer else {
            return false
        }

        let secureTextField = UITextField()
        secureTextField.backgroundColor = .clear
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        secureTextField.tag = Constants.secureTextFieldTag
        secureTextField.isSecureTextEntry = true
        secureTextField.isUserInteractionEnabled = false

        insertSubview(secureTextField, at: 0)

        superlayer.addSublayer(secureTextField.layer)

        guard let secureContainerLayer = secureTextField.layer.sublayers?.last else {
            secureTextField.removeFromSuperview()
            secureTextField.layer.removeFromSuperlayer()
            return false
        }

        secureContainerLayer.addSublayer(layer)

        NSLayoutConstraint.activate([
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        return true
    }
}
#endif
