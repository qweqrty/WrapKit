//
//  SUICountingLabelAnimation.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUICountingLabelAnimation: View {
    @StateObject private var displayLinkManager = SUIDisplayLinkManager()

    private let accessibilityIdentifier: String?
    private let fromValue: Decimal
    private let toValue: Decimal
    private let mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?
    private let animationStyle: LabelAnimationStyle
    private let duration: TimeInterval
    private let completion: (() -> Void)?
    private let font: Font
    private let textColor: Color
    private let textAlignment: TextAlignment

    public init(
        accessibilityIdentifier: String? = nil,
        from fromValue: Decimal,
        to toValue: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle = .none,
        duration: TimeInterval = 1.0,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .label,
        textAlignment: TextAlignment = .natural,
        completion: (() -> Void)? = nil
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.fromValue = fromValue
        self.toValue = toValue
        self.mapToString = mapToString
        self.animationStyle = animationStyle
        self.duration = duration
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.completion = completion
    }

    public var body: some View {
        ZStack {
            if case let .circle(color) = animationStyle {
                SUICircularProgressView(
                    color: color,
                    from: 1,
                    to: 0,
                    duration: duration,
                    completion: nil
                )
                .padding(8)
            }

            SUILabelView(
                model: .init(
                    accessibilityIdentifier: accessibilityIdentifier,
                    model: currentText
                ),
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
        }
        .onAppear {
            displayLinkManager.startAnimation(
                duration: duration,
                completion: completion
            )
        }
        .onDisappear {
            displayLinkManager.stopAnimation()
        }
    }

    private var currentText: TextOutputPresentableModel.TextModel {
        let currentValue = fromValue + (displayLinkManager.progress * (toValue - fromValue))
        return mapToString?(currentValue) ?? .text("")
    }
}

#endif
