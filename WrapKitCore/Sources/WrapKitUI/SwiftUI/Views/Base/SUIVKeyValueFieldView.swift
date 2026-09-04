//
//  SUIVKeyValueFieldView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIVKeyValueFieldView: View {
    @Environment(\.displayScale) private var displayScale

    struct LayoutConfiguration {
        enum VerticalDistribution {
            case standard
            case fill
        }

        let verticalDistribution: VerticalDistribution
        let keyMinimumScaleFactor: CGFloat?
        let valueMinimumScaleFactor: CGFloat?

        static let standardScaled = Self(
            verticalDistribution: .standard,
            keyMinimumScaleFactor: 0.5,
            valueMinimumScaleFactor: 0.5
        )

        static let uiStackFillWithoutScaling = Self(
            verticalDistribution: .fill,
            keyMinimumScaleFactor: nil,
            valueMinimumScaleFactor: nil
        )
    }

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
    private let layoutConfiguration: LayoutConfiguration

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
        self.init(
            adapter: adapter,
            keyFont: keyFont,
            keyTextColor: keyTextColor,
            valueFont: valueFont,
            valueTextColor: valueTextColor,
            keyTextAlignment: keyTextAlignment,
            valueTextAlignment: valueTextAlignment,
            keyNumberOfLines: keyNumberOfLines,
            valueNumberOfLines: valueNumberOfLines,
            spacing: spacing,
            contentInsets: contentInsets,
            isHidden: isHidden,
            layoutConfiguration: .standardScaled
        )
    }

    init(
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
        isHidden: Bool = false,
        layoutConfiguration: LayoutConfiguration
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
        self.layoutConfiguration = layoutConfiguration
    }

    public var body: some View {
        if !stateModel.isHidden {
            fieldContent
            .padding(contentInsets.asSUIEdgeInsets)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var fieldContent: some View {
        switch layoutConfiguration.verticalDistribution {
        case .standard:
            standardStack
        case .fill:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                SUIVKeyValueFillLayout(
                    spacing: spacing,
                    pixelTolerance: 1 / max(displayScale, 1)
                ) {
                    if !stateModel.isKeySlotHidden {
                        fillItem {
                            keySlot
                        }
                    }
                    if !stateModel.isValueSlotHidden {
                        fillItem {
                            valueSlot
                        }
                    }
                    if !stateModel.isBottomImageSlotHidden {
                        fillItem {
                            bottomImageView
                        }
                    }
                }
            } else {
                standardStack
            }
        }
    }

    private var standardStack: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if !stateModel.isKeySlotHidden {
                keySlot
            }
            if !stateModel.isValueSlotHidden {
                valueSlot
            }
            if !stateModel.isBottomImageSlotHidden {
                bottomImageView
            }
        }
    }

    @ViewBuilder
    private var keySlot: some View {
        if stateModel.keyTitle != nil {
            keyLabel
        } else {
            SwiftUIColor.clear.frame(height: 0)
        }
    }

    @ViewBuilder
    private var valueSlot: some View {
        if stateModel.valueTitle != nil {
            valueLabel
        } else {
            SwiftUIColor.clear.frame(height: 0)
        }
    }

    @ViewBuilder
    private var keyLabel: some View {
        label(
            stateModel.keyTitle,
            font: keyFont,
            textColor: keyTextColor,
            textAlignment: keyTextAlignment,
            numberOfLines: keyNumberOfLines,
            minimumScaleFactor: layoutConfiguration.keyMinimumScaleFactor
        )
    }

    @ViewBuilder
    private var valueLabel: some View {
        label(
            stateModel.valueTitle,
            font: valueFont,
            textColor: valueTextColor,
            textAlignment: valueTextAlignment,
            numberOfLines: valueNumberOfLines,
            minimumScaleFactor: layoutConfiguration.valueMinimumScaleFactor
        )
    }

    private func fillItem(@ViewBuilder content: () -> some View) -> some View {
        SUIVKeyValueFillItem(
            pixelTolerance: 1 / max(displayScale, 1),
            content: content
        )
    }

    @ViewBuilder
    private func label(
        _ model: TextOutputPresentableModel?,
        font: Font,
        textColor: Color,
        textAlignment: TextAlignment,
        numberOfLines: Int,
        minimumScaleFactor: CGFloat?
    ) -> some View {
        if let model {
            SUILabelView(
                model: model,
                font: font,
                textColor: textColor,
                textAlignment: textAlignment
            )
            .lineLimit(numberOfLines == 0 ? nil : numberOfLines)
            .ifLet(minimumScaleFactor) { view, factor in
                view.minimumScaleFactor(factor)
            }
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

private struct SUIVKeyValueFillItem<Content: View>: View {
    let pixelTolerance: CGFloat
    let content: Content

    init(
        pixelTolerance: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.pixelTolerance = pixelTolerance
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            SUIVKeyValueFillItemLayout(pixelTolerance: pixelTolerance) {
                content
            }
            .clipped()
        } else {
            content
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .clipped()
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SUIVKeyValueFillItemLayout: Layout {
    let pixelTolerance: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else { return .zero }
        let ideal = subview.sizeThatFits(.unspecified)
        if isCompressionBreakpointProbe(proposal) {
            return ideal
        }
        let width = finite(proposal.width)
        let measured = width.map {
            subview.sizeThatFits(ProposedViewSize(width: $0, height: nil))
        } ?? ideal
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
        let unspecified = subview.sizeThatFits(.unspecified)
        let measured = subview.sizeThatFits(
            ProposedViewSize(width: bounds.width, height: nil)
        )
        let placement = SUIVKeyValueFillItemResolver.placement(
            boundsMinY: bounds.minY,
            boundsHeight: bounds.height,
            idealHeight: measured.height,
            unspecifiedIdealHeight: unspecified.height,
            usesFiniteWidth: finite(proposal.width) != nil,
            pixelTolerance: pixelTolerance
        )
        subview.place(
            at: CGPoint(
                x: bounds.minX,
                y: placement.originY
            ),
            anchor: .topLeading,
            proposal: ProposedViewSize(
                width: bounds.width,
                height: placement.proposedHeight
            )
        )
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }

    private func isCompressionBreakpointProbe(_ proposal: ProposedViewSize) -> Bool {
        proposal.width == 0 && proposal.height == nil
    }
}

enum SUIVKeyValueFillItemResolver {
    struct Placement: Equatable {
        let originY: CGFloat
        let proposedHeight: CGFloat
    }

    static func placement(
        boundsMinY: CGFloat,
        boundsHeight: CGFloat,
        idealHeight: CGFloat,
        unspecifiedIdealHeight: CGFloat,
        usesFiniteWidth: Bool,
        pixelTolerance: CGFloat
    ) -> Placement {
        let wrappedAtFiniteWidth = idealHeight
            > unspecifiedIdealHeight + max(pixelTolerance, 0)
        if usesFiniteWidth && wrappedAtFiniteWidth && idealHeight > boundsHeight {
            return Placement(
                originY: boundsMinY,
                proposedHeight: max(boundsHeight, 0)
            )
        }
        return Placement(
            originY: centeredOrigin(
                boundsMinY: boundsMinY,
                boundsHeight: boundsHeight,
                idealHeight: idealHeight
            ),
            proposedHeight: idealHeight
        )
    }

    static func centeredOrigin(
        boundsMinY: CGFloat,
        boundsHeight: CGFloat,
        idealHeight: CGFloat
    ) -> CGFloat {
        boundsMinY + (boundsHeight - idealHeight) / 2
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SUIVKeyValueFillLayout: Layout {
    let spacing: CGFloat
    let pixelTolerance: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let isCompressionBreakpointProbe = proposal.width == 0 && proposal.height == nil
        let width = finite(proposal.width)
        let breakpointSizes = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: 0, height: nil))
        }
        let forcedFiniteSizes = width.map { allocatedWidth in
            subviews.map {
                $0.sizeThatFits(ProposedViewSize(width: allocatedWidth, height: nil))
            }
        } ?? []
        let measurementWidth = SUIVKeyValueFillWidthResolver.measurementWidth(
            allocatedWidth: width,
            breakpointSizes: breakpointSizes,
            forcedFiniteSizes: forcedFiniteSizes,
            availableHeight: finite(proposal.height),
            spacing: spacing,
            pixelTolerance: pixelTolerance
        )
        let idealSizes = isCompressionBreakpointProbe
            ? breakpointSizes
            : subviews.map {
                $0.sizeThatFits(ProposedViewSize(width: measurementWidth, height: nil))
            }
        let idealHeight = idealSizes.map(\.height).reduce(0, +)
            + spacing * CGFloat(max(idealSizes.count - 1, 0))
        return CGSize(
            width: isCompressionBreakpointProbe
                ? SUIVKeyValueCompressionBreakpointResolver.firstNonzeroSlotWidth(
                    slotSizes: idealSizes
                )
                : width ?? idealSizes.map(\.width).max() ?? 0,
            height: finite(proposal.height).map { min($0, idealHeight) } ?? idealHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let breakpointSizes = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: 0, height: nil))
        }
        let forcedFiniteSizes = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
        }
        let measurementWidth = SUIVKeyValueFillWidthResolver.measurementWidth(
            allocatedWidth: bounds.width,
            breakpointSizes: breakpointSizes,
            forcedFiniteSizes: forcedFiniteSizes,
            availableHeight: bounds.height,
            spacing: spacing,
            pixelTolerance: pixelTolerance
        )
        let idealSizes = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: measurementWidth, height: nil))
        }
        let heights = SUIVKeyValueFillResolver.resolvedHeights(
            idealHeights: idealSizes.map(\.height),
            availableHeight: bounds.height,
            spacing: spacing
        )
        var y = bounds.minY
        for ((subview, idealSize), height) in zip(zip(subviews, idealSizes), heights) {
            subview.place(
                at: CGPoint(
                    x: SUIVKeyValueFillWidthResolver.itemOriginX(
                        boundsMinX: bounds.minX,
                        boundsWidth: bounds.width,
                        itemIdealWidth: idealSize.width,
                        allocatedWidth: bounds.width,
                        breakpointSizes: breakpointSizes,
                        pixelTolerance: pixelTolerance
                    ),
                    y: y
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: measurementWidth, height: height)
            )
            y += height + spacing
        }
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }
}

