//
//  SUIStackView.swift
//  WrapKit
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI

public struct SUIStackView<Content: View>: View {
    @StateObject private var stateModel: SUIStackViewStateModel

    private let backgroundColor: Color
    private let clipsToBounds: Bool
    private let content: Content

    public init(
        adapter: StackViewOutputSwiftUIAdapter = StackViewOutputSwiftUIAdapter(),
        backgroundColor: Color = .clear,
        distribution: StackViewDistribution = .fill,
        alignment: StackViewAlignment = .fill,
        axis: StackViewAxis = .horizontal,
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        clipsToBounds: Bool = false,
        isHidden: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        _stateModel = .init(
            wrappedValue: .init(
                adapter: adapter,
                axis: axis,
                distribution: distribution,
                alignment: alignment,
                spacing: spacing,
                layoutMargins: contentInset,
                isHidden: isHidden
            )
        )
        self.backgroundColor = backgroundColor
        self.clipsToBounds = clipsToBounds
        self.content = content()
    }

    public var body: some View {
        if !stateModel.isHidden {
            _VariadicView.Tree(
                SUIStackViewLayoutRoot(
                    axis: stateModel.axis,
                    distribution: stateModel.distribution,
                    alignment: stateModel.alignment,
                    spacing: stateModel.spacing
                )
            ) {
                content
            }
            .padding(stateModel.layoutMargins.asSUIEdgeInsets)
            .background(SwiftUIColor(backgroundColor))
            .if(clipsToBounds) { $0.clipped() }
        }
    }
}

public extension SUIStackView where Content == SwiftUICore.EmptyView {
    init(
        adapter: StackViewOutputSwiftUIAdapter = StackViewOutputSwiftUIAdapter(),
        backgroundColor: Color = .clear,
        distribution: StackViewDistribution = .fill,
        alignment: StackViewAlignment = .fill,
        axis: StackViewAxis = .horizontal,
        spacing: CGFloat = 0,
        contentInset: EdgeInsets = .zero,
        clipsToBounds: Bool = false,
        isHidden: Bool = false
    ) {
        self.init(
            adapter: adapter,
            backgroundColor: backgroundColor,
            distribution: distribution,
            alignment: alignment,
            axis: axis,
            spacing: spacing,
            contentInset: contentInset,
            clipsToBounds: clipsToBounds,
            isHidden: isHidden
        ) {
            SwiftUICore.EmptyView()
        }
    }
}

