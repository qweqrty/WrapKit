//
//  UIViewController+Extensions.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

public extension UIViewController {
    func showDefaultPrompt(title: String?, text: String, cancelText: String, yesText: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: cancelText,
                style: .default,
                handler: { [weak alert] (_) in
                    alert?.dismiss(animated: true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: yesText,
                style: .default,
                handler: { [completion] (_) in
                    completion()
                }
            )
        )
        present(alert, animated: true, completion: nil)
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
