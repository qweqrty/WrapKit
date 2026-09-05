//
//  CoreTextAttributedLabelSizingLayout.swift
//  WrapKit
//

import Foundation
#if canImport(SwiftUI)
import CoreText
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct CoreTextAttributedLabelSizingLayout: Layout, @unchecked Sendable {
    let attributedText: NSAttributedString
    let usesFoundationLayoutMetrics: Bool
    let displayScale: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let proposedWidth = finite(proposal.width)
        let measured = measuredSize(constrainedTo: proposedWidth)
        return CGSize(
            width: proposedWidth ?? measured.width,
            height: finite(proposal.height) ?? measured.height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews.first?.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
        )
    }

    private func measuredSize(constrainedTo proposedWidth: CGFloat?) -> CGSize {
        let constraint = CGSize(
            width: proposedWidth ?? .greatestFiniteMagnitude,
            height: .greatestFiniteMagnitude
        )
        let measured: CGSize
        if usesFoundationLayoutMetrics {
            measured = attributedText.boundingRect(
                with: constraint,
                options: [.usesLineFragmentOrigin],
                context: nil
            ).size
        } else {
            let framesetter = CTFramesetterCreateWithAttributedString(
                attributedText as CFAttributedString
            )
            measured = CTFramesetterSuggestFrameSizeWithConstraints(
                framesetter,
                CFRange(location: 0, length: attributedText.length),
                nil,
                constraint,
                nil
            )
        }

        let scale = max(displayScale, 1)
        return CGSize(
            width: max(ceil(measured.width * scale) / scale, 0),
            height: max(ceil(measured.height * scale) / scale, 0)
        )
    }

    private func finite(_ value: CGFloat?) -> CGFloat? {
        guard let value, value.isFinite else { return nil }
        return max(value, 0)
    }
}
#endif
