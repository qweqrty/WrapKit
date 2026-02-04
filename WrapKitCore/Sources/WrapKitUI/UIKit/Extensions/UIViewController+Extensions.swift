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
                let alert = UIAlertController(
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
            let alert = UIAlertController(
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

                if let id = action.accessibilityIdentifier {
                    uiAction.setValue(id, forKey: "accessibilityIdentifier")
                }
                alert.addAction(uiAction)
            }
            
            if let cancelText = model.cancelText {
                alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
            }
            self?.present(alert, animated: true, completion: nil)
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
