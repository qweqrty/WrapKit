//
//  SUIVKeyValueFieldView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIVKeyValueFieldView: View {
    @StateObject private var stateModel: SUIKeyValueFieldViewStateModel

    private let keyFont: Font
    private let keyTextColor: Color
    private let valueFont: Font
    private let valueTextColor: Color
    private let keyTextAlignment: TextAlignment
    private let valueTextAlignment: TextAlignment
    private let keyNumberOfLines: Int
    private let valueNumberOfLines: Int
    private let spacing: CGFloat
    private let contentInsets: EdgeInsets

    public init(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter,
        keyFont: Font = .systemFont(ofSize: 11),
        keyTextColor: Color = .black,
        valueFont: Font = .systemFont(ofSize: 14),
        valueTextColor: Color = .black,
        keyTextAlignment: TextAlignment = .left,
        valueTextAlignment: TextAlignment = .left,
        keyNumberOfLines: Int = 1,
        valueNumberOfLines: Int = 1,
        spacing: CGFloat = 4,
        contentInsets: EdgeInsets = .zero,
        isHidden: Bool = false
    ) {
        _stateModel = .init(
            wrappedValue: .init(
                adapter: adapter,
                displaysBottomImage: true,
                isHidden: isHidden
            )
        )
        self.keyFont = keyFont
        self.keyTextColor = keyTextColor
        self.valueFont = valueFont
        self.valueTextColor = valueTextColor
        self.keyTextAlignment = keyTextAlignment
        self.valueTextAlignment = valueTextAlignment
        self.keyNumberOfLines = keyNumberOfLines
        self.valueNumberOfLines = valueNumberOfLines
        self.spacing = spacing
        self.contentInsets = contentInsets
    }

    public var body: some View {
        if !stateModel.isHidden {
            VStack(alignment: .leading, spacing: spacing) {
                label(
                    stateModel.keyTitle,
                    font: keyFont,
                    textColor: keyTextColor,
                    textAlignment: keyTextAlignment,
                    numberOfLines: keyNumberOfLines
                )

                label(
                    stateModel.valueTitle,
                    font: valueFont,
                    textColor: valueTextColor,
                    textAlignment: valueTextAlignment,
                    numberOfLines: valueNumberOfLines
                )

                bottomImageView
            }
            .padding(contentInsets.asSUIEdgeInsets)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private func label(
        _ model: TextOutputPresentableModel?,
        font: Font,
        textColor: Color,
        textAlignment: TextAlignment,
        numberOfLines: Int
    ) -> some View {
        if let model {
            SUILabelView(
                model: model,
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
            .lineLimit(numberOfLines == 0 ? nil : numberOfLines)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: alignment(from: textAlignment))
        }
    }

    private func alignment(from textAlignment: TextAlignment) -> Alignment {
        switch textAlignment {
        case .center:
            return .center
        case .right:
            return .trailing
        default:
            return .leading
        }
    }

    @ViewBuilder
    private var bottomImageView: some View {
        if stateModel.bottomImage != nil {
            HStack(spacing: 0) {
                SUIImageView(adapter: stateModel.bottomImageAdapter)
                Spacer(minLength: 0)
            }
        }
    }
}

#endif
