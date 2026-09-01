//
//  SUIButton.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 15/4/26.
//

import Foundation
import SwiftUI

typealias SUIButtonLoadingIndicatorPhase = SUICircleStrokeSpinPhase

public struct SUIButton: View {
    @StateObject var stateModel: SUIButtonStateModel
    let pressAnimations: Set<PressAnimation>
    let loadingIndicatorPhase: SUIButtonLoadingIndicatorPhase
    
    public init(
        adapter: ButtonOutputSwiftUIAdapter,
        loadingAdapter: LoadingOutputSwiftUIAdapter? = nil,
        pressAnimations: Set<PressAnimation> = []
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter, loadingAdapter: loadingAdapter))
        self.pressAnimations = pressAnimations
        self.loadingIndicatorPhase = .animated
    }

    init(
        stateModel: SUIButtonStateModel,
        pressAnimations: Set<PressAnimation> = [],
        loadingIndicatorPhase: SUIButtonLoadingIndicatorPhase = .animated
    ) {
        _stateModel = .init(wrappedValue: stateModel)
        self.pressAnimations = pressAnimations
        self.loadingIndicatorPhase = loadingIndicatorPhase
    }
    
    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUIButtonView(
                model: stateModel.presentable,
                onPress: stateModel.presentable.onPress,
                isEnabled: stateModel.isEnabled,
                isLoading: stateModel.isLoading,
                pressAnimations: pressAnimations,
                loadingIndicatorPhase: loadingIndicatorPhase
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
    let fillsAvailableHeight: Bool
    let contentInsets: SwiftUI.EdgeInsets
    let loadingIndicatorPhase: SUIButtonLoadingIndicatorPhase
    
    @State private var isPressed: Bool = false
    
    public init(
        model: ButtonPresentableModel,
        onPress: (() -> Void)? = nil,
        isEnabled: Bool,
        isLoading: Bool = false,
        pressAnimations: Set<PressAnimation> = [],
        fillsAvailableWidth: Bool = true,
        fillsAvailableHeight: Bool = true,
        contentInsets: SwiftUI.EdgeInsets = .init()
    ) {
        self.model = model
        self.onPress = onPress
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.pressAnimations = pressAnimations
        self.fillsAvailableWidth = fillsAvailableWidth
        self.fillsAvailableHeight = fillsAvailableHeight
        self.contentInsets = contentInsets
        self.loadingIndicatorPhase = .animated
    }

    init(
        model: ButtonPresentableModel,
        onPress: (() -> Void)?,
        isEnabled: Bool,
        isLoading: Bool,
        pressAnimations: Set<PressAnimation>,
        fillsAvailableWidth: Bool = true,
        fillsAvailableHeight: Bool = true,
        contentInsets: SwiftUI.EdgeInsets = .init(),
        loadingIndicatorPhase: SUIButtonLoadingIndicatorPhase
    ) {
        self.model = model
        self.onPress = onPress
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.pressAnimations = pressAnimations
        self.fillsAvailableWidth = fillsAvailableWidth
        self.fillsAvailableHeight = fillsAvailableHeight
        self.contentInsets = contentInsets
        self.loadingIndicatorPhase = loadingIndicatorPhase
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
        .disabled(!isEnabled)
        .allowsHitTesting(onPress != nil && isEnabled)
        .if(onPress == nil) { view in
            view
                .accessibilityRemoveTraits(.isButton)
                .accessibilityAddTraits(.isStaticText)
        }
        .ifLet(model.accessibilityIdentifier) { view, identifier in
            view.accessibilityIdentifier(identifier)
        }
        .ifLet(model.accessibility?.label) { view, label in
            view.accessibilityLabel(Text(label))
        }
        .ifLet(model.accessibility?.hint) { view, hint in
            view.accessibilityHint(Text(hint))
        }
        .if(!isEnabled) { view in
            view.compositingGroup().opacity(0.5)
        }
    }

    @ViewBuilder
    private var buttonLabel: some View {
        if let requestedHeight = model.height {
            decoratedButtonLabel(height: requestedHeight)
        } else {
            decoratedButtonLabel(fillsAvailableHeight: fillsAvailableHeight)
        }
    }

    private var buttonLabelContent: some View {
        ZStack {
            legacySpacedContent
                .opacity(isLoading ? 0 : 1)

            if isLoading {
                SUICircleStrokeSpin(
                    color: SwiftUIColor(model.style?.loadingIndicatorColor ?? .red),
                    size: CGSize(width: 30, height: 30),
                    phase: loadingIndicatorPhase
                )
            }
        }
        .padding(contentInsets)
    }

    @ViewBuilder
    private var legacySpacedContent: some View {
        let content = HStack(spacing: model.spacing ?? 0) {
            if let image = model.image {
                SwiftUIImage(image: image)
                    .renderingMode(image.swiftUIRenderingMode)
                    .foregroundColor(.accentColor)
            }
            if let title = model.title {
                Text(title.removingPercentEncoding ?? title)
                    .font(titleFont)
                    .foregroundColor(titleColor)
                    .opacity(isEnabled ? 1 : 0.5)
            }
        }

        if usesLiquidGlassConfiguration || (model.spacing ?? 0) == 0 {
            content
        } else if model.image != nil, model.title != nil {
            content.padding(.trailing, model.spacing ?? 0)
        } else if model.image != nil {
            content.padding(.trailing, (model.spacing ?? 0) * 2)
        } else if model.title != nil {
            content.padding(.horizontal, model.spacing ?? 0)
        } else {
            content.padding(.trailing, (model.spacing ?? 0) * 2)
        }
    }

    private func decoratedButtonLabel(
        height: CGFloat? = nil,
        fillsAvailableHeight: Bool = false
    ) -> some View {
        buttonLabelContent
            .frame(
                maxWidth: fillsAvailableWidth ? .infinity : nil,
                maxHeight: fillsAvailableHeight ? .infinity : nil
            )
            .frame(width: model.width, height: height)
            .background {
                if !isLiquidGlassAvailable || model.style?.glassConfiguration == nil {
                    backgroundView
                }
            }
            .clipShape(SUIButtonCornerShape(style: buttonCornerStyle))
            .overlay {
                if !isLiquidGlassAvailable || model.style?.glassConfiguration == nil {
                    borderView
                }
            }
    }

    private var isLiquidGlassAvailable: Bool {
        isAvailableOS26 && isLiquidGlassEnabled
    }

    private var usesLiquidGlassConfiguration: Bool {
        isLiquidGlassAvailable && model.style?.glassConfiguration != nil
    }

    private var buttonCornerStyle: CornerStyle {
        model.style?.cornerStyle ?? .fixed(ButtonStyle.defaultCornerRadius)
    }

    private var glassTintColor: SwiftUIColor? {
        model.style?.backgroundColor.map(SwiftUIColor.init)
    }

    private var titleColor: SwiftUIColor? {
        let color = isPressed
            ? model.style?.pressedTintColor ?? model.style?.titleColor ?? .white
            : model.style?.titleColor ?? .white
        return SwiftUIColor(color)
    }

    private var titleFont: SwiftUIFont {
        SwiftUIFont(model.style?.font ?? .systemFont(ofSize: 18))
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
            SUIButtonCornerShape(style: buttonCornerStyle)
                .strokeBorder(SwiftUIColor(borderColor), lineWidth: model.style?.borderWidth ?? 0)
        }
    }
}

private struct SUIButtonCornerShape: InsettableShape {
    let style: CornerStyle
    private var insetAmount: CGFloat = 0

    init(style: CornerStyle) {
        self.style = style
    }

    func path(in rect: CGRect) -> Path {
        switch style {
        case .automatic:
            return continuousRoundedRectangle(
                radius: min(rect.width, rect.height) / 2,
                in: rect
            )
        case .fixed(let radius):
            return continuousRoundedRectangle(radius: radius, in: rect)
        case .corners, .none:
            return SUICornerShape(style: style)
                .inset(by: insetAmount)
                .path(in: rect)
        }
    }

    func inset(by amount: CGFloat) -> SUIButtonCornerShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    private func continuousRoundedRectangle(radius: CGFloat, in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .inset(by: insetAmount)
            .path(in: rect)
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
