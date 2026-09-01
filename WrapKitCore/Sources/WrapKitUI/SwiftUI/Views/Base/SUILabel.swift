//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
import CoreText
#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

private final class CoreTextAttachmentMetrics {
    let bounds: CGRect

    init(bounds: CGRect) {
        self.bounds = bounds
    }
}

private func releaseCoreTextAttachmentMetrics(_ pointer: UnsafeMutableRawPointer) {
    Unmanaged<CoreTextAttachmentMetrics>.fromOpaque(pointer).release()
}

private func coreTextAttachmentAscent(_ pointer: UnsafeMutableRawPointer) -> CGFloat {
    let bounds = Unmanaged<CoreTextAttachmentMetrics>.fromOpaque(pointer).takeUnretainedValue().bounds
    return max(bounds.maxY, 0)
}

private func coreTextAttachmentDescent(_ pointer: UnsafeMutableRawPointer) -> CGFloat {
    let bounds = Unmanaged<CoreTextAttachmentMetrics>.fromOpaque(pointer).takeUnretainedValue().bounds
    return max(-bounds.minY, 0)
}

private func coreTextAttachmentWidth(_ pointer: UnsafeMutableRawPointer) -> CGFloat {
    let bounds = Unmanaged<CoreTextAttachmentMetrics>.fromOpaque(pointer).takeUnretainedValue().bounds
    return max(bounds.width, 0)
}

private let coreTextManualUnderlineStyleKey = NSAttributedString.Key(
    "WrapKit.SUILabel.ManualUnderlineStyle"
)

public struct SUILabel: View {
    @StateObject var stateModel: SUILabelStateModel

    private let defaultFont: Font
    private let defaultTextColor: Color
    private let defaultTextAlignment: TextAlignment

    public init(
        adapter: TextOutputSwiftUIAdapter,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .label,
        textAlignment: TextAlignment = .natural
    ) {
        _stateModel = StateObject(wrappedValue: SUILabelStateModel(adapter: adapter))
        self.defaultFont = font
        self.defaultTextColor = textColor
        self.defaultTextAlignment = textAlignment
    }

    init(
        stateModel: SUILabelStateModel,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .label,
        textAlignment: TextAlignment = .natural
    ) {
        _stateModel = StateObject(wrappedValue: stateModel)
        self.defaultFont = font
        self.defaultTextColor = textColor
        self.defaultTextAlignment = textAlignment
    }

    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUILabelView(
                model: stateModel.presentable,
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
        }
    }
}

public struct SUILabelView: View, Animatable {
    @Environment(\.colorScheme) private var colorScheme

    private struct HTMLParagraph {
        let attributedText: NSAttributedString
        let alignment: TextAlignment
        let paragraphSpacing: CGFloat
    }

    let model: TextOutputPresentableModel

    private let defaultFont: Font
    private let defaultTextColor: Color
    private let defaultTextAlignment: TextAlignment

    public init(
        model: TextOutputPresentableModel,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .label,
        textAlignment: TextAlignment = .natural
    ) {
        self.model = model
        self.defaultFont = font
        self.defaultTextColor = textColor
        self.defaultTextAlignment = textAlignment
    }

