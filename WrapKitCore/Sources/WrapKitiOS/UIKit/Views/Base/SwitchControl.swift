//
//  SwitchControl.swift
//  WrapKit
//
//  Created by Stas Lee on 21/1/24.
//
import Foundation

public protocol SwitchCotrolOutput: AnyObject {
    func display(model: SwitchControlPresentableModel?)
    func display(onPress: (() -> Void)?)
    func display(isOn: Bool)
    func display(isEnabled: Bool)
}

public struct SwitchControlPresentableModel {
    public let onPress: (() -> Void)?
    public let isOn: Bool?
    public let isEnabled: Bool?
    
    public init(
        onPress: (() -> Void)? = nil,
        isOn: Bool? = nil,
        isEnabled: Bool? = nil
    ) {
        self.onPress = onPress
        self.isOn = isOn
        self.isEnabled = isEnabled
    }
}

#if canImport(UIKit)
import UIKit

open class SwitchControl: UISwitch {
    public var onPress: (() -> Void)?
    
    public init() {
        super.init(frame: .zero)

        addTarget(self, action: #selector(didPress), for: .valueChanged)
    }
    
    @objc private func didPress() {
        onPress?()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SwitchControl: SwitchCotrolOutput {
    public func display(model: SwitchControlPresentableModel?) {
        isHidden = model == nil
        if let isOn = model?.isOn { display(isOn: isOn) }
        if let isEnabled = model?.isEnabled { display(isEnabled: isEnabled) }
        display(onPress: model?.onPress)
    }
    
    public func display(onPress: (() -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(isOn: Bool) {
        self.isOn = isOn
    }
    
    public func display(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
#endif
