//
//  CommonToastiOSAdapter.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

#if canImport(UIKit)
import UIKit

public class CommonToastiOSAdapter: CommonToastOutput {
    private var queue: [ToastView] = []
    private var isDisplaying = false
    
    private let toastViewBuilder: ((CommonToast) -> ToastView?)?
    
    public init(toastViewBuilder: ((CommonToast) -> ToastView?)?) {
        self.toastViewBuilder = toastViewBuilder
    }
    
    public func display(_ toast: CommonToast) {
        guard let toastView = toastViewBuilder?(toast) else { return }
        queue.append(toastView)
        showNextToast()
    }

    private func showNextToast() {
        guard !isDisplaying, let nextToast = queue.first else { return }
        isDisplaying = true
        queue.removeFirst()
        
        nextToast.onDismiss = { [weak self] in
            self?.isDisplaying = false
            self?.showNextToast()
        }
        
        nextToast.show()
    }
}
#endif