    public var body: some View {
        Group {
            switch model.model {
            case .textStyled(let text, let cornerStyle, let insets, _, let backgroundColor):
                SUILabelView(
                    model: .init(
                        accessibilityIdentifier: model.accessibilityIdentifier,
                        accessibility: model.accessibility,
                        model: text
                    ),
                    font: defaultFont,
                    textColor: defaultTextColor,
                    textAlignment: defaultTextAlignment
                )
                .if(!insets.isZero) { $0.padding(insets.asSUIEdgeInsets) }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .ifLet(backgroundColor) { $0.background(SwiftUIColor($1)) }
                .ifLet(cornerStyle) { $0.cornerStyle($1) }

            case .animatedDecimal(_, let from, let to, let mapToString, let animationStyle, let duration, let completion):
                animatedContainer(
                    from: from,
                    to: to,
                    mapToString: mapToString,
                    animationStyle: animationStyle,
                    duration: duration,
                    completion: completion
                )

            case .animated(_, let from, let to, let mapToString, let animationStyle, let duration, let completion):
                let mapper: ((Decimal) -> TextOutputPresentableModel.TextModel)? = if let mapToString {
                    { mapToString($0.doubleValue) }
                } else {
                    nil
                }
                animatedContainer(
                    from: from.asDecimal(),
                    to: to.asDecimal(),
                    mapToString: mapper,
                    animationStyle: animationStyle,
                    duration: duration,
                    completion: completion
                )

            default:
                if let plainText {
                    verticallyCenteredContent {
                        Text(plainText)
                            .font(SwiftUIFont(defaultFont))
                            .textColor(SwiftUIColor(defaultTextColor))
                            .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                            .frame(
                                maxWidth: .infinity,
                                alignment: frameAlignment(from: defaultTextAlignment)
                            )
                    }
                } else if let attributedContent {
                    if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
#if canImport(UIKit) && !os(watchOS)
                        if isHTMLAttributedModel {
                            SUIHTMLAttributedLabel(
                                attributedText: attributedContent.attributedText,
                                font: defaultFont,
                                textColor: defaultTextColor,
                                textAlignment: defaultTextAlignment
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                        } else {
                            coreTextLabel(for: attributedContent)
                        }
#else
                        coreTextLabel(for: attributedContent)
#endif
                    } else {
                        verticallyCenteredContent {
                            Text(attributedContent.attributedText.string)
                                .font(SwiftUIFont(defaultFont))
                                .textColor(SwiftUIColor(defaultTextColor))
                                .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: frameAlignment(from: defaultTextAlignment)
                                )
                        }
                    }
                } else if let fallbackPlainText {
                    verticallyCenteredContent {
                        Text(fallbackPlainText)
                            .font(SwiftUIFont(defaultFont))
                            .textColor(SwiftUIColor(defaultTextColor))
                            .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                            .frame(
                                maxWidth: .infinity,
                                alignment: frameAlignment(from: defaultTextAlignment)
                            )
                    }
                }
            }
        }
        .modifier(LabelAccessibilityModifier(
            identifier: model.accessibilityIdentifier,
            label: model.accessibility?.label,
            hint: model.accessibility?.hint,
            isTappable: hasTappableAttributes
        ))
    }

    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    private func coreTextLabel(for attributedContent: SUILabelAttributedContent) -> some View {
        CoreTextAttributedLabel(
            attributedText: coreTextAttributedString(
                from: attributedContent.attributedText
            ),
            alignment: effectiveTextAlignment(
                in: attributedContent.attributedText,
                fallback: defaultTextAlignment
            ),
            usesFoundationLayoutMetrics: isHTMLAttributedModel,
            tapActions: attributedContent.tapActions
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var hasTappableAttributes: Bool {
        func containsTap(_ textModel: TextOutputPresentableModel.TextModel?) -> Bool {
            switch textModel {
            case .attributes(let attributes):
                return attributes.contains { $0.onTap != nil }
            case .textStyled(let nested, _, _, _, _):
                return containsTap(nested)
            default:
                return false
            }
        }
        return containsTap(model.model)
    }

    private var plainText: String? {
        guard case .text(let string) = model.model else { return nil }
        let text = string?.removingPercentEncoding ?? string ?? ""
        return text.isEmpty ? nil : text
    }

    @ViewBuilder
    private func animatedContainer(
        from: Decimal,
        to: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    ) -> some View {
        SUICountingLabelAnimation(
            accessibilityIdentifier: model.accessibilityIdentifier,
            from: from,
            to: to,
            mapToString: mapToString,
            animationStyle: animationStyle,
            duration: duration,
            font: defaultFont,
            textColor: defaultTextColor,
            textAlignment: defaultTextAlignment,
            completion: completion
        )
    }

    private var attributedContent: SUILabelAttributedContent? {
        switch model.model {
        case .text(let string):
            let text = string?.removingPercentEncoding ?? string ?? ""
            guard !text.isEmpty else { return nil }
            let attributed = NSAttributedString(
                text,
                font: defaultFont,
                color: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            return .init(
                attributedText: attributed,
                tapActions: []
            )

        case .attributes(let attributes):
            guard !attributes.isEmpty else { return nil }
            var normalized = attributes
            for index in normalized.indices {
                normalized[index].text = normalized[index].text.removingPercentEncoding ?? normalized[index].text
            }
            let attributed = normalized.makeNSAttributedString(
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            let tapActions = normalized.compactMap { attribute -> SUILabelTapAction? in
                guard let range = attribute.range, let onTap = attribute.onTap else { return nil }
                return .init(id: attribute.id, range: range, perform: onTap)
            }
            return .init(
                attributedText: attributed,
                tapActions: tapActions
            )

        case .attributedString(let htmlString, let config):
            guard
                let htmlString,
                let attributed = htmlString.asHtmlAttributedString(config: config)
            else {
                return nil
            }
            return .init(
                attributedText: attributed,
                tapActions: []
            )

        default:
            return nil
        }
    }

    private var nsAttributedTextForHTML: NSAttributedString? {
        guard case .attributedString(let htmlString, let config) = model.model,
              let htmlString,
              let attributed = htmlString.asHtmlAttributedString(config: config)
        else {
            return nil
        }

        let mutable = NSMutableAttributedString(attributedString: attributed)
        let wholeRange = NSRange(location: 0, length: mutable.length)
        mutable.enumerateAttribute(.link, in: wholeRange) { value, range, _ in
            guard value != nil else { return }
            mutable.addAttribute(.foregroundColor, value: Color.systemBlue, range: range)
        }
        return mutable
    }

    private var isHTMLAttributedModel: Bool {
        if case .attributedString = model.model {
            return true
        }
        return false
    }

    private var fallbackPlainText: String? {
        switch model.model {
        case .text(let string):
            let text = string?.removingPercentEncoding ?? string ?? ""
            return text.isEmpty ? nil : text
        case .attributes(let attributes):
            let text = attributes.map(\.text).joined()
            return text.isEmpty ? nil : text
        case .attributedString(let htmlString, _):
            guard let htmlString, !htmlString.isEmpty else { return nil }
            return htmlString
        default:
            return nil
        }
    }

    private func multilineAlignment(from textAlignment: TextAlignment) -> SwiftUI.TextAlignment {
        switch textAlignment {
        case .center:
            return .center
        case .right:
            return .trailing
        default:
            return .leading
        }
    }

    private func frameAlignment(from textAlignment: TextAlignment) -> Alignment {
        switch textAlignment {
        case .center:
            return .center
        case .right:
            return .trailing
        default:
            return .leading
        }
    }

    private func effectiveTextAlignment(
        in attributedText: NSAttributedString,
        fallback: TextAlignment
    ) -> TextAlignment {
        guard attributedText.length > 0 else { return fallback }
        let paragraphStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? ParagraphStyle
        return paragraphStyle?.alignment ?? fallback
    }

    @ViewBuilder
    private func verticallyCenteredContent<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            content()
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    private func swiftUIAttributedString(from attributedText: NSAttributedString) -> AttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let wholeRange = NSRange(location: 0, length: mutable.length)

        mutable.enumerateAttributes(in: wholeRange) { attributes, range, _ in
            if attributes[.foregroundColor] == nil {
                mutable.addAttribute(.foregroundColor, value: defaultTextColor, range: range)
            }
        }

        return AttributedString(mutable)
    }

    private func coreTextAttributedString(from attributedText: NSAttributedString) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let source = NSAttributedString(attributedString: attributedText)
        let wholeRange = NSRange(location: 0, length: mutable.length)

        mutable.enumerateAttributes(in: wholeRange) { attributes, range, _ in
            if attributes[.foregroundColor] == nil
                || attributes[.foregroundColor] as? Color == .label {
                mutable.addAttribute(.foregroundColor, value: resolvedDefaultPlatformTextColor, range: range)
            }
            if attributes[.font] == nil {
                mutable.addAttribute(.font, value: defaultFont, range: range)
            }
            if attributes[.paragraphStyle] == nil {
                mutable.addAttribute(
                    .paragraphStyle,
                    value: nearestParagraphStyle(in: source, around: range) ?? defaultParagraphStyle,
                    range: range
                )
            }
        }

        return mutable
    }

    private func nearestParagraphStyle(
        in attributedText: NSAttributedString,
        around range: NSRange
    ) -> ParagraphStyle? {
        if range.upperBound < attributedText.length,
           let style = attributedText.attribute(
               .paragraphStyle,
               at: range.upperBound,
               effectiveRange: nil
           ) as? ParagraphStyle {
            return style
        }
        if range.location > 0,
           let style = attributedText.attribute(
               .paragraphStyle,
               at: range.location - 1,
               effectiveRange: nil
           ) as? ParagraphStyle {
            return style
        }
        return nil
    }

    private var defaultParagraphStyle: ParagraphStyle {
        let style = MutableParagraphStyle()
        style.alignment = defaultTextAlignment
        return style
    }

    private var resolvedDefaultPlatformTextColor: Color {
        guard defaultTextColor == .label else { return defaultTextColor }
        return colorScheme == .dark ? .white : .black
    }

}

#if canImport(UIKit) && !os(watchOS)
private struct SUIHTMLAttributedLabel: UIViewRepresentable {
    let attributedText: NSAttributedString
    let font: Font
    let textColor: Color
    let textAlignment: TextAlignment

    func makeUIView(context: Context) -> Label {
        let label = Label(
            font: font,
            textColor: textColor,
            textAlignment: textAlignment,
            numberOfLines: 0
        )
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }

    func updateUIView(_ label: Label, context: Context) {
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.numberOfLines = 0
        label.attributedText = attributedText
    }

    @available(iOS 16.0, tvOS 16.0, *)
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: Label,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height else { return nil }
        return CGSize(width: width, height: height)
    }
}
#endif

