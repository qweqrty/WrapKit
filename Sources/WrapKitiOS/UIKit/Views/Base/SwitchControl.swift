//
//  SwitchControl.swift
//  WrapKit
//
//  Created by Stas Lee on 21/1/24.
//

#if canImport(UIKit)
import UIKit

open class SwitchControl: UISwitch {
    public var onPress: (() -> Void)?
    
    public init(tintColor: UIColor, onTintColor: UIColor? = nil) {
        super.init(frame: .zero)
        
        self.tintColor = tintColor
        self.onTintColor = onTintColor
        addTarget(self, action: #selector(didPress), for: .valueChanged)
    }
    
    @objc private func didPress() {
        onPress?()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
