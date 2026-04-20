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

public struct SUILabel: View {
    @ObservedObject var stateModel: SUILabelStateModel

    private let defaultFont: Font
    private let defaultTextColor: Color
    private let defaultTextAlignment: TextAlignment

    public init(
        adapter: TextOutputSwiftUIAdapter,
        font: Font = .systemFont(ofSize: 20),
        textColor: Color = .label,
        textAlignment: TextAlignment = .natural
    ) {
        self.stateModel = .init(adapter: adapter)
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

    @StateObject private var displayLinkManager = SUIDisplayLinkManager()

    public var body: some View {
        switch model.model {
        case .textStyled(let text, let cornerStyle, let insets, _, let backgroundColor):
            SUILabelView(
                model: .init(accessibilityIdentifier: model.accessibilityIdentifier, model: text),
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
            if let inlineImageText {
                verticallyCenteredContent {
                    inlineImageText
                        .font(SwiftUIFont(defaultFont))
                        .textColor(SwiftUIColor(defaultTextColor))
                        .multilineTextAlignment(multilineAlignment(from: defaultTextAlignment))
                        .frame(
                            maxWidth: .infinity,
                            alignment: frameAlignment(from: defaultTextAlignment)
                        )
                }
            } else if let nsAttributedText {
                if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
                    CoreTextAttributedLabel(
                        attributedText: coreTextAttributedString(from: nsAttributedText),
                        alignment: effectiveTextAlignment(
                            in: nsAttributedText,
                            fallback: defaultTextAlignment
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    verticallyCenteredContent {
                        Text(nsAttributedText.string)
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

    @ViewBuilder
    private func animatedContainer(
        from: Decimal,
        to: Decimal,
        mapToString: ((Decimal) -> TextOutputPresentableModel.TextModel)?,
        animationStyle: LabelAnimationStyle,
        duration: TimeInterval,
        completion: (() -> Void)?
    ) -> some View {
        ZStack {
            if case let .circle(color) = animationStyle {
                SUICircularProgressView(color: color, from: 1, to: 0, duration: duration, completion: nil)
                    .padding(8)
            }

            SUILabelView(
                model: .init(
                    accessibilityIdentifier: model.accessibilityIdentifier,
                    model: mapToString?(from + (displayLinkManager.progress * (to - from))) ?? .text("")
                ),
                font: defaultFont,
                textColor: defaultTextColor,
                textAlignment: defaultTextAlignment
            )
            .onAppear {
                guard duration > 0 else { return }
                displayLinkManager.startAnimation(duration: duration, completion: nil)
            }
        }
    }

    private var inlineImageText: Text? {
        guard case .attributes(let attributes) = model.model, !attributes.isEmpty else { return nil }
        guard attributes.contains(where: { $0.leadingImage != nil || $0.trailingImage != nil }) else { return nil }

        var result = Text("")
        for attribute in attributes {
            let text = attribute.text.removingPercentEncoding ?? attribute.text
            if let leadingImage = attribute.leadingImage {
                result = result + Text(SwiftUIImage(image: leadingImage)) + Text(" ")
            }
            result = result + Text(text)
            if let trailingImage = attribute.trailingImage {
                result = result + Text(" ") + Text(SwiftUIImage(image: trailingImage))
            }
        }
        return result
    }

    private var nsAttributedText: NSAttributedString? {
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
            return attributed

        case .attributes(let attributes):
            guard !attributes.contains(where: { $0.leadingImage != nil || $0.trailingImage != nil }) else {
                return nil
            }
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
            return attributed

        case .attributedString(let htmlString, let config):
            guard
                let htmlString,
                let attributed = htmlString.asHtmlAttributedString(config: config)
            else {
                return nil
            }
            return attributed

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
        let wholeRange = NSRange(location: 0, length: mutable.length)
        let shouldForceDefaultColor = modelUsesOnlyDefaultColors

        mutable.enumerateAttributes(in: wholeRange) { attributes, range, _ in
            if shouldForceDefaultColor {
                mutable.addAttribute(.foregroundColor, value: resolvedDefaultPlatformTextColor, range: range)
            } else if attributes[.foregroundColor] == nil {
                mutable.addAttribute(.foregroundColor, value: resolvedDefaultPlatformTextColor, range: range)
            } else if let color = attributes[.foregroundColor] as? Color, color == .label {
                mutable.addAttribute(.foregroundColor, value: resolvedDefaultPlatformTextColor, range: range)
            }
        }

        return mutable
    }

    private var modelUsesOnlyDefaultColors: Bool {
        guard case .attributes(let attributes) = model.model else { return false }
        return attributes.allSatisfy { $0.color == nil }
    }

    private var resolvedDefaultPlatformTextColor: Color {
        switch colorScheme {
        case .dark:
            return .white
        default:
            return .black
        }
    }

}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
private struct CoreTextAttributedLabel: View {
    @Environment(\.displayScale) private var displayScale
    private let verticalCorrection: CGFloat = -63

    let attributedText: NSAttributedString
    let alignment: TextAlignment

    var body: some View {
        GeometryReader { _ in
            Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { context, size in
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

                let constrainedSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
                let textOnlyAttributedText = textAttributedStringWithoutUnderline(from: attributedText)
                let framesetter = CTFramesetterCreateWithAttributedString(textOnlyAttributedText as CFAttributedString)
                let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                    framesetter,
                    CFRange(location: 0, length: textOnlyAttributedText.length),
                    nil,
                    constrainedSize,
                    nil
                )

                let textHeight = min(ceil(suggestedSize.height), size.height)
                let verticalInset = max((size.height - textHeight) / 2, 0)
                // CoreText uses bottom-left coordinates. Since we flip the drawing context to top-left
                // before CTLineDraw, convert top inset into bottom-left space to avoid shifting text down.
                let pathOriginY = max(size.height - textHeight - verticalInset, 0)
                let pathRect = CGRect(x: 0, y: pathOriginY, width: size.width, height: max(textHeight, 1))
                let path = CGPath(rect: pathRect, transform: nil)
                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRange(location: 0, length: textOnlyAttributedText.length),
                    path,
                    nil
                )

                bitmapContext.scaleBy(x: scale, y: scale)
                bitmapContext.textMatrix = .identity
                bitmapContext.translateBy(x: 0, y: size.height)
                bitmapContext.scaleBy(x: 1, y: -1)
                bitmapContext.setAllowsAntialiasing(true)
                bitmapContext.setShouldAntialias(true)
                bitmapContext.setShouldSmoothFonts(true)
                draw(frame: frame, in: bitmapContext, scale: scale)

                guard let image = bitmapContext.makeImage() else { return }
                context.withCGContext { cgContext in
                    cgContext.saveGState()
                    cgContext.interpolationQuality = .high
                    cgContext.draw(image, in: CGRect(origin: .zero, size: size))
                    cgContext.restoreGState()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: frameAlignment(for: alignment))
        .offset(y: verticalCorrection)
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

    private func textAttributedStringWithoutUnderline(from attributedText: NSAttributedString) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let wholeRange = NSRange(location: 0, length: mutable.length)

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

            if style.contains(.byWord) || style.contains(.double) || style.contains(.thick) {
                mutable.removeAttribute(.underlineStyle, range: range)
            }
        }

        return mutable
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
            drawUnderlineSegments(for: line, at: origin, in: context, scale: scale)
        }
    }

    private func drawUnderlineSegments(for line: CTLine, at origin: CGPoint, in context: CGContext, scale: CGFloat) {
        let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []

        for run in runs {
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let rawValue: Int?
            if let number = attributes[kCTUnderlineStyleAttributeName] as? NSNumber {
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

            let foregroundColor = (attributes[NSAttributedString.Key.foregroundColor] as? UIColor)?.cgColor
                ?? (attributes[kCTForegroundColorAttributeName] as? UIColor)?.cgColor
            context.setStrokeColor(foregroundColor ?? UIColor.label.cgColor)

            let baselineOffset = (attributes[NSAttributedString.Key.baselineOffset] as? NSNumber)?.doubleValue ?? 0
            let textRange = CTRunGetStringRange(run)
            let segments = underlineSegments(for: style, line: line, stringRange: textRange)

            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            CTRunGetTypographicBounds(run, CFRange(location: 0, length: 0), &ascent, &descent, nil)

            let pixel = max(1 / scale, 0.5)
            let underlineY = origin.y - descent + CGFloat(baselineOffset) - pixel
            let spacing = pixel
            let lineWidth = pixel

            context.saveGState()
            context.setLineWidth(lineWidth)
            context.setLineCap(.butt)

            for segment in segments {
                if style.contains(.double) {
                    context.move(to: CGPoint(x: segment.lowerBound, y: underlineY))
                    context.addLine(to: CGPoint(x: segment.upperBound, y: underlineY))
                    context.move(to: CGPoint(x: segment.lowerBound, y: underlineY - spacing - lineWidth))
                    context.addLine(to: CGPoint(x: segment.upperBound, y: underlineY - spacing - lineWidth))
                } else {
                    context.move(to: CGPoint(x: segment.lowerBound, y: underlineY))
                    context.addLine(to: CGPoint(x: segment.upperBound, y: underlineY))
                }
            }

            context.strokePath()
            context.restoreGState()
        }
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