private struct SUILabelAttributedContent {
    let attributedText: NSAttributedString
    let tapActions: [SUILabelTapAction]
}

struct SUILabelTapAction {
    let id: String
    let range: NSRange
    let perform: () -> Void
}

private struct LabelAccessibilityModifier: ViewModifier {
    let identifier: String?
    let label: String?
    let hint: String?
    let isTappable: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .ifLet(identifier) { view, identifier in
                view.accessibilityIdentifier(identifier)
            }
            .ifLet(label) { view, label in
                view.accessibilityLabel(SwiftUI.Text(label))
            }
            .ifLet(hint) { view, hint in
                view.accessibilityHint(SwiftUI.Text(hint))
            }
            .if(isTappable) { view in
                view.accessibilityAddTraits(.isButton)
            }
    }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
private struct CoreTextAttributedLabel: View {
    @Environment(\.displayScale) private var displayScale
    @Environment(\.colorScheme) private var colorScheme

    private struct AttachmentPlacement {
        let image: Image
        let rect: CGRect
    }

    private struct LayoutResult {
        let attributedText: NSAttributedString
        let frame: CTFrame
        let verticalInset: CGFloat
    }

    private struct TapRegion: Identifiable {
        struct ID: Hashable {
            let actionID: String
            let lineIndex: Int
        }

