//
//  SUIHKeyValueFieldView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
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
    private let keyLineLimit: Int?
    private let valueLineLimit: Int?
    private let keyMinimumScaleFactor: CGFloat
    private let valueMinimumScaleFactor: CGFloat

    public init(
        adapter: KeyValueFieldViewOutputSwiftUIAdapter,
        backgroundColor: Color = .clear,
        keyFont: Font = .systemFont(ofSize: 11),
        keyTextColor: Color = .black,
        valueFont: Font = .systemFont(ofSize: 16),
        valueTextColor: Color = .black,
        spacing: CGFloat = 4,
        contentInsets: EdgeInsets = .zero,
        keyLineLimit: Int? = 1,
        valueLineLimit: Int? = 1,
        keyMinimumScaleFactor: CGFloat = 0.5,
        valueMinimumScaleFactor: CGFloat = 0.5,
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
        self.keyLineLimit = keyLineLimit
        self.valueLineLimit = valueLineLimit
        self.keyMinimumScaleFactor = keyMinimumScaleFactor
        self.valueMinimumScaleFactor = valueMinimumScaleFactor
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
                    textAlignment: .left,
                    lineLimit: keyLineLimit,
                    minimumScaleFactor: keyMinimumScaleFactor
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                label(
                    valueTitle,
                    font: valueFont,
                    textColor: valueTextColor,
                    textAlignment: .right,
                    lineLimit: valueLineLimit,
                    minimumScaleFactor: valueMinimumScaleFactor
                )
                .fixedSize(horizontal: true, vertical: true)
            }

        case (.some(let keyTitle), .none):
            label(
                keyTitle,
                font: keyFont,
                textColor: keyTextColor,
                textAlignment: .left,
                lineLimit: keyLineLimit,
                minimumScaleFactor: keyMinimumScaleFactor
            )
            .frame(maxWidth: .infinity, alignment: .leading)

        case (.none, .some(let valueTitle)):
            label(
                valueTitle,
                font: valueFont,
                textColor: valueTextColor,
                textAlignment: .right,
                lineLimit: valueLineLimit,
                minimumScaleFactor: valueMinimumScaleFactor
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
        textAlignment: TextAlignment,
        lineLimit: Int?,
        minimumScaleFactor: CGFloat
    ) -> some View {
        if let model {
            SUILabelView(
                model: model,
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
            .lineLimit(lineLimit)
            .minimumScaleFactor(minimumScaleFactor)
        }
    }
}

#endif
