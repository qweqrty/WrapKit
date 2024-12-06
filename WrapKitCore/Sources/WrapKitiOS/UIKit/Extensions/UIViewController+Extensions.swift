//
//  UIViewController+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol AlertOutput: AnyObject {
    func showDefaultPrompt(
        title: String?,
        text: String,
        cancelText: String,
        yesText: String,
        onCancelCompletion: (() -> Void)?,
        onYesCompletion: (() -> Void)?
    )
    
    func showAlert(
        text: String,
        okText: String
    )
    
    func showActionSheet(
        title: String?,
        text: String?,
        actions: [AlertAction],
        cancelText: String?
    )
}

#if canImport(UIKit)
import UIKit

extension UIViewController: AlertOutput {
    public func showAlert(text: String, okText: String) {
        let alert = UIAlertController(
            title: nil,
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: okText,
                style: .default
            )
        )
        present(alert, animated: true, completion: nil)
    }
    
    public func showDefaultPrompt(
        title: String?,
        text: String,
        cancelText: String,
        yesText: String,
        onCancelCompletion: (() -> Void)? = nil,
        onYesCompletion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: cancelText,
                style: .default,
                handler: { [onCancelCompletion] (_) in
                    onCancelCompletion?()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: yesText,
                style: .default,
                handler: { [onYesCompletion] (_) in
                    onYesCompletion?()
                }
            )
        )
        present(alert, animated: true, completion: nil)
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
        
    func showActionSheet(
        title: String? = nil,
        text: String? = nil,
        actions: [AlertAction],
        cancelText: String? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .actionSheet
        )
        
        actions.forEach { action in
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
        
        if let cancelText {
                alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
}
#endif

public struct AlertAction {
    public enum Style {
        case `default`
        case cancel
        case destructive
    }

    public let title: String
    public let style: Style
    public let handler: (() -> Void)?
    
    public init(title: String, style: Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
