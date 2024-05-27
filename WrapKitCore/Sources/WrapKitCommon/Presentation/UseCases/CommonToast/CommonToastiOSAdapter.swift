//
//  CommonToastiOSDecorator.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

#if canImport(UIKit)
import UIKit

public class CommonToastiOSAdapter: CommonToastOutput {
    private let onView: UIView
    private let toastViewBuilder: ((CommmonToast) -> ToastView)?
    private let position: ToastView.Position
    
    public init(
        onView: UIView,
        toastViewBuilder: ((CommmonToast) -> ToastView)?,
        position: ToastView.Position
    ) {
        self.onView = onView
        self.toastViewBuilder = toastViewBuilder
        self.position = position
    }
    
    public func display(_ toast: CommmonToast) {
        guard let toastView = toastViewBuilder?(toast) else { return }
        toastView.removePastToastIfNeeded(from: onView)
        toastView.setPosition(on: onView, position: position)
        toastView.animate(constant: 20, inside: onView) { [weak self, weak toastView] _ in
            guard let self = self else { return }
            toastView?.hide(after: toast.duration, for: self.onView)
        }
    }
}
#endif
