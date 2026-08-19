//
//  SUIChunkedTextField.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIChunkedTextField: View {
    private static let cornerRadius: CGFloat = 12

    private let count: Int
    private let appearance: TextfieldAppearance

    @StateObject private var stateModel: SUIChunkedTextFieldStateModel

    public init(
        count: Int,
        appearance: TextfieldAppearance,
        adapter: TextInputOutputSwiftUIAdapter
    ) {
        self.count = count
        self.appearance = appearance
        _stateModel = .init(wrappedValue: .init(count: count, adapter: adapter))
    }

    public var body: some View {
        HStack(spacing: count > 4 ? 8 : 12) {
            ForEach(0..<count, id: \.self) { index in
                SUIChunkedTextFieldItem(
                    text: Binding(
                        get: { stateModel.character(at: index) },
                        set: { stateModel.updateCharacter(at: index, with: $0) }
                    ),
                    appearance: appearance,
                    isValid: stateModel.isValid,
                    isUserInteractionEnabled: stateModel.isUserInteractionEnabled,
                    cornerRadius: Self.cornerRadius
                )
            }
        }
        .opacity(stateModel.isHidden ? 0 : 1)
        .allowsHitTesting(stateModel.isUserInteractionEnabled)
    }
}

private struct SUIChunkedTextFieldItem: View {
    @Binding var text: String

    let appearance: TextfieldAppearance
    let isValid: Bool
    let isUserInteractionEnabled: Bool
    let cornerRadius: CGFloat

    var body: some View {
        TextField("", text: $text)
            .font(SwiftUIFont(appearance.font))
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .textFieldStyle(PlainTextFieldStyle())
            .accentColor(.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .allowsHitTesting(isUserInteractionEnabled)
    }

    private var textColor: SwiftUIColor {
        SwiftUIColor(isUserInteractionEnabled ? appearance.colors.textColor : appearance.colors.disabledTextColor)
    }

    private var backgroundColor: SwiftUIColor {
        return SwiftUIColor(isValid ? appearance.colors.deselectedBackgroundColor : appearance.colors.errorBackgroundColor)
    }

    private var borderColor: SwiftUIColor {
        SwiftUIColor(isValid ? appearance.colors.deselectedBorderColor : appearance.colors.errorBorderColor)
    }

    private var borderWidth: CGFloat {
        appearance.border?.idleBorderWidth ?? 0
    }
}

#endif