enum SUIVKeyValueFillWidthResolver {
    static func measurementWidth(
        allocatedWidth: CGFloat?,
        breakpointSizes: [CGSize],
        forcedFiniteSizes: [CGSize],
        availableHeight: CGFloat?,
        spacing: CGFloat,
        pixelTolerance: CGFloat
    ) -> CGFloat? {
        guard let allocatedWidth, allocatedWidth.isFinite else { return nil }
        let breakpointWidth = SUIVKeyValueCompressionBreakpointResolver.firstNonzeroSlotWidth(
            slotSizes: breakpointSizes
        )
        guard breakpointWidth > 0 else { return nil }

        let finiteWidth = max(allocatedWidth, 0)
        let tolerance = max(pixelTolerance, 0)
        if finiteWidth + tolerance >= breakpointWidth || availableHeight == nil {
            return finiteWidth
        }

        let forcedFiniteHeight = forcedFiniteSizes.map(\.height).reduce(0, +)
            + spacing * CGFloat(max(forcedFiniteSizes.count - 1, 0))
        guard forcedFiniteHeight <= max(availableHeight ?? 0, 0) + tolerance else {
            return nil
        }
        return finiteWidth
    }

    static func itemOriginX(
        boundsMinX: CGFloat,
        boundsWidth: CGFloat,
        itemIdealWidth: CGFloat,
        allocatedWidth: CGFloat,
        breakpointSizes: [CGSize],
        pixelTolerance: CGFloat
    ) -> CGFloat {
        let breakpointWidth = SUIVKeyValueCompressionBreakpointResolver.firstNonzeroSlotWidth(
            slotSizes: breakpointSizes
        )
        guard allocatedWidth.isFinite,
              breakpointWidth > 0,
              allocatedWidth + max(pixelTolerance, 0) < breakpointWidth else {
            return boundsMinX
        }
        return boundsMinX + (max(boundsWidth, 0) - max(itemIdealWidth, 0)) / 2
    }
}

enum SUIVKeyValueCompressionBreakpointResolver {
    static func firstNonzeroSlotWidth(slotSizes: [CGSize]) -> CGFloat {
        slotSizes.first(where: { $0.width > 0 && $0.height > 0 })?.width ?? 0
    }
}

enum SUIVKeyValueFillResolver {
    static func resolvedHeights(
        idealHeights: [CGFloat],
        availableHeight: CGFloat,
        spacing: CGFloat
    ) -> [CGFloat] {
        guard !idealHeights.isEmpty else { return [] }

        var result = idealHeights.map { max($0, 0) }
        let totalSpacing = spacing * CGFloat(max(result.count - 1, 0))
        let availableForChildren = max(availableHeight - totalSpacing, 0)
        var shortage = max(result.reduce(0, +) - availableForChildren, 0)

        for index in result.indices.reversed() where shortage > 0 {
            let reduction = min(result[index], shortage)
            result[index] -= reduction
            shortage -= reduction
        }
        return result
    }
}

#endif
