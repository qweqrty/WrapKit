//
//  UIViewController+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol AlertOutput: AnyObject {
    func showAlert(model: AlertPresentableModel?)
    func showActionSheet(model: AlertPresentableModel?)
    func showTextFieldAlert(model: AlertPresentableModel?)
}

public struct AlertPresentableModel {
    public let title: String?
    public let text: String?
    public let placeholder: String?
    public let actions: [AlertAction]
    public let cancelText: String?
    
    public init(
        title: String? = nil,
        text: String? = nil,
        placeholder: String? = nil,
        actions: [AlertAction] = [],
        cancelText: String? = nil
    ) {
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.actions = actions
        self.cancelText = cancelText
    }
}

#if canImport(UIKit)
import UIKit

extension UIViewController: AlertOutput {
    public func showTextFieldAlert(model: AlertPresentableModel?) {
            guard let model = model else { return }
            
            CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue) { [weak self] in
                let alert = makeAlertController(
                    title: model.title,
                    message: model.text,
                    preferredStyle: .alert
                )
                
                alert.addTextField { textField in
                    textField.placeholder = model.placeholder
                }
                
                model.actions.forEach { action in
                    let style: UIAlertAction.Style
                    switch action.style {
                    case .default: style = .default
                    case .cancel: style = .cancel
                    case .destructive: style = .destructive
                    }
                    
                    let uiAction = UIAlertAction(title: action.title, style: style) { _ in
                        if action.style != .cancel, let textField = alert.textFields?.first {
                            action.inputHandler?(textField.text ?? "")
                        } else {
                            action.inputHandler?("")
                        }
                        action.handler?()
                    }
                    uiAction.accessibilityIdentifier = action.accessibilityIdentifier
                    alert.addAction(uiAction)
                }
                
                if let cancelText = model.cancelText {
                    alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
                }
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    
    public func showAlert(model: AlertPresentableModel?) {
        guard let model = model else { return }
        CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue) { [weak self] in
            let alert = makeAlertController(
                title: model.title,
                message: model.text,
                preferredStyle: .alert
            )
            model.actions.forEach { action in
                let style: UIAlertAction.Style
                switch action.style {
                case .default: style = .default
                case .cancel: style = .cancel
                case .destructive: style = .destructive
                }
                
                let uiAction = UIAlertAction(title: action.title, style: style) { _ in
                    action.handler?()
                }
                uiAction.accessibilityIdentifier = action.accessibilityIdentifier
                alert.addAction(uiAction)
            }
            
            if let cancelText = model.cancelText {
                alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
            }
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showActionSheet(model: AlertPresentableModel?) {
        guard let model = model else { return }
        CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue) { [weak self] in
            let alert = UIAlertController(
                title: model.title,
                message: model.text,
                preferredStyle: .actionSheet
            )
            
            model.actions.forEach { action in
                let style: UIAlertAction.Style
                switch action.style {
                case .default: style = .default
                case .cancel: style = .cancel
                case .destructive: style = .destructive
                }
                
                let uiAction = UIAlertAction(title: action.title, style: style) { _ in
                    action.handler?()
                }
                uiAction.accessibilityIdentifier = action.accessibilityIdentifier
                alert.addAction(uiAction)
            }
            
            if let cancelText = model.cancelText {
                alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
            }
            self?.present(alert, animated: true, completion: nil)
        }
    }
}

private func makeAlertController(
    title: String?,
    message: String?,
    preferredStyle: UIAlertController.Style
) -> UIAlertController {
    if #available(iOS 26.0, *) {
        return CenteredAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
    }

    return UIAlertController(
        title: title,
        message: message,
        preferredStyle: preferredStyle
    )
}

@available(iOS 26.0, *)
private final class CenteredAlertController: UIAlertController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerTextIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerTextIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        centerTextIfNeeded()
    }
}

private extension UIAlertController {
    func centerTextIfNeeded() {
        guard #available(iOS 26.0, *) else { return }

        let alertTexts = Set([title, message].compactMap { $0 })
        view.allSubviews
            .compactMap { $0 as? UILabel }
            .filter { label in
                guard let text = label.text else { return false }
                return alertTexts.contains(text)
            }
            .forEach { label in
                if let attributedText = label.attributedText, attributedText.length > 0 {
                    let currentStyle = attributedText.attribute(
                        .paragraphStyle,
                        at: 0,
                        effectiveRange: nil
                    ) as? NSParagraphStyle
                    let paragraphStyle = currentStyle?.mutableCopy() as? NSMutableParagraphStyle
                        ?? NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center

                    let centeredText = NSMutableAttributedString(attributedString: attributedText)
                    centeredText.addAttribute(
                        .paragraphStyle,
                        value: paragraphStyle,
                        range: NSRange(location: 0, length: centeredText.length)
                    )
                    label.attributedText = centeredText
                }
                label.textAlignment = .center
            }
    }
}

public extension UIViewController {
    var window: UIView? {
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return window
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window {
                return window
            }
        }
        return nil
    }
}
#endif

public struct AlertAction {
    public enum Style {
        case `default`
        case cancel
        case destructive
    }

    public let accessibilityIdentifier: String?
    public let title: String
    public let style: Style
    public let handler: (() -> Void)?
    public let inputHandler: ((String) -> Void)?
    
    public init(
        accessibilityIdentifier: String? = nil,
        title: String,
        style: Style = .default,
        handler: (() -> Void)? = nil,
        inputHandler: ((String) -> Void)? = nil
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.title = title
        self.style = style
        self.handler = handler
        self.inputHandler = inputHandler
    }
}