        let id: ID
        let rect: CGRect
        let perform: () -> Void
    }

    let attributedText: NSAttributedString
    let alignment: TextAlignment
    let usesFoundationLayoutMetrics: Bool
    let tapActions: [SUILabelTapAction]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { context, size in
                    guard let layout = makeLayout(in: size) else { return }

                    let scale = max(displayScale, 1)
                    let pixelWidth = max(Int(ceil(size.width * scale)), 1)
                    let pixelHeight = max(Int(ceil(size.height * scale)), 1)
                    guard let bitmapContext = CGContext(
                        data: nil,
                        width: pixelWidth,
                        height: pixelHeight,
                        bitsPerComponent: 8,
                        bytesPerRow: 0,
                        space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                    ) else { return }

                    bitmapContext.scaleBy(x: scale, y: scale)
                    bitmapContext.textMatrix = .identity
                    bitmapContext.translateBy(x: 0, y: size.height)
                    bitmapContext.scaleBy(x: 1, y: -1)
                    bitmapContext.saveGState()
                    bitmapContext.translateBy(x: 0, y: layout.verticalInset)
                    bitmapContext.setAllowsAntialiasing(true)
                    bitmapContext.setShouldAntialias(true)
                    bitmapContext.setShouldSmoothFonts(true)
                    draw(frame: layout.frame, in: bitmapContext, scale: scale)
                    bitmapContext.restoreGState()

                    guard let image = bitmapContext.makeImage() else { return }
                    context.withCGContext { cgContext in
                        cgContext.saveGState()
                        cgContext.interpolationQuality = .high
                        cgContext.draw(image, in: CGRect(origin: .zero, size: size))
                        cgContext.restoreGState()
                    }

                    for placement in attachmentPlacements(
                        in: layout.frame,
                        canvasHeight: size.height,
                        verticalInset: layout.verticalInset
                    ) {
#if canImport(UIKit) && !os(watchOS)
                        let image = rasterizedUIKitAttachment(
                            placement.image,
                            size: placement.rect.size,
                            scale: scale
                        )
                        context.draw(SwiftUIImage(image: image), in: placement.rect)
#else
                        context.draw(SwiftUIImage(image: placement.image), in: placement.rect)
#endif
                    }

#if canImport(UIKit) && !os(watchOS)
                    if let underlineImage = rasterizedUIKitUnderlineDecoration(
                        canvasSize: size,
                        scale: scale
                    ) {
                        context.draw(
                            SwiftUIImage(image: underlineImage),
                            in: CGRect(origin: .zero, size: size)
                        )
                    }
#endif
                }

