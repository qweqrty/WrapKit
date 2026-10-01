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
        var measured: CGSize
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
            measured.height += CoreTextAttributedLabelMetrics.trailingEmptyLineHeight(in: attributedText)
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

enum CoreTextAttributedLabelMetrics {
    static func trailingEmptyLineHeight(in attributedText: NSAttributedString) -> CGFloat {
        guard let lastScalar = attributedText.string.unicodeScalars.last,
              CharacterSet.newlines.contains(lastScalar),
              let font = attributedText.attribute(
                .font, at: attributedText.length - 1, effectiveRange: nil
              ) as? Font
        else { return 0 }

        // A terminal line break creates an empty line with no glyphs. Core Text's
        // framesetter measures only the preceding lines, so reserve its typographic height.
        let coreTextFont = font as CTFont
        let lineHeight = CTFontGetAscent(coreTextFont)
            + CTFontGetDescent(coreTextFont)
            + CTFontGetLeading(coreTextFont)
        let paragraphStyle = attributedText.attribute(
            .paragraphStyle, at: attributedText.length - 1, effectiveRange: nil
        ) as? ParagraphStyle
        return max(lineHeight + (paragraphStyle?.lineSpacing ?? 0), 0)
    }
}
#endif
