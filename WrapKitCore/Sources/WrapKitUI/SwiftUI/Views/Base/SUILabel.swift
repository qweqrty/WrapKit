//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI

public struct SUILabel: View {
    @ObservedObject var stateModel: SUILabelStateModel

    private let defaultFont: Font
    private let defaultTextColor: Color
    private let defaultTextAlignment: TextAlignment

    public init(
        adapter: TextOutputSwiftUIAdapter,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .darkText,
        textAlignment: TextAlignment = .natural
    ) {
        self.stateModel = .init(adapter: adapter)
        self.defaultFont = font
        self.defaultTextColor = textColor
        self.defaultTextAlignment = textAlignment
    }

    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUILabelView(
                model: stateModel.presentable,
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
        }
    }
}

public struct SUILabelView: View, Animatable {
    let model: TextOutputPresentableModel

    private let defaultFont: Font
    private let defaultTextColor: Color
    private let defaultTextAlignment: TextAlignment

    public init(
        model: TextOutputPresentableModel,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .darkText,
        textAlignment: TextAlignment = .natural
    ) {
        self.model = model
        self.defaultFont = font
        self.defaultTextColor = textColor
        self.defaultTextAlignment = textAlignment
    }

    @StateObject private var displayLinkManager = SUIDisplayLinkManager()

    public var body: some View {
        switch model.model {
        case .textStyled(let text, let cornerStyle, let insets, _, let backgroundColor):
            SUILabelView(
                model: .init(accessibilityIdentifier: model.accessibilityIdentifier, model: text),
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            .if(!insets.isZero) { $0.padding(insets.asSUIEdgeInsets) }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .ifLet(backgroundColor) { $0.background(SwiftUIColor($1)) }
            .ifLet(cornerStyle) { $0.cornerStyle($1) }

        case .animatedDecimal(_, let from, let to, let mapToString, let animationStyle, let duration, let completion):
            animatedContainer(
                from: from,
                to: to,
                mapToString: mapToString,
                animationStyle: animationStyle,
                duration: duration,
                completion: completion
            )

        case .animated(_, let from, let to, let mapToString, let animationStyle, let duration, let completion):
            let mapper: ((Decimal) -> TextOutputPresentableModel.TextModel)? = if let mapToString {
                { mapToString($0.doubleValue) }
            } else {
                nil
            }
            animatedContainer(
                from: from.asDecimal(),
                to: to.asDecimal(),
                mapToString: mapper,
                animationStyle: animationStyle,
                duration: duration,
                completion: completion
            )

        default:
            if let inlineImageText {
                inlineImageText
                    .font(SwiftUIFont(defaultFont))
                    .textColor(SwiftUIColor(defaultTextColor))
                    .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *), let attributedText {
                Text(attributedText)
                    .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let fallbackPlainText {
                Text(fallbackPlainText)
                    .font(SwiftUIFont(defaultFont))
                    .textColor(SwiftUIColor(defaultTextColor))
                    .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func animatedContainer(
        from: Decimal,
        to: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    ) -> some View {
        ZStack {
            if case let .circle(color) = animationStyle {
                SUICircularProgressView(color: color, from: 1, to: 0, duration: duration, completion: nil)
                    .padding(8)
            }

            SUILabelView(
                model: .init(
                    accessibilityIdentifier: model.accessibilityIdentifier,
                    model: mapToString?(from + (displayLinkManager.progress * (to - from))) ?? .text("")
                ),
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            .onAppear {
                guard duration > 0 else { return }
                displayLinkManager.startAnimation(duration: duration, completion: nil)
            }
        }
    }

    private var inlineImageText: Text? {
        guard case .attributes(let attributes) = model.model, !attributes.isEmpty else { return nil }
        guard attributes.contains(where: { $0.leadingImage != nil || $0.trailingImage != nil }) else { return nil }

        var result = Text("")
        for attribute in attributes {
            let text = attribute.text.removingPercentEncoding ?? attribute.text
            if let leadingImage = attribute.leadingImage {
                result = result + Text(SwiftUIImage(image: leadingImage)) + Text(" ")
            }
            result = result + Text(text)
            if let trailingImage = attribute.trailingImage {
                result = result + Text(" ") + Text(SwiftUIImage(image: trailingImage))
            }
        }
        return result
    }

    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    private var attributedText: AttributedString? {
        switch model.model {
        case .text(let string):
            let text = string?.removingPercentEncoding ?? string ?? ""
            guard !text.isEmpty else { return nil }
            let attributed = NSAttributedString(
                text,
                font: defaultFont,
                color: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            return AttributedString(attributed)

        case .attributes(let attributes):
            guard !attributes.contains(where: { $0.leadingImage != nil || $0.trailingImage != nil }) else {
                return nil
            }
            guard !attributes.isEmpty else { return nil }
            var normalized = attributes
            for index in normalized.indices {
                normalized[index].text = normalized[index].text.removingPercentEncoding ?? normalized[index].text
            }
            let attributed = normalized.makeNSAttributedString(
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            return AttributedString(attributed)

        case .attributedString(let htmlString, let config):
            guard
                let htmlString,
                let attributed = htmlString.asHtmlAttributedString(config: config)
            else {
                return nil
            }
            return AttributedString(attributed)

        default:
            return nil
        }
    }

    private var fallbackPlainText: String? {
        switch model.model {
        case .text(let string):
            let text = string?.removingPercentEncoding ?? string ?? ""
            return text.isEmpty ? nil : text
        case .attributes(let attributes):
            let text = attributes.map(\.text).joined()
            return text.isEmpty ? nil : text
        case .attributedString(let htmlString, _):
            guard let htmlString, !htmlString.isEmpty else { return nil }
            return htmlString
        default:
            return nil
        }
    }

    private func multilineAlignment(from textAlignment: TextAlignment) -> SwiftUI.TextAlignment {
        switch textAlignment {
        case .center:
            return .center
        case .right:
            return .trailing
        default:
            return .leading
        }
    }
}
#endif