                ForEach(tapRegions(in: geometry.size)) { region in
                    SwiftUIColor.clear
                        .frame(width: region.rect.width, height: region.rect.height)
                        .contentShape(Rectangle())
                        .position(x: region.rect.midX, y: region.rect.midY)
                        .accessibilityHidden(true)
                        .onTapGesture(perform: region.perform)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: frameAlignment(for: alignment))
    }

    private func makeLayout(in size: CGSize) -> LayoutResult? {
        guard size.width > 0, size.height > 0 else { return nil }

        let text = textAttributedStringWithoutUnderline(from: attributedText)
        let framesetter = CTFramesetterCreateWithAttributedString(text as CFAttributedString)
        let textHeight: CGFloat
        let verticalInset: CGFloat
        if usesFoundationLayoutMetrics {
            let measuredHeight = text.boundingRect(
                with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                context: nil
            ).height
            let scale = max(displayScale, 1)
            textHeight = max(ceil(measuredHeight * scale) / scale, 1)
            verticalInset = textHeight > size.height
                ? size.height - textHeight
                : (size.height - textHeight) / 2
        } else {
            let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                framesetter,
                CFRange(location: 0, length: text.length),
                nil,
                CGSize(width: size.width, height: .greatestFiniteMagnitude),
                nil
            )
            textHeight = min(ceil(suggestedSize.height), size.height)
            verticalInset = max((size.height - textHeight) / 2, 0)
        }
        let path = CGPath(
            rect: CGRect(x: 0, y: 0, width: size.width, height: textHeight),
            transform: nil
        )
        let frame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: text.length),
            path,
            nil
        )
        return .init(attributedText: text, frame: frame, verticalInset: verticalInset)
    }

    private func frameAlignment(for alignment: TextAlignment) -> Alignment {
        switch alignment {
        case .center:
            return .center
        case .right:
            return .trailing
        default:
            return .leading
        }
    }

    private func tapRegions(in size: CGSize) -> [TapRegion] {
        guard !tapActions.isEmpty, let layout = makeLayout(in: size) else { return [] }

        let lines = CTFrameGetLines(layout.frame) as? [CTLine] ?? []
        guard !lines.isEmpty else { return [] }

        var lineOrigins = Array(repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(layout.frame, CFRange(location: 0, length: 0), &lineOrigins)
        let contentBounds = CGRect(origin: .zero, size: size)
        let completeRange = NSRange(location: 0, length: layout.attributedText.length)
        var regions: [TapRegion] = []

        for action in tapActions {
            let actionRange = NSIntersectionRange(action.range, completeRange)
            guard actionRange.length > 0 else { continue }

            for (lineIndex, line) in lines.enumerated() {
                let lineRange = CTLineGetStringRange(line)
                guard lineRange.location != kCFNotFound else { continue }
                let intersection = NSIntersectionRange(
                    actionRange,
                    NSRange(location: lineRange.location, length: lineRange.length)
                )
                guard intersection.length > 0 else { continue }

                let start = CTLineGetOffsetForStringIndex(line, intersection.location, nil)
                let end = CTLineGetOffsetForStringIndex(line, intersection.upperBound, nil)
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                CTLineGetTypographicBounds(line, &ascent, &descent, nil)

                let origin = lineOrigins[lineIndex]
                let coreTextRect = CGRect(
                    x: origin.x + min(start, end),
                    y: origin.y - descent,
                    width: abs(end - start),
                    height: ascent + descent
                )
                let viewRect = CGRect(
                    x: coreTextRect.minX,
                    y: size.height - coreTextRect.maxY - layout.verticalInset,
                    width: coreTextRect.width,
                    height: coreTextRect.height
                ).intersection(contentBounds)
                guard !viewRect.isNull, viewRect.width > 0, viewRect.height > 0 else { continue }

                regions.append(.init(
                    id: .init(actionID: action.id, lineIndex: lineIndex),
                    rect: viewRect,
                    perform: action.perform
                ))
            }
        }
        return regions
    }

    private func textAttributedStringWithoutUnderline(from attributedText: NSAttributedString) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let wholeRange = NSRange(location: 0, length: mutable.length)

        mutable.enumerateAttribute(.attachment, in: wholeRange) { value, range, _ in
            guard let attachment = value as? NSTextAttachment else { return }

            let pointer = Unmanaged.passRetained(
                CoreTextAttachmentMetrics(bounds: attachment.bounds)
            ).toOpaque()
            var callbacks = CTRunDelegateCallbacks(
                version: kCTRunDelegateVersion1,
                dealloc: releaseCoreTextAttachmentMetrics,
                getAscent: coreTextAttachmentAscent,
                getDescent: coreTextAttachmentDescent,
                getWidth: coreTextAttachmentWidth
            )
            guard let delegate = CTRunDelegateCreate(&callbacks, pointer) else {
                releaseCoreTextAttachmentMetrics(pointer)
                return
            }
            mutable.addAttribute(
                NSAttributedString.Key(kCTRunDelegateAttributeName as String),
                value: delegate,
                range: range
            )
        }

        mutable.enumerateAttribute(.underlineStyle, in: wholeRange) { value, range, _ in
            let rawValue: Int?
            if let number = value as? NSNumber {
                rawValue = number.intValue
            } else if let intValue = value as? Int {
                rawValue = intValue
            } else {
                rawValue = nil
            }

            guard let rawValue else { return }
            let style = UnderlineStyle(rawValue: rawValue)

#if canImport(UIKit) && !os(watchOS)
            mutable.removeAttribute(.underlineStyle, range: range)
#else
            if style.contains(.byWord) || style.contains(.double) || style.contains(.thick) {
                mutable.addAttribute(
                    coreTextManualUnderlineStyleKey,
                    value: NSNumber(value: rawValue),
                    range: range
                )
                mutable.removeAttribute(.underlineStyle, range: range)
            }
#endif
        }

        return mutable
    }

    private func attachmentPlacements(
        in frame: CTFrame,
        canvasHeight: CGFloat,
        verticalInset: CGFloat
    ) -> [AttachmentPlacement] {
        let lines = CTFrameGetLines(frame) as? [CTLine] ?? []
        guard !lines.isEmpty else { return [] }

        var lineOrigins = Array(repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &lineOrigins)

        return lines.enumerated().flatMap { lineIndex, line in
            let lineOrigin = lineOrigins[lineIndex]
            let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []

            return runs.compactMap { run -> AttachmentPlacement? in
                let attributes = CTRunGetAttributes(run) as NSDictionary
                guard let attachment = attributes[NSAttributedString.Key.attachment] as? NSTextAttachment,
                      let image = attachment.image,
                      attachment.bounds.width > 0,
                      attachment.bounds.height > 0
                else {
                    return nil
                }

                var runPosition = CGPoint.zero
                CTRunGetPositions(run, CFRange(location: 0, length: 1), &runPosition)
                let coreTextRect = CGRect(
                    x: lineOrigin.x + runPosition.x + attachment.bounds.origin.x,
                    y: lineOrigin.y + runPosition.y + attachment.bounds.origin.y,
                    width: attachment.bounds.width,
                    height: attachment.bounds.height
                )
                return AttachmentPlacement(
                    image: image,
                    rect: CGRect(
                        x: coreTextRect.minX,
                        y: canvasHeight - coreTextRect.maxY - verticalInset,
                        width: coreTextRect.width,
                        height: coreTextRect.height
                    )
                )
            }
        }
    }

    private func draw(frame: CTFrame, in context: CGContext, scale: CGFloat) {
        let lines = CTFrameGetLines(frame) as? [CTLine] ?? []
        guard !lines.isEmpty else { return }

        var lineOrigins = Array(repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &lineOrigins)

        for (lineIndex, line) in lines.enumerated() {
            let origin = lineOrigins[lineIndex]
            context.textPosition = origin
            CTLineDraw(line, context)
#if !(canImport(UIKit) && !os(watchOS))
            drawUnderlineSegments(for: line, at: origin, in: context, scale: scale)
#endif
        }
    }

