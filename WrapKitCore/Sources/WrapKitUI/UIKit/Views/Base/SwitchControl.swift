//
//  SwitchControl.swift
//  WrapKit
//
//  Created by Stas Lee on 21/1/24.
//
import Foundation

public protocol SwitchCotrolOutput: AnyObject {
    func display(model: SwitchControlPresentableModel?)
    func display(onPress: ((SwitchCotrolOutput) -> Void)?)
    func display(isOn: Bool)
    func display(style: SwitchControlPresentableModel.Style)
    func display(isEnabled: Bool)
    func display(isHidden: Bool)
    
    func display(isLoading: Bool, shimmerStyle: ShimmerStyle?)
}

public struct SwitchControlPresentableModel {
    public let onPress: ((SwitchCotrolOutput) -> Void)?
    public let isOn: Bool?
    public let isEnabled: Bool?
    public let style: Style?
    
    public init(
        onPress: ((SwitchCotrolOutput) -> Void)? = nil,
        isOn: Bool? = nil,
        isEnabled: Bool? = nil,
        style: Style? = nil
    ) {
        self.onPress = onPress
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.style = style
    }
    
    public struct Style {
        public let tintColor: Color
        public let thumbTintColor: Color
        public let backgroundColor: Color
        public let cornerRadius: CGFloat
        
        public init(
            tintColor: Color,
            thumbTintColor: Color,
            backgroundColor: Color,
            cornerRadius: CGFloat
        ) {
            self.tintColor = tintColor
            self.thumbTintColor = thumbTintColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
        }
    }
}

#if canImport(UIKit)
import UIKit

open class SwitchControl: UISwitch {
    public var onPress: ((SwitchCotrolOutput) -> Void)?
    
    public init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(didPress), for: .valueChanged)
    }
    
    public init(style: SwitchControlPresentableModel.Style) {
        super.init(frame: .zero)
        addTarget(self, action: #selector(didPress), for: .valueChanged)
        display(style: style)
    }
    
    @objc private func didPress() {
        onPress?(self)
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
        if let style = model?.style { display(style: style) }
        display(onPress: model?.onPress)
    }
    
    public func display(style: SwitchControlPresentableModel.Style) {
        tintColor = style.tintColor
        thumbTintColor = style.thumbTintColor
        backgroundColor = style.backgroundColor
        cornerRadius = style.cornerRadius
    }
    
    public func display(onPress: ((SwitchCotrolOutput) -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(isOn: Bool) {
        self.isOn = isOn
    }
    
    public func display(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
    
    public func display(isLoading: Bool, shimmerStyle: ShimmerStyle?) {
        var shimmerView: ShimmerView? = nil
        if let shimmerStyle {
            shimmerView = ShimmerView(backgroundColor: shimmerStyle.backgroundColor)
            shimmerView?.style = shimmerStyle
        }
        
        isLoading
        ? self.showShimmer(shimmerView, heightMultiplier: 1, widthMultiplier: 1.1)
        : self.hideShimmer()
    }
}
#endif
