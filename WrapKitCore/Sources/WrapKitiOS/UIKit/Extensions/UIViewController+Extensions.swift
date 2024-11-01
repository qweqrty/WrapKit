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
}

#if canImport(UIKit)
import UIKit

extension UIViewController: AlertOutput {
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
                handler: { [weak alert, onCancelCompletion] (_) in
                    alert?.dismiss(animated: true)
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
        
    func showActionSheet(title: String?, text: String?, actions: [UIAlertAction], cancelText: String) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .actionSheet
        )
        actions.forEach { alert.addAction($0) }
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
#endif
