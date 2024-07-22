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
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTap))
        recognizer.minimumPressDuration = 1
        return recognizer
    }()
    
    public init(
        backgroundColor: UIColor? = nil,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = true
    ) {
        super.init(frame: .zero)
        
        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressRecognizer)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressRecognizer)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func didTap() {
        onPress?()
    }
    
    @objc private func didLongPress() {
        onLongPress?()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        self.alpha = 0.5
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
}
#endif
