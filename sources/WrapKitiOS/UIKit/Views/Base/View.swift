//
//  View.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class View: UIView {
    public var onPress: (() -> Void)?
    public var onLongPress: (() -> Void)?
    
    public init(
        backgroundColor: UIColor? = nil,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = true
    ) {
        super.init(frame: .zero)
        
        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressRecognizer.minimumPressDuration = 4
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func handleLongPress() {
        onLongPress?()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPressRecognizer)
    }
    
    private lazy var completionAnimation: ((Bool) -> Void) = { [weak self] finished in
        guard finished else { return }
        self?.isUserInteractionEnabled = true
        self?.onPress?()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onPress != nil else {
            super.touchesBegan(touches, with: event)
            return
        }
        isUserInteractionEnabled = false
        alpha = 1.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
            self.alpha = 0.5
        }, completion: self.completionAnimation)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onPress != nil else {
            super.touchesEnded(touches, with: event)
            return
        }
        isUserInteractionEnabled = false
        alpha = 0.5
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
            self.alpha = 1.0
        }, completion: self.completionAnimation)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onPress != nil else {
            super.touchesCancelled(touches, with: event)
            return
        }
        isUserInteractionEnabled = false
        alpha = 0.5
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
            self.alpha = 1.0
        }, completion: self.completionAnimation)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension View: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
#endif
