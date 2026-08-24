//
//  SwitchControl.swift
//  WrapKit
//
//  Created by Stas Lee on 21/1/24.
//
import Foundation

public protocol SwitchCotrolOutput: AnyObject {
    func display(model: SwitchControlPresentableModel?)
    func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?)
    func display(isOn: Bool)
    func display(style: SwitchControlPresentableModel.Style?)
    func display(isEnabled: Bool)
    func display(isHidden: Bool)
}

public struct SwitchControlPresentableModel {
    public let accessibilityIdentifier: String?
    public let onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?
    public let isOn: Bool?
    public let isEnabled: Bool?
    public let style: Style?
    
    public init(
        accessibilityIdentifier: String? = nil,
        onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)? = nil,
        isOn: Bool? = nil,
        isEnabled: Bool? = nil,
        style: Style? = nil
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
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
        public let shimmerStyle: ShimmerStyle?

        public init(
            tintColor: Color,
            thumbTintColor: Color,
            backgroundColor: Color,
            cornerRadius: CGFloat,
            shimmerStyle: ShimmerStyle? = nil
        ) {
            self.tintColor = tintColor
            self.thumbTintColor = thumbTintColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.shimmerStyle = shimmerStyle
        }
    }
}

#if canImport(UIKit) && !os(watchOS)
import UIKit

#if os(tvOS)
open class SwitchControl: UISegmentedControl {
    public var onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?
    public var isLoading: Bool?
    private var switchStyle: SwitchControlPresentableModel.Style? {
        didSet {
            display(style: switchStyle)
        }
    }
    private var wasUserSwitched = false

    public var isOn: Bool {
        get { selectedSegmentIndex == 1 }
        set { selectedSegmentIndex = newValue ? 1 : 0 }
    }

    public init() {
        super.init(items: Self.makeItems())
        commonInit()
    }

    public init(style: SwitchControlPresentableModel.Style) {
        super.init(items: Self.makeItems())
        commonInit()
        self.switchStyle = style
        display(style: style)
    }

    private static func makeItems() -> [Any] {
        [
            WrapKit.Image(systemName: "xmark") as Any,
            WrapKit.Image(systemName: "checkmark") as Any
        ]
    }

    private func commonInit() {
        selectedSegmentIndex = 0
        addTarget(self, action: #selector(didPress), for: .valueChanged)
    }

    public func setOn(_ on: Bool, animated: Bool) {
        selectedSegmentIndex = on ? 1 : 0
    }

    @objc private func didPress() {
        wasUserSwitched = true
        onPress?(self)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#else
open class SwitchControl: UISwitch {
    public var onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?
    public var isLoading: Bool?
    private var switchStyle: SwitchControlPresentableModel.Style? {
        didSet {
            display(style: switchStyle)
        }
    }
    private var wasUserSwitched = false
    
    public init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(didPress), for: .valueChanged)
    }
    
    public init(style: SwitchControlPresentableModel.Style) {
        super.init(frame: .zero)
        addTarget(self, action: #selector(didPress), for: .valueChanged)
        self.switchStyle = style
        display(style: style)
    }
    
    @objc private func didPress() {
        wasUserSwitched = true
        onPress?(self)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif

extension SwitchControl: SwitchCotrolOutput {
    
    public func display(model: SwitchControlPresentableModel?) {
        isHidden = model == nil
        
        if let accessibilityIdentifier = model?.accessibilityIdentifier {
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        if let isOn = model?.isOn { display(isOn: isOn) }
        if let isEnabled = model?.isEnabled { display(isEnabled: isEnabled) }
        if let style = model?.style {
            switchStyle = style
        }
        display(onPress: model?.onPress)
    }
    
    public func display(style: SwitchControlPresentableModel.Style?) {
        #if os(tvOS)
        selectedSegmentTintColor = style?.tintColor
        #else
        onTintColor = style?.tintColor
        thumbTintColor = style?.thumbTintColor
        #endif
        backgroundColor = style?.backgroundColor
        cornerRadius = style?.cornerRadius ?? 0
    }
    
    public func display(onPress: ((SwitchCotrolOutput & LoadingOutput) -> Void)?) {
        self.onPress = onPress
    }
    
    public func display(isOn: Bool) {
        if self.isTracking { return }

        setOn(isOn, animated: wasUserSwitched)
        wasUserSwitched = false
    }
    
    public func display(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    public func display(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

extension SwitchControl: LoadingOutput {
    public func display(isLoading: Bool) {
        if isLoading {
            let shimmerView = ShimmerView(backgroundColor: switchStyle?.backgroundColor ?? .clear)
            shimmerView.style = switchStyle?.shimmerStyle
            showShimmer(shimmerView, heightMultiplier: 1, widthMultiplier: 1.1)
        } else {
            hideShimmer()
        }
    }
}
#endif
