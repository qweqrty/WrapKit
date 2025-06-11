//
//  CommonToastiOSAdapter.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

#if canImport(UIKit)
import UIKit

public class CommonToastiOSAdapter: CommonToastOutput {
    private var queue = Queue<CommonToast>()
    private var isDisplaying = false
    
    private let toastViewBuilder: ((CommonToast) -> ToastView?)?
    private var keyboardHeight: CGFloat = 0
    private var currentToastView: ToastView?
    
    public init(toastViewBuilder: ((CommonToast) -> ToastView?)?) {
        self.toastViewBuilder = toastViewBuilder
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func display(_ toast: CommonToast) {
        queue.enqueue(toast)
        showNextToast()
    }
    
    public func hide() {
        currentToastView?.hide(after: 0)
    }

    private func showNextToast() {
        guard !isDisplaying, let toast = queue.dequeue() else { return }
        currentToastView = toastViewBuilder?(toast)

        isDisplaying = true
        currentToastView?.keyboardHeight = keyboardHeight
        currentToastView?.onDismiss = { [weak self] in
            self?.currentToastView = nil
            self?.isDisplaying = false
            self?.showNextToast()
        }
        
        currentToastView?.show()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        keyboardHeight = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide() {
        keyboardHeight = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
#endif
