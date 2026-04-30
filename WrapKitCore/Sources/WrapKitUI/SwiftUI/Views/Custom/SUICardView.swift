import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUICardView: View {
    @StateObject private var stateModel: SUICardViewStateModel

    public init(adapter: CardViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        if !stateModel.isHidden {
            content
                .accessibilityIdentifier(stateModel.accessibilityIdentifier ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        let style = stateModel.style
        ZStack {
            backgroundImageView(style: style)
            VStack(spacing: 0) {
                cardContent(style: style)
                bottomSeparator
            }
            .padding(style.vStacklayoutMargins.asSUIEdgeInsets)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(SwiftUIColor(style.backgroundColor))
        .cornerRadius(style.cornerRadius)
        .overlay(CardBorderOverlay(style: style))
        .allowsHitTesting(stateModel.isUserInteractionEnabled)
        .onTapGesture {
            stateModel.onPress?()
        }
        .onLongPressGesture(minimumDuration: 1) {
            stateModel.onLongPress?()
        }
    }

    @ViewBuilder
    private func backgroundImageView(style: CardViewPresentableModel.Style) -> some View {
        if let backgroundImage = stateModel.backgroundImage {
            let needsAspectFillCorrection = backgroundImage.contentModeIsFit == false && backgroundImage.size == nil
            SUIImageView(adapter: stateModel.backgroundImageAdapter)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .scaleEffect(needsAspectFillCorrection ? 0.78 : 1)
                .offset(y: needsAspectFillCorrection ? -96 : 0)
                .opacity(backgroundImage.alpha ?? 1)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func cardContent(style: CardViewPresentableModel.Style) -> some View {
        HStack(spacing: style.hStackViewSpacing) {
            arrangedContainer(style: style) {
                leadingTitlesView(style: style)
            }
            arrangedContainer(style: style) {
                imageView(stateModel.leadingImage, adapter: stateModel.leadingImageAdapter)
            }
            arrangedContainer(style: style) {
                imageView(stateModel.secondaryLeadingImage, adapter: stateModel.secondaryLeadingImageAdapter)
            }
            arrangedContainer(style: style) {
                titleBlockView(style: style)
            }
            arrangedContainer(style: style) {
                subTitleView(style: style)
            }
            arrangedContainer(style: style) {
                imageView(stateModel.secondaryTrailingImage, adapter: stateModel.secondaryTrailingImageAdapter)
            }
            arrangedContainer(style: style, leadingSpacing: style.trailingImageLeadingSpacing) {
                imageView(stateModel.trailingImage, adapter: stateModel.trailingImageAdapter)
            }
            arrangedContainer(style: style, leadingSpacing: style.secondaryTrailingImageLeadingSpacing) {
                switchView
            }
            arrangedContainer(style: style) {
                trailingTitlesView(style: style)
            }
        }
        .padding(style.hStacklayoutMargins.asSUIEdgeInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func arrangedContainer(
        style: CardViewPresentableModel.Style,
        leadingSpacing: CGFloat? = nil,
        @ViewBuilder content: () -> some View
    ) -> some View {
        let inner = content()
        switch style.hStackViewDistribution {
        case .fillEqually:
            inner
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.leading, leadingSpacing ?? 0)
        case .equalSpacing, .equalCentering:
            inner
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.leading, leadingSpacing ?? 0)
                .padding(.horizontal, 2)
        default:
            inner
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.leading, leadingSpacing ?? 0)
        }
    }

    @ViewBuilder
    private func leadingTitlesView(style: CardViewPresentableModel.Style) -> some View {
        if let leadingTitles = stateModel.leadingTitles {
            VStack(spacing: 0) {
                styledLabel(
                    leadingTitles.first,
                    font: style.leadingTitleKeyLabelFont,
                    color: style.leadingTitleKeyTextColor,
                    numberOfLines: style.titleKeyNumberOfLines,
                    alignment: .center
                )
                styledLabel(
                    leadingTitles.second,
                    font: style.leadingTitleKeyLabelFont,
                    color: style.leadingTitleKeyTextColor,
                    numberOfLines: style.titleValueNumberOfLines,
                    alignment: .center
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func trailingTitlesView(style: CardViewPresentableModel.Style) -> some View {
        if let trailingTitles = stateModel.trailingTitles {
            VStack(spacing: 0) {
                styledLabel(
                    trailingTitles.first,
                    font: style.trailingTitleKeyLabelFont,
                    color: style.trailingTitleKeyTextColor,
                    numberOfLines: style.titleKeyNumberOfLines,
                    alignment: .center
                )
                styledLabel(
                    trailingTitles.second,
                    font: style.trailingTitleKeyLabelFont,
                    color: style.trailingTitleKeyTextColor,
                    numberOfLines: style.titleValueNumberOfLines,
                    alignment: .center
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func titleBlockView(style: CardViewPresentableModel.Style) -> some View {
        if isVisibleTextModel(stateModel.title) || isVisibleTextModel(stateModel.valueTitle) {
            VStack(alignment: .leading, spacing: style.stackSpace) {
                styledLabel(
                    stateModel.title,
                    font: style.titleKeyLabelFont,
                    color: style.titleKeyTextColor,
                    numberOfLines: style.titleKeyNumberOfLines,
                    alignment: .leading
                )
                styledLabel(
                    stateModel.valueTitle,
                    font: style.titleValueLabelFont,
                    color: style.titleValueTextColor,
                    numberOfLines: style.titleValueNumberOfLines,
                    alignment: .leading
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func subTitleView(style: CardViewPresentableModel.Style) -> some View {
        if isVisibleTextModel(stateModel.subTitle) {
            styledLabel(
                stateModel.subTitle,
                font: style.subTitleLabelFont,
                color: style.subTitleTextColor,
                numberOfLines: style.subtitleNumberOfLines,
                alignment: .leading
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private func styledLabel(
        _ model: TextOutputPresentableModel?,
        font: Font,
        color: Color,
        numberOfLines: Int,
        alignment: SwiftUI.Alignment
    ) -> some View {
        if let model {
            SUILabelView(
                model: model,
                font: font,
                textColor: color,
                textAlignment: textAlignment(from: alignment)
            )
            .lineLimit(numberOfLines == 0 ? nil : numberOfLines)
            .frame(maxWidth: CGFloat.infinity, alignment: alignment)
        }
    }

    private func textAlignment(from alignment: SwiftUI.Alignment) -> TextAlignment {
        switch alignment {
        case .leading:
            return .left
        case .trailing:
            return .right
        default:
            return .center
        }
    }

    @ViewBuilder
    private func imageView(_ model: ImageViewPresentableModel?, adapter: ImageViewOutputSwiftUIAdapter) -> some View {
        if model != nil {
            SUIImageView(adapter: adapter)
                .accentColor(SwiftUIColor.black)
        }
    }

    @ViewBuilder
    private var switchView: some View {
        if let model = stateModel.switchControl {
            SUISwitchControlView(model: model)
        }
    }

    @ViewBuilder
    private var bottomSeparator: some View {
        if let separator = stateModel.bottomSeparator {
            SwiftUIColor(separator.color)
                .frame(height: separator.height)
                .padding(separator.padding.asSUIEdgeInsets)
        }
    }

    private func isVisibleTextModel(_ model: TextOutputPresentableModel?) -> Bool {
        guard let model else { return false }
        return isVisibleTextModel(model.model)
    }

    private func isVisibleTextModel(_ model: TextOutputPresentableModel.TextModel?) -> Bool {
        guard let model else { return false }

        switch model {
        case .text(let text):
            return !(text?.isEmpty ?? true)
        case .attributes(let attrs):
            return !attrs.isEmpty
        case .textStyled(let wrapped, _, _, _, _):
            return isVisibleTextModel(wrapped)
        case .animated, .animatedDecimal:
            return true
        case .attributedString(let html, _):
            return !(html?.isEmpty ?? true)
        }
    }
}

private struct CardBorderOverlay: View {
    let style: CardViewPresentableModel.Style

    var body: some View {
        Group {
            if let borderColor = style.borderColor,
               let borderWidth = style.borderWidth {
                RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                    .stroke(SwiftUIColor(borderColor), lineWidth: borderWidth)
            } else {
                SwiftUICore.EmptyView()
            }
        }
    }
}

#endif
