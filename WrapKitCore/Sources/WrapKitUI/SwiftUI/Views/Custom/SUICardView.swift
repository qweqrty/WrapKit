import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUICardView: View {
    @StateObject private var stateModel: SUICardViewStateModel
    private let titleFontOverride: Font?
    private let titleColorOverride: Color?
    private let leadingImageTintOverride: Color?

    public init(adapter: CardViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        titleFontOverride = nil
        titleColorOverride = nil
        leadingImageTintOverride = nil
    }

    init(
        adapter: CardViewOutputSwiftUIAdapter,
        titleFontOverride: Font?,
        titleColorOverride: Color?,
        leadingImageTintOverride: Color?
    ) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
        self.titleFontOverride = titleFontOverride
        self.titleColorOverride = titleColorOverride
        self.leadingImageTintOverride = leadingImageTintOverride
    }

    init(stateModel: SUICardViewStateModel) {
        _stateModel = .init(wrappedValue: stateModel)
        titleFontOverride = nil
        titleColorOverride = nil
        leadingImageTintOverride = nil
    }

    public var body: some View {
        if !stateModel.isHidden {
            content
                .modifier(CardAccessibilityModifier(
                    identifier: stateModel.accessibilityIdentifier,
                    label: stateModel.accessibilityLabel,
                    hint: stateModel.accessibilityHint,
                    onPress: stateModel.onPress,
                    onLongPress: stateModel.onLongPress
                ))
        }
    }

    @ViewBuilder
    private var content: some View {
        let style = stateModel.style
        cardSurface(style: style)
            .overlay(CardBorderOverlay(
                style: style,
                gradientBorderColors: stateModel.activeGradientBorderColors
            ).allowsHitTesting(false))
            .allowsHitTesting(stateModel.isUserInteractionEnabled)
            .ifLet(stateModel.onPress) { view, action in
                view.onTapGesture(perform: action)
            }
            .ifLet(stateModel.onLongPress) { view, action in
                view.onLongPressGesture(minimumDuration: 1, perform: action)
            }
    }

    private func cardSurface(style: CardViewPresentableModel.Style) -> some View {
        ZStack {
            CardCornerShape(style: style.cornerStyle)
                .fill(SwiftUIColor(style.backgroundColor))

            cardBody(style: style)
                .clipShape(CardCornerShape(style: style.cornerStyle))
        }
    }

    private func cardBody(style: CardViewPresentableModel.Style) -> some View {
        ZStack {
            cardBackground
            VStack(spacing: 0) {
                cardContent(style: style)
                bottomSeparator
                bottomImage
            }
            .padding(style.vStacklayoutMargins.asSUIEdgeInsets)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let backgroundImage = stateModel.backgroundImage {
            CardBackgroundImageView(model: backgroundImage)
        }
    }

    @ViewBuilder
    private func cardContent(style: CardViewPresentableModel.Style) -> some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                switch style.hStackViewDistribution {
                case .fill:
                    CardFillHorizontalLayout(defaultSpacing: style.hStackViewSpacing) {
                        cardArrangedSubviews(style: style)
                    }
                case .equalSpacing, .equalCentering:
                    CardDistributedHorizontalLayout(
                        distribution: style.hStackViewDistribution,
                        minimumSpacing: style.hStackViewSpacing
                    ) {
                        cardArrangedSubviews(style: style)
                    }
                case .fillEqually, .fillProportionally:
                    HStack(spacing: style.hStackViewSpacing) {
                        cardArrangedSubviews(style: style)
                    }
                }
            } else {
                HStack(spacing: style.hStackViewSpacing) {
                    cardArrangedSubviews(style: style)
                }
            }
        }
        .padding(style.hStacklayoutMargins.asSUIEdgeInsets)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func cardArrangedSubviews(style: CardViewPresentableModel.Style) -> some View {
        if stateModel.leadingTitles != nil {
            arrangedContainer(style: style, fillRole: .flexibleText) {
                leadingTitlesView(style: style)
            }
        }
        if stateModel.leadingImage != nil {
            arrangedContainer(style: style) {
                imageView(
                    stateModel.leadingImage,
                    adapter: stateModel.leadingImageAdapter,
                    tintColor: leadingImageTintOverride ?? .black
                )
            }
        }
        if stateModel.secondaryLeadingImage != nil {
            arrangedContainer(style: style) {
                imageView(stateModel.secondaryLeadingImage, adapter: stateModel.secondaryLeadingImageAdapter)
            }
        }
        if isVisibleTextModel(stateModel.title) || isVisibleTextModel(stateModel.valueTitle) {
            arrangedContainer(style: style, fillRole: .flexibleText) {
                titleBlockView(style: style)
            }
        }
        if isVisibleTextModel(stateModel.subTitle) {
            arrangedContainer(style: style, fillRole: .subtitle) {
                subTitleView(style: style)
            }
        }
        if stateModel.secondaryTrailingImage != nil {
            arrangedContainer(style: style, leadingSpacing: stateModel.secondaryTrailingImageLeadingSpacing) {
                imageView(
                    stateModel.secondaryTrailingImage,
                    adapter: stateModel.secondaryTrailingImageAdapter,
                    tintColor: nil
                )
            }
        }
        if stateModel.trailingImage != nil {
            arrangedContainer(style: style, leadingSpacing: stateModel.trailingImageLeadingSpacing) {
                imageView(stateModel.trailingImage, adapter: stateModel.trailingImageAdapter)
            }
        }
        if stateModel.switchControl != nil {
            // UISwitch has a wider physical frame than its alignment rect on iOS 26.
            // Keep the semantic viewport for layout, but leave the physical overhang visible.
            arrangedContainer(
                style: style,
                fillEquallyAlignment: .leading,
                clipsFixedViewport: false
            ) {
                switchView
            }
        }
        if stateModel.trailingTitles != nil {
            arrangedContainer(style: style, fillRole: .flexibleText) {
                trailingTitlesView(style: style)
            }
        }
    }

    @ViewBuilder
    private func arrangedContainer(
        style: CardViewPresentableModel.Style,
        leadingSpacing: CGFloat? = nil,
        fillRole: CardFillRole = .fixed,
        fillEquallyAlignment: Alignment = .center,
        clipsFixedViewport: Bool = true,
        @ViewBuilder content: () -> some View
    ) -> some View {
        let inner = content()
        let container = Group {
            switch style.hStackViewDistribution {
            case .fill:
                if fillRole.canCompress || fillRole.canExpand {
                    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                        CardFillViewportLayout(measuresContentAtProposedWidth: true) {
                            inner
                        }
                        .clipped()
                    } else {
                        inner
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .if(fillRole.canCompress) { $0.clipped() }
                    }
                } else {
                    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                        CardFillViewportLayout {
                            inner
                                .fixedSize(horizontal: true, vertical: true)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                        .if(clipsFixedViewport) { $0.clipped() }
                    } else {
                        inner
                            .fixedSize(horizontal: true, vertical: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .if(clipsFixedViewport) { $0.clipped() }
                    }
                }
            case .fillEqually:
                inner
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: fillEquallyAlignment
                    )
                    .padding(.leading, leadingSpacing ?? 0)
            case .fillProportionally:
                inner
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.leading, leadingSpacing ?? 0)
            case .equalSpacing, .equalCentering:
                inner
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(.leading, leadingSpacing ?? 0)
                    .padding(.horizontal, 2)
            }
        }
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            container.layoutValue(
                key: CardFillItemMetadataKey.self,
                value: .init(role: fillRole, leadingSpacing: leadingSpacing)
            )
        } else {
            container
        }
    }

    @ViewBuilder
    private func leadingTitlesView(style: CardViewPresentableModel.Style) -> some View {
        if stateModel.leadingTitles != nil {
            SUIVKeyValueFieldView(
                adapter: stateModel.leadingTitlesAdapter,
                keyFont: style.leadingTitleKeyLabelFont,
                keyTextColor: style.leadingTitleKeyTextColor,
                valueFont: .systemFont(ofSize: 16),
                valueTextColor: .black,
                keyTextAlignment: .center,
                keyNumberOfLines: 0,
                valueNumberOfLines: 0,
                spacing: 0,
                layoutConfiguration: keyValueLayoutConfiguration(for: style)
            )
            .if(keyValueUsesIntrinsicHeight(for: style)) {
                $0.fixedSize(horizontal: false, vertical: true)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: keyValueMaximumHeight(for: style),
                alignment: .center
            )
        }
    }

    @ViewBuilder
    private func trailingTitlesView(style: CardViewPresentableModel.Style) -> some View {
        if stateModel.trailingTitles != nil {
            SUIVKeyValueFieldView(
                adapter: stateModel.trailingTitlesAdapter,
                keyFont: style.trailingTitleKeyLabelFont,
                keyTextColor: style.trailingTitleKeyTextColor,
                valueFont: .systemFont(ofSize: 16),
                valueTextColor: .black,
                keyTextAlignment: .center,
                keyNumberOfLines: 0,
                valueNumberOfLines: 0,
                spacing: 0,
                layoutConfiguration: keyValueLayoutConfiguration(for: style)
            )
            .if(keyValueUsesIntrinsicHeight(for: style)) {
                $0.fixedSize(horizontal: false, vertical: true)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: keyValueMaximumHeight(for: style),
                alignment: .center
            )
        }
    }

    @ViewBuilder
    private func titleBlockView(style: CardViewPresentableModel.Style) -> some View {
        if isVisibleTextModel(stateModel.title) || isVisibleTextModel(stateModel.valueTitle) {
            SUIVKeyValueFieldView(
                adapter: stateModel.titleViewsAdapter,
                keyFont: titleFontOverride ?? style.titleKeyLabelFont,
                keyTextColor: titleColorOverride ?? style.titleKeyTextColor,
                valueFont: style.titleValueLabelFont,
                valueTextColor: style.titleValueTextColor,
                keyNumberOfLines: style.titleKeyNumberOfLines,
                valueNumberOfLines: style.titleValueNumberOfLines,
                spacing: style.stackSpace,
                layoutConfiguration: keyValueLayoutConfiguration(for: style)
            )
            .if(keyValueUsesIntrinsicHeight(for: style)) {
                $0.fixedSize(horizontal: false, vertical: true)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: keyValueMaximumHeight(for: style),
                alignment: .center
            )
        }
    }

    private func keyValueLayoutConfiguration(
        for style: CardViewPresentableModel.Style
    ) -> SUIVKeyValueFieldView.LayoutConfiguration {
        switch style.hStackViewDistribution {
        case .fill:
            return .uiStackFillWithoutScaling
        default:
            return .standardScaled
        }
    }

    private func keyValueMaximumHeight(for style: CardViewPresentableModel.Style) -> CGFloat? {
        keyValueUsesIntrinsicHeight(for: style) ? .infinity : nil
    }

    private func keyValueUsesIntrinsicHeight(for style: CardViewPresentableModel.Style) -> Bool {
        switch style.hStackViewDistribution {
        case .fill:
            return false
        default:
            return true
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
            .frame(maxWidth: .infinity, alignment: .center)
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
    private func imageView(
        _ model: ImageViewPresentableModel?,
        adapter: ImageViewOutputSwiftUIAdapter,
        tintColor: Color? = .black
    ) -> some View {
        if model != nil {
            if let tintColor {
                SUIImageView(adapter: adapter)
                    .accentColor(SwiftUIColor(tintColor))
            } else {
                SUIImageView(adapter: adapter)
            }
        }
    }

    @ViewBuilder
    private var switchView: some View {
        if stateModel.switchControl != nil {
            SUISwitchControl(adapter: stateModel.switchControlAdapter)
        }
    }

    @ViewBuilder
    private var bottomSeparator: some View {
        if let separator = stateModel.bottomSeparator {
            SwiftUIColor.clear
                .frame(height: separator.height)
                .overlay {
                    SwiftUIColor(separator.color)
                        .padding(separator.padding.asSUIEdgeInsets)
                }
        }
    }

    @ViewBuilder
    private var bottomImage: some View {
        if stateModel.bottomImage != nil {
            HStack(spacing: 0) {
                SUIImageView(adapter: stateModel.bottomImageAdapter)
                Spacer(minLength: 0)
            }
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

struct CardFillRole: Equatable {
    let canCompress: Bool
    let expansionPriority: CardFillExpansionPriority?

    var canExpand: Bool { expansionPriority != nil }

    static let flexibleText = Self(canCompress: true, expansionPriority: .flexibleText)
    // UIKit gives subtitleLabel required horizontal compression resistance.
    // Preserve that priority and clip only its allocated viewport as a final
    // overflow safeguard when even required content cannot fit.
    static let subtitle = Self(canCompress: false, expansionPriority: .subtitle)
    static let fixed = Self(canCompress: false, expansionPriority: nil)
}

enum CardFillExpansionPriority: Int, Equatable {
    case subtitle
    case flexibleText
}

struct CardFillItemMetadata: Equatable {
    let role: CardFillRole
    let leadingSpacing: CGFloat?

    static let fixed = Self(role: .fixed, leadingSpacing: nil)
}

struct CardFillHorizontalResolution: Equatable {
    let widths: [CGFloat]
    let origins: [CGFloat]
}

enum CardFillHorizontalResolver {
    static func resolve(
        idealWidths: [CGFloat],
        breakpointWidths: [CGFloat]? = nil,
        items: [CardFillItemMetadata],
        availableWidth: CGFloat,
        defaultSpacing: CGFloat
    ) -> CardFillHorizontalResolution {
        guard !idealWidths.isEmpty else {
            return .init(widths: [], origins: [])
        }

        let metadata = normalizedMetadata(items, count: idealWidths.count)
        var gaps = resolvedGaps(items: metadata, defaultSpacing: defaultSpacing)
        var widths = idealWidths.map { max($0, 0) }
        let availableForItems = max(max(availableWidth, 0) - gaps.reduce(0, +), 0)
        let highestPriority = metadata.compactMap { $0.role.expansionPriority?.rawValue }.max()
        let expansionRecipient = highestPriority.flatMap { priority in
            metadata.indices.last(where: { metadata[$0].role.expansionPriority?.rawValue == priority })
        }

        if let breakpointWidths, let expansionRecipient {
            for index in widths.indices
            where index < expansionRecipient && metadata[index].role.canCompress {
                let breakpoint = breakpointWidths.indices.contains(index)
                    ? max(breakpointWidths[index], 0)
                    : widths[index]
                widths[index] = min(widths[index], breakpoint)
            }
        }

        let resolvedTotal = widths.reduce(0, +)

        if availableForItems >= resolvedTotal {
            let recipient = expansionRecipient ?? widths.indices.last
            if let recipient {
                widths[recipient] += availableForItems - resolvedTotal
            }
        } else {
            var shortage = max(
                resolvedTotal + gaps.reduce(0, +) - max(availableWidth, 0),
                0
            )
            for index in widths.indices where metadata[index].role.canCompress && shortage > 0 {
                let reduction = min(widths[index], shortage)
                widths[index] -= reduction
                shortage -= reduction
            }

            // A card can still be proposed an exceptionally narrow width where
            // fixed images and controls alone do not fit. SwiftUI layouts must
            // nevertheless stay inside that proposal. Clip fixed viewports only
            // as a last resort, after every text viewport has been compressed.
            for index in widths.indices where !metadata[index].role.canCompress && shortage > 0 {
                let reduction = min(widths[index], shortage)
                widths[index] -= reduction
                shortage -= reduction
            }

            for index in gaps.indices.reversed() where shortage > 0 {
                let reduction = min(gaps[index], shortage)
                gaps[index] -= reduction
                shortage -= reduction
            }
        }

        var x: CGFloat = 0
        let origins = widths.indices.map { index in
            x += gaps[index]
            defer { x += widths[index] }
            return x
        }
        return .init(widths: widths, origins: origins)
    }

    static func intrinsicWidth(
        idealWidths: [CGFloat],
        items: [CardFillItemMetadata],
        defaultSpacing: CGFloat
    ) -> CGFloat {
        let metadata = normalizedMetadata(items, count: idealWidths.count)
        return idealWidths.map { max($0, 0) }.reduce(0, +)
            + resolvedGaps(items: metadata, defaultSpacing: defaultSpacing).reduce(0, +)
    }

    static func compressionBreakpointWidth(
        idealWidths: [CGFloat],
        breakpointWidths: [CGFloat],
        items: [CardFillItemMetadata],
        defaultSpacing: CGFloat
    ) -> CGFloat {
        let metadata = normalizedMetadata(items, count: idealWidths.count)
        var widths = idealWidths.map { max($0, 0) }
        if let index = widths.indices.first(where: { metadata[$0].role.canCompress }) {
            let breakpoint = breakpointWidths.indices.contains(index)
                ? max(breakpointWidths[index], 0)
                : widths[index]
            widths[index] = min(widths[index], breakpoint)
        }
        return widths.reduce(0, +)
            + resolvedGaps(items: metadata, defaultSpacing: defaultSpacing).reduce(0, +)
    }

    private static func normalizedMetadata(
        _ items: [CardFillItemMetadata],
        count: Int
    ) -> [CardFillItemMetadata] {
        (0..<count).map { index in
            items.indices.contains(index) ? items[index] : .fixed
        }
    }

    private static func resolvedGaps(
        items: [CardFillItemMetadata],
        defaultSpacing: CGFloat
    ) -> [CGFloat] {
        items.indices.map { index in
            guard index > 0 else { return 0 }
            return items[index].leadingSpacing ?? defaultSpacing
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct CardFillItemMetadataKey: LayoutValueKey {
    static let defaultValue = CardFillItemMetadata.fixed
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct CardFillViewportLayout: Layout {
    let measuresContentAtProposedWidth: Bool

    init(measuresContentAtProposedWidth: Bool = false) {
        self.measuresContentAtProposedWidth = measuresContentAtProposedWidth
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else { return .zero }
        if proposal.width == 0, proposal.height == nil {
            return subview.sizeThatFits(proposal)
        }
        let width = finite(proposal.width)
        let ideal = subview.sizeThatFits(.unspecified)
        let measured: CGSize
        if measuresContentAtProposedWidth, let width {
            measured = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
        } else {
            measured = ideal
        }
        return CGSize(
            width: width ?? ideal.width,
            height: finite(proposal.height) ?? measured.height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else { return }
        subview.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
        )
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct CardFillHorizontalLayout: Layout {
    let defaultSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let isCompressionBreakpointProbe = proposal.width == 0 && proposal.height == nil
        let measured: [(
            index: Int,
            ideal: CGSize,
            breakpointWidth: CGFloat,
            metadata: CardFillItemMetadata
        )] = subviews.enumerated().compactMap { index, subview in
            let ideal = subview.sizeThatFits(.unspecified)
            guard isVisible(ideal) else { return nil }
            let breakpointWidth = subview.sizeThatFits(
                ProposedViewSize(width: 0, height: nil)
            ).width
            return (index, ideal, breakpointWidth, subview[CardFillItemMetadataKey.self])
        }
        let idealWidths = measured.map(\.ideal.width)
        let items = measured.map(\.metadata)
        let proposedWidth = finite(proposal.width)
        let intrinsicHeight: CGFloat
        if !isCompressionBreakpointProbe, let proposedWidth {
            let resolution = CardFillHorizontalResolver.resolve(
                idealWidths: idealWidths,
                breakpointWidths: measured.map(\.breakpointWidth),
                items: items,
                availableWidth: proposedWidth,
                defaultSpacing: defaultSpacing
            )
            intrinsicHeight = zip(measured, resolution.widths).map { item, width in
                subviews[item.index].sizeThatFits(
                    ProposedViewSize(width: width, height: nil)
                ).height
            }.max() ?? 0
        } else {
            intrinsicHeight = measured.map(\.ideal.height).max() ?? 0
        }
        return CGSize(
            width: isCompressionBreakpointProbe
                ? CardFillHorizontalResolver.compressionBreakpointWidth(
                    idealWidths: idealWidths,
                    breakpointWidths: measured.map(\.breakpointWidth),
                    items: items,
                    defaultSpacing: defaultSpacing
                )
                : proposedWidth ?? CardFillHorizontalResolver.intrinsicWidth(
                    idealWidths: idealWidths,
                    items: items,
                    defaultSpacing: defaultSpacing
                ),
            height: finite(proposal.height) ?? intrinsicHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let measured = subviews.enumerated().compactMap { index, subview
            -> (index: Int, size: CGSize, breakpointWidth: CGFloat, metadata: CardFillItemMetadata)? in
            let size = subview.sizeThatFits(.unspecified)
            guard isVisible(size) else { return nil }
            let breakpointWidth = subview.sizeThatFits(
                ProposedViewSize(width: 0, height: nil)
            ).width
            return (index, size, breakpointWidth, subview[CardFillItemMetadataKey.self])
        }
        let resolution = CardFillHorizontalResolver.resolve(
            idealWidths: measured.map(\.size.width),
            breakpointWidths: measured.map(\.breakpointWidth),
            items: measured.map(\.metadata),
            availableWidth: bounds.width,
            defaultSpacing: defaultSpacing
        )

        for (position, item) in measured.enumerated() {
            let width = resolution.widths[position]
            let allocatedSize = subviews[item.index].sizeThatFits(
                ProposedViewSize(width: width, height: nil)
            )
            let height = min(max(allocatedSize.height, 0), max(bounds.height, 0))
            subviews[item.index].place(
                at: CGPoint(
                    x: bounds.minX + resolution.origins[position],
                    y: bounds.midY - height / 2
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: width,
                    height: height
                )
            )
        }
    }

    private func isVisible(_ size: CGSize) -> Bool {
        size.width > 0 && size.height > 0
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct CardDistributedHorizontalLayout: Layout {
    let distribution: StackViewDistribution
    let minimumSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let visibleSizes = sizes.filter(isVisible)
        let idealWidth = visibleSizes.reduce(0) { $0 + $1.width }
            + minimumSpacing * CGFloat(max(visibleSizes.count - 1, 0))
        return CGSize(
            width: proposal.width ?? idealWidth,
            height: proposal.height ?? visibleSizes.map(\.height).max() ?? 0
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let measured = subviews.enumerated().compactMap { index, subview -> (Int, CGSize)? in
            let size = subview.sizeThatFits(.unspecified)
            return isVisible(size) ? (index, size) : nil
        }
        guard !measured.isEmpty else { return }

        let positions = CardHorizontalDistributionResolver.origins(
            widths: measured.map(\.1.width),
            availableWidth: bounds.width,
            minimumSpacing: minimumSpacing,
            distribution: distribution
        )
        for ((index, size), x) in zip(measured, positions) {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + x, y: bounds.midY - size.height / 2),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }

    private func isVisible(_ size: CGSize) -> Bool {
        size.width > 0 && size.height > 0
    }
}

enum CardHorizontalDistributionResolver {
    static func origins(
        widths: [CGFloat],
        availableWidth: CGFloat,
        minimumSpacing: CGFloat,
        distribution: StackViewDistribution
    ) -> [CGFloat] {
        guard widths.count > 1 else {
            return [(availableWidth - (widths.first ?? 0)) / 2]
        }

        let totalWidth = widths.reduce(0, +)
        if distribution == .equalCentering {
            let firstCenter = widths[0] / 2
            let lastCenter = availableWidth - widths[widths.count - 1] / 2
            let centerStep = (lastCenter - firstCenter) / CGFloat(widths.count - 1)
            let origins = widths.indices.map { index in
                firstCenter + centerStep * CGFloat(index) - widths[index] / 2
            }
            let hasRequiredSpacing = zip(origins, origins.dropFirst()).enumerated().allSatisfy { index, pair in
                pair.1 - (pair.0 + widths[index]) >= minimumSpacing
            }
            if hasRequiredSpacing {
                return origins
            }
        }

        let resolvedSpacing = max(
            minimumSpacing,
            (availableWidth - totalWidth) / CGFloat(widths.count - 1)
        )
        var x: CGFloat = 0
        return widths.map { width in
            defer { x += width + resolvedSpacing }
            return x
        }
    }
}

private struct CardBackgroundImageView: View {
    let model: ImageViewPresentableModel

    var body: some View {
        GeometryReader { proxy in
            let shape = RoundedRectangle(
                cornerRadius: model.cornerRadius ?? 0,
                style: .circular
            )
            backgroundContent(in: proxy.size)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .clipShape(shape)
                .overlay {
                    if let borderColor = model.borderColor,
                       let borderWidth = model.borderWidth {
                        shape
                            .strokeBorder(SwiftUIColor(borderColor), lineWidth: borderWidth)
                    }
                }
        }
        .opacity(model.alpha ?? 1)
    }

    @ViewBuilder
    private func backgroundContent(in availableSize: CGSize) -> some View {
        SUIImageViewView(model: contentModel(size: availableSize))
    }

    private func contentModel(size: CGSize) -> ImageViewPresentableModel {
        .init(
            accessibilityIdentifier: model.accessibilityIdentifier,
            accessibility: model.accessibility,
            size: size,
            image: model.image,
            onPress: model.onPress,
            onLongPress: model.onLongPress,
            contentModeIsFit: model.contentModeIsFit
        )
    }
}

private struct CardBorderOverlay: View {
    let style: CardViewPresentableModel.Style
    let gradientBorderColors: [Color]?

    var body: some View {
        ZStack {
            if let borderColor = style.borderColor,
               let borderWidth = style.borderWidth {
                CardCornerShape(style: style.cornerStyle)
                    .strokeBorder(SwiftUIColor(borderColor), lineWidth: borderWidth)
            }

            if let gradientBorderColors, !gradientBorderColors.isEmpty {
                AnimatedCardGradientBorder(
                    cornerStyle: style.cornerStyle,
                    colors: gradientBorderColors
                )
            }
        }
    }
}

private struct AnimatedCardGradientBorder: View {
    let cornerStyle: CornerStyle
    let colors: [Color]

    @State private var rotation: Double = 0

    var body: some View {
        CardCornerShape(style: cornerStyle)
            .strokeBorder(
                AngularGradient(
                    colors: colors.map(SwiftUIColor.init),
                    center: .center,
                    angle: .degrees(rotation)
                ),
                lineWidth: 2
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 0.3 * Double(max(colors.count, 1)))
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

private struct CardCornerShape: InsettableShape {
    let style: CornerStyle
    private var insetAmount: CGFloat = 0

    init(style: CornerStyle) {
        self.style = style
    }

    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radii = cornerRadii(in: insetRect)

        switch style {
        case .automatic:
            return Capsule(style: resolvedRoundedCornerStyle).path(in: insetRect)
        case .fixed:
            return RoundedRectangle(
                cornerRadius: radii.topLeft,
                style: resolvedRoundedCornerStyle
            ).path(in: insetRect)
        case .none:
            return Rectangle().path(in: insetRect)
        case .corners:
            break
        }

        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *) {
            return UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: radii.topLeft,
                    bottomLeading: radii.bottomLeft,
                    bottomTrailing: radii.bottomRight,
                    topTrailing: radii.topRight
                ),
                style: .continuous
            ).path(in: insetRect)
        }

        var path = Path()

        path.move(to: CGPoint(x: insetRect.minX + radii.topLeft, y: insetRect.minY))
        path.addLine(to: CGPoint(x: insetRect.maxX - radii.topRight, y: insetRect.minY))
        addArc(
            to: &path,
            center: CGPoint(x: insetRect.maxX - radii.topRight, y: insetRect.minY + radii.topRight),
            radius: radii.topRight,
            startAngle: -90,
            endAngle: 0
        )
        path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY - radii.bottomRight))
        addArc(
            to: &path,
            center: CGPoint(
                x: insetRect.maxX - radii.bottomRight,
                y: insetRect.maxY - radii.bottomRight
            ),
            radius: radii.bottomRight,
            startAngle: 0,
            endAngle: 90
        )
        path.addLine(to: CGPoint(x: insetRect.minX + radii.bottomLeft, y: insetRect.maxY))
        addArc(
            to: &path,
            center: CGPoint(
                x: insetRect.minX + radii.bottomLeft,
                y: insetRect.maxY - radii.bottomLeft
            ),
            radius: radii.bottomLeft,
            startAngle: 90,
            endAngle: 180
        )
        path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.minY + radii.topLeft))
        addArc(
            to: &path,
            center: CGPoint(x: insetRect.minX + radii.topLeft, y: insetRect.minY + radii.topLeft),
            radius: radii.topLeft,
            startAngle: 180,
            endAngle: 270
        )
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> CardCornerShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    private var resolvedRoundedCornerStyle: RoundedCornerStyle {
        .continuous
    }

    private func addArc(
        to path: inout Path,
        center: CGPoint,
        radius: CGFloat,
        startAngle: Double,
        endAngle: Double
    ) {
        guard radius > 0 else {
            path.addLine(to: center)
            return
        }
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
    }

    private func cornerRadii(in rect: CGRect) -> CornerStyle.Corners {
        let maximumRadius = max(min(rect.width, rect.height) / 2, 0)
        let source: CornerStyle.Corners
        switch style {
        case .automatic:
            source = .init(all: maximumRadius)
        case .fixed(let radius):
            source = .init(all: max(radius - insetAmount, 0))
        case .corners(let corners):
            source = .init(
                topLeft: max(corners.topLeft - insetAmount, 0),
                topRight: max(corners.topRight - insetAmount, 0),
                bottomLeft: max(corners.bottomLeft - insetAmount, 0),
                bottomRight: max(corners.bottomRight - insetAmount, 0)
            )
        case .none:
            source = .init(topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0)
        }
        return .init(
            topLeft: min(source.topLeft, maximumRadius),
            topRight: min(source.topRight, maximumRadius),
            bottomLeft: min(source.bottomLeft, maximumRadius),
            bottomRight: min(source.bottomRight, maximumRadius)
        )
    }
}

private struct CardAccessibilityModifier: ViewModifier {
    let identifier: String?
    let label: String?
    let hint: String?
    let onPress: (() -> Void)?
    let onLongPress: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .ifLet(identifier) { view, identifier in
                view.accessibilityIdentifier(identifier)
            }
            .ifLet(label) { view, label in
                view.accessibilityLabel(SwiftUI.Text(label))
            }
            .ifLet(hint) { view, hint in
                view.accessibilityHint(SwiftUI.Text(hint))
            }
            .if(onPress != nil || onLongPress != nil) { view in
                view.accessibilityAddTraits(.isButton)
            }
            .ifLet(onPress) { view, action in
                view.accessibilityAction { action() }
            }
            .ifLet(onLongPress) { view, action in
                view.accessibilityAction(named: SwiftUI.Text("More options")) { action() }
            }
    }
}

#endif
