#if os(iOS)
import UIKit

public class ScreenShield {
    public static let shared = ScreenShield()
    
    public func protect(window: UIWindow) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            window.setScreenCaptureProtection()
        })
    }
    
    public func protect(view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            view.setScreenCaptureProtection()
        })
    }
}

extension UIView {
    private struct Constants {
        static var secureTextFieldTag: Int { 54321 }
    }
    
    func setScreenCaptureProtection() {
        if viewWithTag(Constants.secureTextFieldTag) is UITextField {
            return
        }
        
        guard superview != nil else {
            for subview in subviews {
                subview.setScreenCaptureProtection()
            }
            return
        }
        
        let secureTextField = UITextField()
        secureTextField.backgroundColor = .clear
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        secureTextField.tag = Constants.secureTextFieldTag
        secureTextField.isSecureTextEntry = true
        
        insertSubview(secureTextField, at: 0)
        secureTextField.isUserInteractionEnabled = false
        
#if os(iOS)
        layer.superlayer?.addSublayer(secureTextField.layer)
        secureTextField.layer.sublayers?.last?.addSublayer(layer)
        
        secureTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        secureTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        secureTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        secureTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
#else
        secureTextField.frame = bounds
        secureTextField.wantsLayer = true
        secureTextField.layer?.addSublayer(layer!)
        addSubview(secureTextField)
#endif
    }
}
#endif
