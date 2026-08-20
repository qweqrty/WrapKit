//
//  SUIButton.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 15/4/26.
//

import Foundation
import SwiftUI

public struct SUIButton: View {
    @ObservedObject var stateModel: SUIButtonStateModel
    let pressAnimations: Set<PressAnimation>
    
    public init(
        adapter: ButtonOutputSwiftUIAdapter,
        loadingAdapter: LoadingOutputSwiftUIAdapter? = nil,
        pressAnimations: Set<PressAnimation> = []
    ) {
        self.stateModel = .init(adapter: adapter, loadingAdapter: loadingAdapter)
        self.pressAnimations = pressAnimations
    }
    
    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUIButtonView(
                model: stateModel.presentable,
                onPress: stateModel.presentable.onPress,
                isEnabled: stateModel.isEnabled,
                isLoading: stateModel.isLoading,
                pressAnimations: pressAnimations
            )
        }
    }
}

public struct SUIButtonView: View {
    let model: ButtonPresentableModel
    let onPress: (() -> Void)?
    let isEnabled: Bool
    let isLoading: Bool
    let pressAnimations: Set<PressAnimation>
    let fillsAvailableWidth: Bool
    let contentInsets: SwiftUI.EdgeInsets
    
    @State private var isPressed: Bool = false
    
    public init(
        model: ButtonPresentableModel,
        onPress: (() -> Void)? = nil,
        isEnabled: Bool,
        isLoading: Bool = false,
        pressAnimations: Set<PressAnimation> = [],
        fillsAvailableWidth: Bool = true,
        contentInsets: SwiftUI.EdgeInsets = .init()
    ) {
        self.model = model
        self.onPress = onPress
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.pressAnimations = pressAnimations
        self.fillsAvailableWidth = fillsAvailableWidth
        self.contentInsets = contentInsets
    }
    
    @ViewBuilder
    public var body: some View {
        if let glassConfiguration = model.style?.glassConfiguration,
           isLiquidGlassAvailable {
            glassButton(configuration: glassConfiguration)
        } else {
            legacyButton
        }
    }

    private var legacyButton: some View {
        baseButton
            .buttonStyle(PressableButtonStyle(isPressed: $isPressed, pressAnimations: pressAnimations))
    }

    @ViewBuilder
    private func glassButton(configuration: ButtonStyle.GlassConfiguration) -> some View {
        baseButton
            .wrapKitGlassButtonStyle(
                configuration,
                tint: glassTintColor,
                cornerStyle: buttonCornerStyle
            )
            .overlay(borderView)
    }

    private var baseButton: some View {
        SwiftUI.Button(
            action: { onPress?() },
            label: { buttonLabel }
        )
        .opacity(isEnabled ? 1.0 : 0.5)
        .disabled(!isEnabled)
        .accessibilityIdentifier(model.accessibilityIdentifier ?? "")
    }

    private var buttonLabel: some View {
        ZStack {
            HStack(spacing: model.spacing ?? 0) {
                if let image = model.image {
                    SwiftUIImage(image: image)
                }
                if let title = model.title {
                    Text(title.removingPercentEncoding ?? title)
                        .font(model.style?.font.map { SwiftUIFont($0) })
                        .foregroundColor(titleColor)
                }
            }
            .opacity(isLoading ? 0 : 1)
        }
        .frame(maxWidth: fillsAvailableWidth ? .infinity : nil)
        .frame(width: model.width, height: model.height)
        .padding(contentInsets)
        .background {
            if !isLiquidGlassAvailable || model.style?.glassConfiguration == nil {
                backgroundView
            }
        }
        .cornerStyle(buttonCornerStyle)
        .overlay {
            if !isLiquidGlassAvailable || model.style?.glassConfiguration == nil {
                borderView
            }
        }
    }

    private var isLiquidGlassAvailable: Bool {
        isAvailableOS26 && isLiquidGlassEnabled
    }

    private var buttonCornerStyle: CornerStyle {
        model.style?.cornerStyle ?? .fixed(ButtonStyle.defaultCornerRadius)
    }

    private var glassTintColor: SwiftUIColor? {
        model.style?.backgroundColor.map(SwiftUIColor.init)
    }

    private var titleColor: SwiftUIColor? {
        let color = isPressed ? model.style?.pressedTintColor : model.style?.titleColor
        return color.map(SwiftUIColor.init)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        SwiftUIColor(
            isPressed
            ? model.style?.pressedColor ?? model.style?.backgroundColor ?? .clear
            : model.style?.backgroundColor ?? .clear
        )
    }
    
    @ViewBuilder
    private var borderView: some View {
        if let borderColor = model.style?.borderColor,
           (model.style?.borderWidth ?? 0) > 0 {
            SUICornerShape(style: buttonCornerStyle)
                .stroke(SwiftUIColor(borderColor), lineWidth: model.style?.borderWidth ?? 0)
        }
    }
}

private struct PressableButtonStyle: SwiftUI.ButtonStyle {
    @Binding var isPressed: Bool
    let pressAnimations: Set<PressAnimation>
    
    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(
                pressAnimations.contains(.shrink) && configuration.isPressed ? 0.95 : 1.0
            )
            .animation(
                SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}
