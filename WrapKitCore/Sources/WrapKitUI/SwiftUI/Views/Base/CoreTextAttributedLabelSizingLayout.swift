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
    var lineLimit: Int?

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
        let attributedText = CoreTextAttributedLabelMetrics.lineLimitedText(
            self.attributedText,
            lineLimit: lineLimit,
            width: proposedWidth
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
    /// The text `UILabel` shows with `numberOfLines`: the first `lineLimit` lines at `width`.
    /// The attributed strings wrap by word, so the rest is cut without an ellipsis, as in `UILabel`.
    static func lineLimitedText(
        _ attributedText: NSAttributedString,
        lineLimit: Int?,
        width: CGFloat?
    ) -> NSAttributedString {
        let length = visibleLength(of: attributedText, lineLimit: lineLimit, width: width)
        guard length < attributedText.length else { return attributedText }
        return attributedText.attributedSubstring(from: NSRange(location: 0, length: length))
    }

    static func visibleLength(
        of attributedText: NSAttributedString,
        lineLimit: Int?,
        width: CGFloat?
    ) -> Int {
        guard let lineLimit, lineLimit > 0, attributedText.length > 0 else { return attributedText.length }
        let layoutSide: CGFloat = 1_000_000
        let layoutWidth = width.flatMap { $0.isFinite && $0 > 0 ? $0 : nil } ?? layoutSide
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: layoutWidth, height: layoutSide), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        let lines = CTFrameGetLines(frame) as? [CTLine] ?? []
        guard lines.count > lineLimit else { return attributedText.length }

        let lastVisibleLine = CTLineGetStringRange(lines[lineLimit - 1])
        var length = lastVisibleLine.location + lastVisibleLine.length
        // A line break that ends the last visible line would add an empty line.
        let string = attributedText.string as NSString
        while length > 0,
              let scalar = UnicodeScalar(string.character(at: length - 1)),
              CharacterSet.newlines.contains(scalar) {
            length -= 1
        }
        return length
    }

    static func drawingHeight(
        in attributedText: NSAttributedString,
        width: CGFloat,
        minimumHeight: CGFloat,
        displayScale: CGFloat
    ) -> CGFloat {
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let measured = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: attributedText.length),
            nil,
            CGSize(width: width, height: .greatestFiniteMagnitude),
            nil
        )
        let scale = max(displayScale, 1)
        // The frame must fit Core Text's lines even when the view uses UILabel's
        // fractional metrics or is compressed. One pixel also avoids excluding a
        // final line whose descent falls exactly on the frame boundary.
        return max(minimumHeight, ceil(measured.height * scale) / scale) + 1 / scale
    }

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
