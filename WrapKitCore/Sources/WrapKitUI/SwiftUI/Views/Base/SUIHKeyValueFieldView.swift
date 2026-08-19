//
//  SUIHKeyValueFieldView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import CoreText
import SwiftUI

public struct SUIHKeyValueFieldView: View {
    @StateObject private var stateModel: SUIKeyValueFieldViewStateModel

    private let backgroundColor: Color
    private let keyFont: Font
    private let keyTextColor: Color
    private let valueFont: Font
    private let valueTextColor: Color
    private let spacing: CGFloat
    private let contentInsets: EdgeInsets

    public init(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter,
        backgroundColor: Color = .clear,
        keyFont: Font = .systemFont(ofSize: 11),
        keyTextColor: Color = .black,
        valueFont: Font = .systemFont(ofSize: 16),
        valueTextColor: Color = .black,
        spacing: CGFloat = 4,
        contentInsets: EdgeInsets = .zero,
        isHidden: Bool = false
    ) {
        _stateModel = .init(
            wrappedValue: .init(
                adapter: adapter,
                displaysBottomImage: false,
                isHidden: isHidden
            )
        )
        self.backgroundColor = backgroundColor
        self.keyFont = keyFont
        self.keyTextColor = keyTextColor
        self.valueFont = valueFont
        self.valueTextColor = valueTextColor
        self.spacing = spacing
        self.contentInsets = contentInsets
    }

    public var body: some View {
        if !stateModel.isHidden {
            content
            .padding(contentInsets.asSUIEdgeInsets)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SwiftUIColor(backgroundColor))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch (stateModel.keyTitle, stateModel.valueTitle) {
        case (.some(let keyTitle), .some(let valueTitle)):
            HStack(alignment: .center, spacing: spacing) {
                label(
                    keyTitle,
                    font: keyFont,
                    textColor: keyTextColor,
                    textAlignment: .left
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                label(
                    valueTitle,
                    font: valueFont,
                    textColor: valueTextColor,
                    textAlignment: .right
                )
                .fixedSize(horizontal: true, vertical: true)
            }

        case (.some(let keyTitle), .none):
            label(
                keyTitle,
                font: keyFont,
                textColor: keyTextColor,
                textAlignment: .left
            )
            .frame(maxWidth: .infinity, alignment: .leading)

        case (.none, .some(let valueTitle)):
            label(
                valueTitle,
                font: valueFont,
                textColor: valueTextColor,
                textAlignment: .right
            )
            .frame(maxWidth: .infinity, alignment: .trailing)

        case (.none, .none):
            SwiftUICore.EmptyView()
        }
    }

    @ViewBuilder
    private func label(
        _ model: TextOutputPresentableModel?,
        font: Font,
        textColor: Color,
        textAlignment: TextAlignment
    ) -> some View {
        if let text = model?.model?.text {
            SUIHKeyValueText(
                text: text.removingPercentEncoding ?? text,
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
            .frame(height: ceil(font.lineHeight), alignment: .center)
            .accessibilityIdentifier(model?.accessibilityIdentifier ?? "")
        }
    }
}

private struct SUIHKeyValueText: View {
    let text: String
    let font: Font
    let textColor: Color
    let textAlignment: TextAlignment

    @ViewBuilder
    var body: some View {
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            coreTextBody
        } else {
            Text(text)
                .font(SwiftUIFont(font))
                .foregroundColor(SwiftUIColor(textColor))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    private var coreTextBody: some View {
        Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { graphicsContext, size in
            let attributedString = NSAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: textColor,
                ]
            )
            let line = CTLineCreateWithAttributedString(attributedString as CFAttributedString)
            let lineWidth = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
            let origin = CGPoint(
                x: originX(lineWidth: lineWidth, containerWidth: size.width),
                y: abs(font.descender)
            )

            graphicsContext.withCGContext { context in
                context.saveGState()
                context.textMatrix = .identity
                context.translateBy(x: 0, y: size.height)
                context.scaleBy(x: 1, y: -1)
                context.textPosition = origin
                CTLineDraw(line, context)
                context.restoreGState()
            }
        }
    }

    private func originX(lineWidth: CGFloat, containerWidth: CGFloat) -> CGFloat {
        switch textAlignment {
        case .center:
            return max((containerWidth - lineWidth) / 2, 0)
        case .right:
            return max(containerWidth - lineWidth, 0)
        default:
            return 0
        }
    }
}

#endif
