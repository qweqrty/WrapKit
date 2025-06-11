//
//  CommonToastiOSAdapter.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

#if canImport(UIKit)
import UIKit

public class CommonToastiOSAdapter: CommonToastOutput {
    private var queue = Queue<ToastView>()
    private var isDisplaying = false
    
    private let toastViewBuilder: ((CommonToast) -> ToastView?)?
    private var keyboardHeight: CGFloat = 0
    private var currentToast: ToastView?
    
    public init(toastViewBuilder: ((CommonToast) -> ToastView?)?) {
        self.toastViewBuilder = toastViewBuilder
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func display(_ toast: CommonToast) {
        guard let toastView = toastViewBuilder?(toast) else { return }
        queue.enqueue(toastView)
        showNextToast()
    }
    
    public func hide() {
        currentToast?.hide(after: 0)
    }

    private func showNextToast() {
        guard !isDisplaying else { return }
        currentToast = queue.dequeue()
        isDisplaying = true
        currentToast?.keyboardHeight = keyboardHeight
        currentToast?.onDismiss = { [weak self] in
            self?.currentToast = nil
            self?.isDisplaying = false
            self?.showNextToast()
        }
        
        currentToast?.show()
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
