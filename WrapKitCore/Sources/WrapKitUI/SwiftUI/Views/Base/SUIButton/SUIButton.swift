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
    
    public init(
        adapter: ButtonOutputSwiftUIAdapter
    ) {
        self.stateModel = .init(adapter: adapter)
    }
    
    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUIButtonView(
                model: stateModel.presentable,
                onPress: stateModel.presentable.onPress,
                isEnabled: stateModel.isEnabled
            )
        }
    }
}

public struct SUIButtonView: View {
    let model: ButtonPresentableModel
    let onPress: (() -> Void)?
    let isEnabled: Bool
    let isLoading: Bool
    
    @State private var isPressed: Bool = false
    
    public init(
        model: ButtonPresentableModel,
        onPress: (() -> Void)? = nil,
        isEnabled: Bool,
        isLoading: Bool = false
    ) {
        self.model = model
        self.onPress = onPress
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }
    
    public var body: some View {
        SwiftUI.Button(action: { onPress?() }) {
            ZStack {
                HStack(spacing: model.spacing ?? 0) {
                    if let image = model.image {
                        SwiftUIImage(image: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: (model.height ?? 44) * 0.5)
                    }
                    if let title = model.title {
                        Text(title.removingPercentEncoding ?? title)
                            .font(model.style?.font.map { SwiftUIFont($0) })
                            .foregroundColor(
                                isPressed
                                ? model.style?.pressedTintColor.map { SwiftUIColor($0) }
                                : model.style?.titleColor.map { SwiftUIColor($0) }
                            )
                    }
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    SUILoadingViewContent(
                        color: model.style?.loadingIndicatorColor.map { SwiftUIColor($0) } ?? .white,
                        size: .init(
                            width: (model.height ?? 44) * 0.5,
                            height: (model.height ?? 44) * 0.5
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(model.contentInset?.asSUIEdgeInsets ?? .init())
            .frame(width: model.width, height: model.height)
            .background(backgroundView)
            .cornerRadius(model.style?.cornerRadius ?? 12)
            .overlay(borderView)
            .accessibilityIdentifier(model.accessibilityIdentifier ?? "")
        }
        .opacity(isEnabled ? 1.0 : 0.5)
        .disabled(!isEnabled)
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if let gradientColors = model.style?.gradientColors, !gradientColors.isEmpty {
            LinearGradient(
                colors: gradientColors.map { SwiftUIColor($0) },
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            SwiftUIColor(
                isPressed
                ? model.style?.pressedColor ?? model.style?.backgroundColor ?? .clear
                : model.style?.backgroundColor ?? .clear
            )
        }
    }
    
    @ViewBuilder
    private var borderView: some View {
        if let borderColor = model.style?.borderColor,
           (model.style?.borderWidth ?? 0) > 0 {
            RoundedRectangle(cornerRadius: model.style?.cornerRadius ?? 12)
                .strokeBorder(SwiftUIColor(borderColor), lineWidth: model.style?.borderWidth ?? 0)
        }
    }
}

private struct PressableButtonStyle: SwiftUI.ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(
                SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}