#if canImport(UIKit) && !os(watchOS)
    private func rasterizedUIKitAttachment(
        _ image: UIImage,
        size: CGSize,
        scale: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func rasterizedUIKitUnderlineDecoration(
        canvasSize: CGSize,
        scale: CGFloat
    ) -> UIImage? {
        guard let decoration = underlineDecorationAttributedString() else { return nil }

        let textStorage = NSTextStorage(attributedString: decoration)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: canvasSize)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = 0
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let glyphRange = layoutManager.glyphRange(for: textContainer)
        guard glyphRange.length > 0 else { return nil }
        let usedRect = layoutManager.usedRect(for: textContainer)
        let drawingOrigin = CGPoint(
            x: 0,
            y: (canvasSize.height - usedRect.height) / 2 - usedRect.minY
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: canvasSize, format: format).image { _ in
            layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: drawingOrigin)
        }
    }

    private func underlineDecorationAttributedString() -> NSAttributedString? {
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let wholeRange = NSRange(location: 0, length: mutable.length)
        var containsUnderline = false

        mutable.enumerateAttributes(in: wholeRange) { attributes, range, _ in
            mutable.addAttribute(.foregroundColor, value: UIColor.clear, range: range)

            guard let rawValue = underlineRawValue(from: attributes[.underlineStyle]), rawValue != 0 else {
                return
            }
            containsUnderline = true
            let sourceColor = attributes[.underlineColor]
                ?? attributes[.foregroundColor]
                ?? UIColor.label
            mutable.addAttribute(
                .underlineColor,
                value: resolvedUIKitColor(from: sourceColor),
                range: range
            )
        }

        mutable.enumerateAttribute(.attachment, in: wholeRange) { value, range, _ in
            guard let attachment = value as? NSTextAttachment else { return }
            let transparentAttachment = NSTextAttachment()
            transparentAttachment.bounds = attachment.bounds
            transparentAttachment.image = UIImage()
            mutable.addAttribute(.attachment, value: transparentAttachment, range: range)
        }

        return containsUnderline ? mutable : nil
    }

    private func underlineRawValue(from value: Any?) -> Int? {
        if let number = value as? NSNumber {
            return number.intValue
        }
        return value as? Int
    }

    private func resolvedUIKitColor(from value: Any) -> UIColor {
        guard let color = value as? UIColor else { return .label }
        let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        return color.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }
#endif

    private func drawUnderlineSegments(for line: CTLine, at origin: CGPoint, in context: CGContext, scale: CGFloat) {
        let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []

        for run in runs {
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let rawValue: Int?
            if let number = attributes[coreTextManualUnderlineStyleKey] as? NSNumber {
                rawValue = number.intValue
            } else if let intValue = attributes[coreTextManualUnderlineStyleKey] as? Int {
                rawValue = intValue
            } else if let number = attributes[kCTUnderlineStyleAttributeName] as? NSNumber {
                rawValue = number.intValue
            } else if let intValue = attributes[kCTUnderlineStyleAttributeName] as? Int {
                rawValue = intValue
            } else if let number = attributes[NSAttributedString.Key.underlineStyle] as? NSNumber {
                rawValue = number.intValue
            } else if let intValue = attributes[NSAttributedString.Key.underlineStyle] as? Int {
                rawValue = intValue
            } else {
                rawValue = nil
            }

            guard let rawValue else { continue }

            let style = UnderlineStyle(rawValue: rawValue)
            guard style.contains(.byWord) || style.contains(.double) || style.contains(.thick) else { continue }

            let foregroundColor = coreGraphicsColor(
                from: attributes[NSAttributedString.Key.foregroundColor]
                    ?? attributes[kCTForegroundColorAttributeName]
            )
            context.setStrokeColor(
                foregroundColor
                    ?? CGColor(gray: colorScheme == .dark ? 1 : 0, alpha: 1)
            )

            let baselineOffset = (attributes[NSAttributedString.Key.baselineOffset] as? NSNumber)?.doubleValue ?? 0
            let textRange = CTRunGetStringRange(run)
            let segments = underlineSegments(for: style, line: line, stringRange: textRange)

            let font = coreTextFont(
                from: attributes[NSAttributedString.Key.font]
                    ?? attributes[kCTFontAttributeName]
            )
            let pixel = 1 / max(abs(scale), 1)
            let nativeLineWidth = font.map(CTFontGetUnderlineThickness) ?? pixel
            let nativePosition = font.map(CTFontGetUnderlinePosition) ?? -pixel
            let lineWidth = style.contains(.thick)
                ? max(nativeLineWidth * 2, pixel * 2)
                : max(nativeLineWidth, pixel)
            let underlineY = origin.y + nativePosition + CGFloat(baselineOffset)
            let spacing = max(nativeLineWidth, pixel)

            context.saveGState()
            context.setLineWidth(lineWidth)
            context.setLineCap(.butt)

            for segment in segments {
                let lowerBound = origin.x + segment.lowerBound
                let upperBound = origin.x + segment.upperBound
                if style.contains(.double) {
                    context.move(to: CGPoint(x: lowerBound, y: underlineY))
                    context.addLine(to: CGPoint(x: upperBound, y: underlineY))
                    context.move(to: CGPoint(x: lowerBound, y: underlineY - spacing - lineWidth))
                    context.addLine(to: CGPoint(x: upperBound, y: underlineY - spacing - lineWidth))
                } else {
                    context.move(to: CGPoint(x: lowerBound, y: underlineY))
                    context.addLine(to: CGPoint(x: upperBound, y: underlineY))
                }
            }

            context.strokePath()
            context.restoreGState()
        }
    }

    private func coreGraphicsColor(from value: Any?) -> CGColor? {
        if let color = value as? Color {
            return color.cgColor
        }
        guard let object = value as AnyObject?,
              CFGetTypeID(object) == CGColor.typeID
        else {
            return nil
        }
        return unsafeDowncast(object, to: CGColor.self)
    }

    private func coreTextFont(from value: Any?) -> CTFont? {
        if let font = value as? Font {
            return font as CTFont
        }
        guard let object = value as AnyObject?,
              CFGetTypeID(object) == CTFontGetTypeID()
        else {
            return nil
        }
        return unsafeDowncast(object, to: CTFont.self)
    }

    private func underlineSegments(for style: UnderlineStyle, line: CTLine, stringRange: CFRange) -> [ClosedRange<CGFloat>] {
        let location = stringRange.location
        let length = stringRange.length
        guard location != kCFNotFound, length > 0 else { return [] }

        if style.contains(.byWord) {
            let nsString = attributedText.string as NSString
            let fullRange = NSRange(location: location, length: length)
            let substring = nsString.substring(with: fullRange) as NSString
            let matches = try? NSRegularExpression(pattern: "\\S+").matches(
                in: substring as String,
                range: NSRange(location: 0, length: substring.length)
            )

            return (matches ?? []).compactMap { match in
                let start = location + match.range.location
                let end = start + match.range.length
                let startOffset = CTLineGetOffsetForStringIndex(line, start, nil)
                let endOffset = CTLineGetOffsetForStringIndex(line, end, nil)
                guard endOffset > startOffset else { return nil }
                return startOffset...endOffset
            }
        }

        let startOffset = CTLineGetOffsetForStringIndex(line, location, nil)
        let endOffset = CTLineGetOffsetForStringIndex(line, location + length, nil)
        guard endOffset > startOffset else { return [] }
        return [startOffset...endOffset]
    }
}
#endif

extension NSTextAlignment {
    var suiTextAlignment: SwiftUI.TextAlignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        case .justified: .leading // not available in SwiftUI
        case .natural: .center // currently do not need to handle RTL
        @unknown default: fatalError()
        }
    }
    var suiAlignment: SwiftUI.Alignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        case .justified: .leading // not available in SwiftUI
        case .natural: .center // currently do not need to handle RTL
        @unknown default: fatalError()
        }
    }
}