private struct SUIStackViewLayoutRoot: _VariadicView_MultiViewRoot {
    let axis: StackViewAxis
    let distribution: StackViewDistribution
    let alignment: StackViewAlignment
    let spacing: CGFloat

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            SUIStackLayout(
                axis: axis,
                distribution: distribution,
                alignment: alignment,
                spacing: spacing
            ) {
                ForEach(children) { child in
                    layoutChild(child)
                }
            }
        } else {
            legacyLayout(children: children)
        }
    }

    @ViewBuilder
    private func layoutChild(_ child: _VariadicView.Children.Element) -> some View {
        if alignment == .fill {
            switch axis {
            case .horizontal:
                child.frame(maxHeight: .infinity)
            case .vertical:
                child.frame(maxWidth: .infinity)
            }
        } else {
            child
        }
    }

    @ViewBuilder
    private func legacyLayout(children: _VariadicView.Children) -> some View {
        switch axis {
        case .horizontal:
            HStack(alignment: verticalAlignment, spacing: legacySpacing) {
                ForEach(children) { child in
                    legacyHorizontalChild(child)
                    if distribution == .equalSpacing,
                       child.id != children.last?.id {
                        Spacer(minLength: spacing)
                    }
                }
            }
        case .vertical:
            VStack(alignment: horizontalAlignment, spacing: legacySpacing) {
                ForEach(children) { child in
                    legacyVerticalChild(child)
                    if distribution == .equalSpacing,
                       child.id != children.last?.id {
                        Spacer(minLength: spacing)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func legacyHorizontalChild(_ child: _VariadicView.Children.Element) -> some View {
        switch distribution {
        case .fillEqually, .equalCentering:
            layoutChild(child).frame(maxWidth: .infinity)
        default:
            layoutChild(child)
        }
    }

    @ViewBuilder
    private func legacyVerticalChild(_ child: _VariadicView.Children.Element) -> some View {
        switch distribution {
        case .fillEqually, .equalCentering:
            layoutChild(child).frame(maxHeight: .infinity)
        default:
            layoutChild(child)
        }
    }

    private var legacySpacing: CGFloat? {
        switch distribution {
        case .equalSpacing:
            return 0
        default:
            return spacing
        }
    }

    private var verticalAlignment: VerticalAlignment {
        switch alignment {
        case .top, .leading:
            return .top
        case .center, .fill:
            return .center
        case .bottom, .trailing:
            return .bottom
        case .firstBaseline:
            return .firstTextBaseline
        case .lastBaseline:
            return .lastTextBaseline
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
        switch alignment {
        case .leading, .top:
            return .leading
        case .center, .fill, .firstBaseline, .lastBaseline:
            return .center
        case .trailing, .bottom:
            return .trailing
        }
    }
}

struct StackMainAxisResolution: Equatable {
    let origins: [CGFloat]
    let lengths: [CGFloat]
    let containerLength: CGFloat
}

/// Pure geometry shared by the SwiftUI stack layout and other components that
/// need UIStackView-compatible main-axis distribution.
enum StackMainAxisResolver {
    static func resolve(
        idealLengths: [CGFloat],
        minimumLengths: [CGFloat] = [],
        priorities: [Double] = [],
        proposedLength: CGFloat?,
        distribution: StackViewDistribution,
        spacing: CGFloat
    ) -> StackMainAxisResolution {
        let ideals = idealLengths.map(normalizedLength)
        let minimums = ideals.indices.map { index in
            guard minimumLengths.indices.contains(index) else { return CGFloat.zero }
            return min(ideals[index], normalizedLength(minimumLengths[index]))
        }
        let itemPriorities = ideals.indices.map { index in
            priorities.indices.contains(index) ? priorities[index] : 0
        }
        guard !ideals.isEmpty else {
            return .init(origins: [], lengths: [], containerLength: 0)
        }

        let proposed = normalizedProposal(proposedLength)
        switch distribution {
        case .fill:
            return sequentialResolution(
                lengths: fillLengths(
                    ideals: ideals,
                    minimums: minimums,
                    priorities: itemPriorities,
                    proposedLength: proposed,
                    spacing: spacing
                ),
                proposedLength: proposed,
                spacing: spacing
            )
        case .fillEqually:
            return sequentialResolution(
                lengths: equalLengths(
                    ideals: ideals,
                    proposedLength: proposed,
                    spacing: spacing
                ),
                proposedLength: proposed,
                spacing: spacing
            )
        case .fillProportionally:
            return sequentialResolution(
                lengths: proportionalLengths(
                    ideals: ideals,
                    priorities: itemPriorities,
                    proposedLength: proposed,
                    spacing: spacing
                ),
                proposedLength: proposed,
                spacing: spacing
            )
        case .equalSpacing:
            return equalSpacingResolution(
                ideals: ideals,
                minimums: minimums,
                proposedLength: proposed,
                minimumSpacing: spacing
            )
        case .equalCentering:
            return equalCenteringResolution(
                ideals: ideals,
                proposedLength: proposed,
                minimumSpacing: spacing
            )
        }
    }
}

struct StackCrossAxisResolution: Equatable {
    let origins: [CGFloat]
    let lengths: [CGFloat]
    let containerLength: CGFloat
}

enum StackCrossAxisResolver {
    static func resolve(
        idealLengths: [CGFloat],
        proposedLength: CGFloat?,
        alignment: StackViewAlignment,
        baselineOffsets: [CGFloat] = []
    ) -> StackCrossAxisResolution {
        let lengths = idealLengths.map { $0.isFinite ? max(0, $0) : 0 }
        guard !lengths.isEmpty else {
            return .init(origins: [], lengths: [], containerLength: 0)
        }

        if alignment == .firstBaseline || alignment == .lastBaseline,
           baselineOffsets.count == lengths.count {
            let baselines = baselineOffsets.map { $0.isFinite ? max(0, $0) : 0 }
            let commonBaseline = baselines.max() ?? 0
            let origins = baselines.map { commonBaseline - $0 }
            let intrinsicLength = zip(origins, lengths).map(+).max() ?? 0
            return .init(
                origins: origins,
                lengths: lengths,
                containerLength: normalizedProposal(proposedLength) ?? intrinsicLength
            )
        }

        let intrinsicLength = lengths.max() ?? 0
        let containerLength = normalizedProposal(proposedLength) ?? intrinsicLength
        if alignment == .fill {
            return .init(
                origins: Array(repeating: 0, count: lengths.count),
                lengths: Array(repeating: containerLength, count: lengths.count),
                containerLength: containerLength
            )
        }

        let origins = lengths.map { length in
            let freeLength = max(0, containerLength - length)
            switch alignment {
            case .leading, .top:
                return CGFloat.zero
            case .center, .firstBaseline, .lastBaseline:
                return freeLength / 2
            case .trailing, .bottom:
                return freeLength
            case .fill:
                return CGFloat.zero
            }
        }
        return .init(
            origins: origins,
            lengths: lengths,
            containerLength: containerLength
        )
    }
}

private extension StackCrossAxisResolver {
    static func normalizedProposal(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(0, value)
    }
}

private extension StackMainAxisResolver {
    static func fillLengths(
        ideals: [CGFloat],
        minimums: [CGFloat],
        priorities: [Double],
        proposedLength: CGFloat?,
        spacing: CGFloat
    ) -> [CGFloat] {
        guard let proposedLength else { return ideals }
        let itemBudget = availableItemLength(
            containerLength: proposedLength,
            itemCount: ideals.count,
            spacing: spacing
        )
        let idealTotal = ideals.reduce(0, +)
        if itemBudget < idealTotal {
            return compressedLengths(
                ideals: ideals,
                minimums: minimums,
                itemBudget: itemBudget
            )
        }
        guard itemBudget > idealTotal, !ideals.isEmpty else { return ideals }

        var result = ideals
        let stretchIndex = adjustmentIndex(priorities: priorities)
        result[stretchIndex] += itemBudget - idealTotal
        return result
    }

    static func equalLengths(
        ideals: [CGFloat],
        proposedLength: CGFloat?,
        spacing: CGFloat
    ) -> [CGFloat] {
        guard let proposedLength else {
            return Array(repeating: ideals.max() ?? 0, count: ideals.count)
        }
        let itemBudget = availableItemLength(
            containerLength: proposedLength,
            itemCount: ideals.count,
            spacing: spacing
        )
        return Array(repeating: itemBudget / CGFloat(ideals.count), count: ideals.count)
    }

    static func proportionalLengths(
        ideals: [CGFloat],
        priorities: [Double],
        proposedLength: CGFloat?,
        spacing: CGFloat
    ) -> [CGFloat] {
        guard let proposedLength else { return ideals }
        let gapCount = max(0, ideals.count - 1)
        let resolvedSpacing = spacingThatFits(
            spacing,
            gapCount: gapCount,
            containerLength: proposedLength
        )
        let itemBudget = availableItemLength(
            containerLength: proposedLength,
            itemCount: ideals.count,
            spacing: spacing
        )
        let idealTotal = ideals.reduce(0, +)
        let intrinsicContainerLength = idealTotal
            + resolvedSpacing * CGFloat(gapCount)
        guard intrinsicContainerLength > 0, idealTotal > 0 else {
            return Array(repeating: itemBudget / CGFloat(ideals.count), count: ideals.count)
        }

        // UIStackView forms its proportional constraints against the stack's
        // complete intrinsic length, including spacing. The lowest-priority
        // arranged subview absorbs the residual required by the exact canvas
        // connections. Scaling only the post-spacing item budget produces a
        // visibly different layout whenever spacing is non-zero.
        var result = ideals.map {
            proposedLength * $0 / intrinsicContainerLength
        }
        let adjustment = itemBudget - result.reduce(0, +)
        let index = adjustmentIndex(priorities: priorities)
        if result[index] + adjustment >= 0 {
            result[index] += adjustment
            return result
        }

        result[index] = 0
        let remainingTotal = result.reduce(0, +)
        guard remainingTotal > 0 else {
            return Array(repeating: 0, count: ideals.count)
        }
        return result.map { itemBudget * $0 / remainingTotal }
    }

    static func adjustmentIndex(priorities: [Double]) -> Int {
        priorities.indices.min { lhs, rhs in
            if priorities[lhs] == priorities[rhs] {
                return lhs > rhs
            }
            return priorities[lhs] < priorities[rhs]
        } ?? priorities.index(before: priorities.endIndex)
    }

    static func equalSpacingResolution(
        ideals: [CGFloat],
        minimums: [CGFloat],
        proposedLength: CGFloat?,
        minimumSpacing: CGFloat
    ) -> StackMainAxisResolution {
        let gapCount = max(0, ideals.count - 1)
        guard let proposedLength else {
            return sequentialResolution(
                lengths: ideals,
                proposedLength: nil,
                spacing: minimumSpacing
            )
        }

        let resolvedSpacing = spacingThatFits(
            minimumSpacing,
            gapCount: gapCount,
            containerLength: proposedLength
        )
        let itemBudget = max(0, proposedLength - resolvedSpacing * CGFloat(gapCount))
        let idealTotal = ideals.reduce(0, +)
        let lengths = itemBudget < idealTotal
            ? compressedLengths(ideals: ideals, minimums: minimums, itemBudget: itemBudget)
            : ideals
        let usedItemLength = lengths.reduce(0, +)
        let spacing = gapCount > 0
            ? max(resolvedSpacing, (proposedLength - usedItemLength) / CGFloat(gapCount))
            : 0
        return sequentialResolution(
            lengths: lengths,
            proposedLength: proposedLength,
            spacing: spacing
        )
    }

    static func equalCenteringResolution(
        ideals: [CGFloat],
        proposedLength: CGFloat?,
        minimumSpacing: CGFloat
    ) -> StackMainAxisResolution {
        guard ideals.count > 1 else {
            let containerLength = proposedLength ?? ideals[0]
            return .init(
                origins: [max(0, (containerLength - ideals[0]) / 2)],
                lengths: ideals,
                containerLength: containerLength
            )
        }

        let gapCount = ideals.count - 1
        let resolvedSpacing: CGFloat
        let lengths: [CGFloat]
        let containerLength: CGFloat
        if let proposedLength {
            containerLength = proposedLength
            resolvedSpacing = spacingThatFits(
                minimumSpacing,
                gapCount: gapCount,
                containerLength: proposedLength
            )
            lengths = scaledForEqualCentering(
                ideals,
                containerLength: proposedLength,
                spacing: resolvedSpacing
            )
        } else {
            resolvedSpacing = minimumSpacing
            lengths = ideals
            containerLength = equalCenteringRequiredLength(
                lengths: ideals,
                spacing: minimumSpacing
            )
        }

        let centerDistance = max(
            maximumCenterDistance(lengths: lengths, spacing: resolvedSpacing),
            (containerLength - lengths[0] / 2 - lengths[lengths.count - 1] / 2)
                / CGFloat(gapCount)
        )
        let firstCenter = lengths[0] / 2
        let origins = lengths.indices.map { index in
            firstCenter + CGFloat(index) * centerDistance - lengths[index] / 2
        }
        return .init(
            origins: origins,
            lengths: lengths,
            containerLength: containerLength
        )
    }

    static func scaledForEqualCentering(
        _ ideals: [CGFloat],
        containerLength: CGFloat,
        spacing: CGFloat
    ) -> [CGFloat] {
        guard equalCenteringRequiredLength(lengths: ideals, spacing: spacing) > containerLength else {
            return ideals
        }

        var lowerBound: CGFloat = 0
        var upperBound: CGFloat = 1
        for _ in 0..<32 {
            let scale = (lowerBound + upperBound) / 2
            let candidate = ideals.map { $0 * scale }
            if equalCenteringRequiredLength(lengths: candidate, spacing: spacing) <= containerLength {
                lowerBound = scale
            } else {
                upperBound = scale
            }
        }
        return ideals.map { $0 * lowerBound }
    }

    static func equalCenteringRequiredLength(
        lengths: [CGFloat],
        spacing: CGFloat
    ) -> CGFloat {
        guard lengths.count > 1 else { return lengths.first ?? 0 }
        return lengths[0] / 2
            + maximumCenterDistance(lengths: lengths, spacing: spacing)
                * CGFloat(lengths.count - 1)
            + lengths[lengths.count - 1] / 2
    }

    static func maximumCenterDistance(
        lengths: [CGFloat],
        spacing: CGFloat
    ) -> CGFloat {
        zip(lengths, lengths.dropFirst())
            .map { ($0 + $1) / 2 + spacing }
            .max() ?? 0
    }

    static func compressedLengths(
        ideals: [CGFloat],
        minimums: [CGFloat],
        itemBudget: CGFloat
    ) -> [CGFloat] {
        let budget = max(0, itemBudget)
        let idealTotal = ideals.reduce(0, +)
        guard idealTotal > budget, idealTotal > 0 else { return ideals }

        let minimumTotal = minimums.reduce(0, +)
        if minimumTotal >= budget {
            guard minimumTotal > 0 else { return Array(repeating: 0, count: ideals.count) }
            return minimums.map { budget * $0 / minimumTotal }
        }

        let compression = idealTotal - budget
        let capacities = zip(ideals, minimums).map(-)
        let capacityTotal = capacities.reduce(0, +)
        guard capacityTotal > 0 else {
            return ideals.map { budget * $0 / idealTotal }
        }
        return zip(ideals, capacities).map { ideal, capacity in
            ideal - compression * capacity / capacityTotal
        }
    }

    static func sequentialResolution(
        lengths: [CGFloat],
        proposedLength: CGFloat?,
        spacing: CGFloat
    ) -> StackMainAxisResolution {
        let gapCount = max(0, lengths.count - 1)
        let containerLength = proposedLength
            ?? max(0, lengths.reduce(0, +) + spacing * CGFloat(gapCount))
        let resolvedSpacing = spacingThatFits(
            spacing,
            gapCount: gapCount,
            containerLength: containerLength
        )
        var cursor: CGFloat = 0
        let origins = lengths.map { length in
            defer { cursor += length + resolvedSpacing }
            return cursor
        }
        return .init(
            origins: origins,
            lengths: lengths,
            containerLength: containerLength
        )
    }

    static func availableItemLength(
        containerLength: CGFloat,
        itemCount: Int,
        spacing: CGFloat
    ) -> CGFloat {
        let gapCount = max(0, itemCount - 1)
        let resolvedSpacing = spacingThatFits(
            spacing,
            gapCount: gapCount,
            containerLength: containerLength
        )
        return max(0, containerLength - resolvedSpacing * CGFloat(gapCount))
    }

    static func spacingThatFits(
        _ spacing: CGFloat,
        gapCount: Int,
        containerLength: CGFloat
    ) -> CGFloat {
        guard gapCount > 0, spacing > 0 else { return spacing }
        return min(spacing, containerLength / CGFloat(gapCount))
    }

    static func normalizedLength(_ value: CGFloat) -> CGFloat {
        value.isFinite ? max(0, value) : 0
    }

    static func normalizedProposal(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(0, value)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SUIStackLayout: Layout {
    let axis: StackViewAxis
    let distribution: StackViewDistribution
    let alignment: StackViewAlignment
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        resolvedLayout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let resolved = resolvedLayout(
            proposal: .init(width: bounds.width, height: bounds.height),
            subviews: subviews
        )
        for index in subviews.indices {
            let size = resolved.childSizes[index]
            let point: CGPoint
            switch axis {
            case .horizontal:
                point = .init(
                    x: bounds.minX + resolved.mainAxis.origins[index],
                    y: bounds.minY + resolved.crossOrigins[index]
                )
            case .vertical:
                point = .init(
                    x: bounds.minX + resolved.crossOrigins[index],
                    y: bounds.minY + resolved.mainAxis.origins[index]
                )
            }
            subviews[index].place(
                at: point,
                anchor: .topLeading,
                proposal: .init(width: size.width, height: size.height)
            )
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private extension SUIStackLayout {
    struct Resolution {
        let mainAxis: StackMainAxisResolution
        let childSizes: [CGSize]
        let crossOrigins: [CGFloat]
        let size: CGSize
    }

    func resolvedLayout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> Resolution {
        let idealSizes = subviews.map { idealSize(of: $0, proposal: proposal) }
        let minimumSizes = subviews.map { minimumSize(of: $0, proposal: proposal) }
        let mainAxis = StackMainAxisResolver.resolve(
            idealLengths: idealSizes.map(mainLength),
            minimumLengths: minimumSizes.map(mainLength),
            priorities: subviews.map(\.priority),
            proposedLength: mainProposal(proposal),
            distribution: distribution,
            spacing: spacing
        )

        var childSizes = subviews.indices.map { index in
            measuredSize(
                of: subviews[index],
                mainLength: mainAxis.lengths[index],
                crossProposal: crossProposal(proposal)
            )
        }
        let usesBaselineAlignment = axis == .horizontal
            && (alignment == .firstBaseline || alignment == .lastBaseline)
        let baselineOffsets = usesBaselineAlignment
            ? self.baselineOffsets(subviews: subviews, childSizes: childSizes)
            : []
        let crossAxis = StackCrossAxisResolver.resolve(
            idealLengths: childSizes.map(crossLength),
            proposedLength: crossProposal(proposal),
            alignment: usesBaselineAlignment ? alignment : effectiveCrossAlignment,
            baselineOffsets: baselineOffsets
        )
        childSizes = childSizes.indices.map { index in
            size(main: mainLength(childSizes[index]), cross: crossAxis.lengths[index])
        }
        return .init(
            mainAxis: mainAxis,
            childSizes: childSizes,
            crossOrigins: crossAxis.origins,
            size: size(main: mainAxis.containerLength, cross: crossAxis.containerLength)
        )
    }

    func idealSize(of subview: LayoutSubview, proposal: ProposedViewSize) -> CGSize {
        switch axis {
        case .horizontal:
            return subview.sizeThatFits(.unspecified)
        case .vertical:
            return subview.sizeThatFits(.init(width: proposal.width, height: nil))
        }
    }

    func minimumSize(of subview: LayoutSubview, proposal: ProposedViewSize) -> CGSize {
        switch axis {
        case .horizontal:
            return subview.sizeThatFits(.init(width: 0, height: proposal.height))
        case .vertical:
            return subview.sizeThatFits(.init(width: proposal.width, height: 0))
        }
    }

    func measuredSize(
        of subview: LayoutSubview,
        mainLength: CGFloat,
        crossProposal: CGFloat?
    ) -> CGSize {
        let proposal: ProposedViewSize
        switch axis {
        case .horizontal:
            proposal = .init(width: mainLength, height: crossProposal)
        case .vertical:
            proposal = .init(width: crossProposal, height: mainLength)
        }
        let measured = subview.sizeThatFits(proposal)
        return size(
            main: mainLength,
            cross: alignment == .fill && crossProposal != nil
                ? crossProposal ?? crossLength(measured)
                : crossLength(measured)
        )
    }

    func baselineOffsets(
        subviews: Subviews,
        childSizes: [CGSize]
    ) -> [CGFloat] {
        subviews.indices.map { index in
            let dimensions = subviews[index].dimensions(
                in: .init(width: childSizes[index].width, height: childSizes[index].height)
            )
            switch alignment {
            case .lastBaseline:
                return dimensions[.lastTextBaseline]
            default:
                return dimensions[.firstTextBaseline]
            }
        }
    }

    var effectiveCrossAlignment: StackViewAlignment {
        guard axis == .vertical,
              alignment == .firstBaseline || alignment == .lastBaseline else { return alignment }
        return .center
    }

    func mainProposal(_ proposal: ProposedViewSize) -> CGFloat? {
        switch axis {
        case .horizontal: return proposal.width
        case .vertical: return proposal.height
        }
    }

    func crossProposal(_ proposal: ProposedViewSize) -> CGFloat? {
        switch axis {
        case .horizontal: return proposal.height
        case .vertical: return proposal.width
        }
    }

    func mainLength(_ size: CGSize) -> CGFloat {
        switch axis {
        case .horizontal: return size.width
        case .vertical: return size.height
        }
    }

    func crossLength(_ size: CGSize) -> CGFloat {
        switch axis {
        case .horizontal: return size.height
        case .vertical: return size.width
        }
    }

    func size(main: CGFloat, cross: CGFloat) -> CGSize {
        switch axis {
        case .horizontal: return .init(width: main, height: cross)
        case .vertical: return .init(width: cross, height: main)
        }
    }
}

#endif
