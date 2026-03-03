//
//  HTMLAttributedStringConfig.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 19/2/26.
//

import Foundation

public struct HTMLAttributedStringConfig: Hashable {
    public var size: CGFloat?
    public var weight: Weight?
    public var color: Color?

    public var lineSpacing: CGFloat?
    public var paragraphSpacing: CGFloat?
    public var paragraphSpacingBefore: CGFloat?
    public var lineHeightMultiple: CGFloat?

    public var textAlignment: TextAlignment?
    public var lineBreakMode: LineBreakMode?

    public var firstLineHeadIndent: CGFloat?
    public var headIndent: CGFloat?
    public var tailIndent: CGFloat?

    public init(
        size: CGFloat? = nil,
        weight: Weight? = nil,
        color: Color? = nil,
        lineSpacing: CGFloat? = nil,
        paragraphSpacing: CGFloat? = nil,
        paragraphSpacingBefore: CGFloat? = nil,
        lineHeightMultiple: CGFloat? = nil,
        textAlignment: TextAlignment? = nil,
        lineBreakMode: LineBreakMode? = nil,
        firstLineHeadIndent: CGFloat? = nil,
        headIndent: CGFloat? = nil,
        tailIndent: CGFloat? = nil
    ) {
        self.size = size
        self.weight = weight
        self.color = color
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
        self.paragraphSpacingBefore = paragraphSpacingBefore
        self.lineHeightMultiple = lineHeightMultiple
        self.textAlignment = textAlignment
        self.lineBreakMode = lineBreakMode
        self.firstLineHeadIndent = firstLineHeadIndent
        self.headIndent = headIndent
        self.tailIndent = tailIndent
    }

    public static let `default` = HTMLAttributedStringConfig()
}
