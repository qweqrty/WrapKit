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
        textColor: Color = .defaultLabel,
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
        SUILabelView(
            model: .init(
                accessibilityIdentifier: accessibilityIdentifier,
                model: currentText
            ),
            font: font,
            textColor: textColor,
            textAlignment: textAlignment
        )
        .if(isCircular) { $0.fixedSize() }
        .background {
            if case let .circle(color) = animationStyle {
                SUICircularProgressView(
                    color: color,
                    from: 1,
                    to: 0,
                    duration: duration,
                    completion: nil
                )
                // UIKit draws the ring outside the label's text bounds. Keep it
                // out of intrinsic measurement, including zero-width card probes.
                .padding(-8)
            }
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

    private var isCircular: Bool {
        if case .circle = animationStyle { return true }
        return false
    }
}

extension TextOutputPresentableModel {
    var hasCircularCountingAnimation: Bool {
        model?.hasCircularCountingAnimation ?? false
    }
}

private extension TextOutputPresentableModel.TextModel {
    var hasCircularCountingAnimation: Bool {
        switch self {
        case let .animated(_, _, _, _, style, _, _),
             let .animatedDecimal(_, _, _, _, style, _, _):
            if case .circle = style { return true }
            return false
        case let .textStyled(text, _, _, _, _):
            return text.hasCircularCountingAnimation
        default:
            return false
        }
    }
}

#endif