extension NSUnderlineStyle {
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    var suiStyle: SwiftUI.Text.LineStyle.Pattern {
        switch self {
        case .patternDash: return .dash
        case .patternDashDot: return .dashDot
        case .patternDashDotDot: return .dashDotDot
        case .patternDot: return .dot
        default: return .solid
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    ScrollView(.vertical) {
        VStack(alignment: .leading) {
            SUILabelView(
                model: .text("Hello, World!")
            )
            
            SUILabelView(
                model: .animated(
                    1.2, 225,
                    mapToString: { .text($0.asString()) },
                    animationStyle: .circle(lineColor: .red),
                    duration: 5,
                    completion: { print("completed") }
                )
            )
            .frame(height: 100)
            
            SUILabelView(
                model: .textStyled(
                    text: .text("some text"), cornerStyle: .automatic,
                    insets: .init(all: 8)
                )
            )
            
            SUILabelView(
                model: .textStyled(
                    text: .attributes([.init(text: "cornerStyle: .automatic", color: .gray)]),
                    cornerStyle: .automatic,
                    insets: .init(all: 8),
                    backgroundColor: .blue
                )
            )
            
            SUILabelView(model: .attributes(
                [
                    .init(text: "first line"),
                    .init(
                        text: "green bold 20 (.byWord) \n\n",
                        color: .green,
                        font: .boldSystemFont(ofSize: 20),
                        underlineStyle: .byWord
                    ),
                    .init(
                        text: "yellow bold 25 (.double) \n\n",
                        color: .yellow,
                        font: .boldSystemFont(ofSize: 25),
                        underlineStyle: .double
                    ),
                    .init(
                        text: "blue italic 15 (.patternDash) \n\n",
                        color: .blue,
                        font: FontFactory.italic(size: 15),
                        underlineStyle: .patternDash
                    ),
                    .init(
                        text: "cyan default 25 (.patternDashDot) asdf xcvxcv asdfsdf \n\n",
                        color: .cyan,
                        font: .systemFont(ofSize: 25),
                        underlineStyle: .patternDashDot
                    ),
                    .init(
                        text: "brown 30-500 (.patternDashDotDot) zxcvz gtfrgh vbnbvgn \n\n",
                        color: .brown,
                        font: .systemFont(ofSize: 30, weight: Font.Weight(rawValue: 500)),
                        underlineStyle: .patternDashDotDot,
                        onTap: { print("didTap: brown patternDashDotDot ") }
                    ),
                    .init(
                        text: "darkGray 16-200 (.patternDot) \n\n",
                        color: .darkGray,
                        font: .systemFont(ofSize: 16, weight: Font.Weight(rawValue: 200)),
                        underlineStyle: .patternDot,
                        onTap: { print("didTap: patternDot ") }
                    ),
                    .init(
                        text: "The quick brown fox ",
                        color: .black,
                        font: .boldSystemFont(ofSize: 25),
                        underlineStyle: .single,
                        textAlignment: .left,
                        leadingImage: ImageFactory.systemImage(named: "mail"),
                        leadingImageBounds: .init(x: 30, y: 40, width: 45, height: 56),
                        trailingImage: ImageFactory.systemImage(named: "arrow.right"),
                        trailingImageBounds: .init(x: -30, y: -40, width: 15, height: 15),
                        onTap: { print("didTap: The quick brown fox ") }
                    )
                ]
            ))
            
            SUILabelView(model: .textStyled(
                text: .attributes([TextAttributes(
                    text: "Text with leading image",
                    leadingImage: ImageFactory.systemImage(named: "star.fill")
                )]),
                cornerStyle: nil, insets: .zero, height: 150, backgroundColor: .systemBlue
            ))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

@available(iOS 16.0, *)
#Preview {
    SUILabelView(
        model: .text("This is really long text that should wrap and check for number of lines")
    )
    .font(.system(size: 20))
    .offset(y: -1.2)
    .modify { if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, *) {
        if #available(macOS 26.0, *) {
            $0.lineHeight(.multiple(factor: 1.17))
        } else {
            // Line-height customization is unavailable on this platform.
        }
    } }
    .frame(height: 150, alignment: .center)
    .frame(maxWidth: .infinity, alignment: .leading)
    
    SUILabelView(
        model: .text("This is really long text that should wrap and check for number of lines")
    )
    .font(.system(size: 30))
    .offset(y: -1.2)
    .modify { if #available(iOS 26, macOS 26, watchOS 26, tvOS 26, *) {
        if #available(macOS 26.0, *) {
            $0.lineHeight(.multiple(factor: 1.17))
        } else {
            // Line-height customization is unavailable on this platform.
        }
    } }
    .frame(height: 150, alignment: .center)
    .frame(maxWidth: .infinity, alignment: .leading)
    
    SUILabelView(
        model: .text("This is really long text that should wrap and check for number of lines This is really long text that should wrap and check for number of lines")
    )
    .font(.system(size: 20))
    .lineSpacing(2)
    .frame(maxWidth: .infinity, alignment: .leading)
}
