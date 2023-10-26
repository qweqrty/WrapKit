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
    
    private let longPressThreshold: TimeInterval = 1.5
    private var pressStartTime: Date?
    private var longPressTimer: Timer?
    
    public init(
        backgroundColor: UIColor? = nil,
        isHidden: Bool = false,
        translatesAutoresizingMaskIntoConstraints: Bool = true
    ) {
        super.init(frame: .zero)
        
        self.isHidden = isHidden
        self.backgroundColor = backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        self.alpha = 0.5
        
        pressStartTime = Date()
        
        // Schedule the long press action
        longPressTimer = Timer.scheduledTimer(withTimeInterval: longPressThreshold, repeats: false, block: { [weak self] _ in
            self?.onLongPress?()
            self?.longPressTimer?.invalidate()
            self?.longPressTimer = nil
        })
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
        
        if let timer = longPressTimer, timer.isValid {
            timer.invalidate()
            onPress?()
        }
        
        pressStartTime = nil
        longPressTimer = nil
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard onLongPress != nil || onPress != nil else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
        
        pressStartTime = nil
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}
#endif
