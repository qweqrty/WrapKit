//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

import Foundation
import SwiftUI
import UIKit

public struct SUILabel: View {
    @ObservedObject var adapter: TextOutputSwiftUIAdapter

    public var body: some View {
        Group {
            if adapter.displayIsHiddenState?.isHidden == true {
                SwiftUICore.EmptyView()
            } else if let attrs = adapter.displayAttributesState?.attributes {
                AttributedText(attributes: attrs)
                      .frame(maxWidth: .infinity, alignment: .leading)
            } else if let model = adapter.displayModelState?.model {
                switch model {
                case .text(let text):
                    Text(text ?? "")
                    
                case .attributes(let attributes):
                    AttributedText(attributes: attributes)
                          .frame(maxWidth: .infinity, alignment: .leading)
                    
                case .animated:
                    fatalError("SUILabel: 'animated' case is not supported")
                    
                case .textStyled:
                    fatalError("SUILabel: 'textStyled' case is not supported")
                }
            } else {
                SwiftUICore.EmptyView()
            }
        }
    }

    private var displayText: String {
        if let textState = adapter.displayTextState, let text = textState.text {
            return text
        } else if let modelState = adapter.displayModelState, case .text(let text) = modelState.model {
            return text ?? ""
        }
        return ""
    }

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }
}

/// UIViewRepresentable that builds an NSAttributedString with images, underlines, and tap handlers.
private struct AttributedText: UIViewRepresentable {
    typealias UIViewType = TapableLabel
    let attributes: [TextAttributes]

    func makeUIView(context: Context) -> TapableLabel {
        let label = TapableLabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ uiView: TapableLabel, context: Context) {
        let result = NSMutableAttributedString()
        var actions: [(NSRange, () -> Void)] = []

        for attr in attributes {
            // Leading image
            if let image = attr.leadingImage {
                let attach = NSTextAttachment()
                attach.image = image
                attach.bounds = attr.leadingImageBounds
                result.append(NSAttributedString(attachment: attach))
            }
            // Text
            let start = result.length
            // Build attributes dictionary
            var textAttrs: [NSAttributedString.Key: Any] = [:]
            // Font & color
            textAttrs[.font] = attr.font ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)
            textAttrs[.foregroundColor] = attr.color ?? UIColor.label
            // Paragraph style for wrapping & alignment
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byWordWrapping
            paragraph.alignment = attr.textAlignment ?? .natural
            textAttrs[.paragraphStyle] = paragraph
            // Underline style (including pattern bits)
            if let style = attr.underlineStyle {
                var effective = style
                let patternMask = 0xFF00
                let styleBits = effective.rawValue & ~patternMask
                let patternBits = effective.rawValue & patternMask
                if patternBits != 0 && styleBits == 0 {
                    effective.insert(.single)
                }
                textAttrs[.underlineStyle] = effective.rawValue
            }
            let piece = NSAttributedString(string: attr.text, attributes: textAttrs)
            result.append(piece)
            // Tap action
            if let onTap = attr.onTap {
                let range = NSRange(location: start, length: piece.length)
                actions.append((range, onTap))
            }
            // Trailing image
            if let image = attr.trailingImage {
                let attach = NSTextAttachment()
                attach.image = image
                attach.bounds = attr.trailingImageBounds
                result.append(NSAttributedString(attachment: attach))
            }
        }

        uiView.setAttributedText(result, actions: actions)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator { var label: TapableLabel? }
}

/// UILabel subclass that handles tap gestures and wraps text within its width.
private class TapableLabel: UILabel, UIGestureRecognizerDelegate {
    private var actions: [(range: NSRange, handler: () -> Void)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        numberOfLines = 0
        isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
        
        lineBreakMode = .byWordWrapping
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // ensure multiline wraps to current width
        preferredMaxLayoutWidth = bounds.width
    }
    
    func setAttributedText(_ attributed: NSAttributedString, actions: [(NSRange, () -> Void)]) {
        self.attributedText = attributed
        self.actions = actions
    }
    
    @objc private func didTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = attributedText else { return }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        let location = gesture.location(in: self)
        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        for (range, handler) in actions {
            if NSLocationInRange(index, range) {
                handler()
                break
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let tap = gestureRecognizer as? UITapGestureRecognizer,
              let attributedText = attributedText
        else { return false }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        
        let location = tap.location(in: self)
        let idx = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Only begin recognition if we’re actually over one of our action ranges:
        return actions.contains { NSLocationInRange(idx, $0.range) }
    }
}

//------------------

import SwiftUI
import UIKit   // for UIImage, UIFont

// 1️⃣ The per‐segment view that shows leading/trailing images, styled text, and handles its own onTap
struct SegmentView: View {
    let attr: TextAttributes
    
    var body: some View {
        HStack(spacing: 0) {
            // Leading image if any
            if let img = attr.leadingImage {
                SwiftUI.Image(uiImage: img)
                    .resizable()
                    .frame(
                      width: attr.leadingImageBounds.width,
                      height: attr.leadingImageBounds.height
                    )
            }
            
            // The text itself
            Text(attr.text)
                .font(attr.font.map { SwiftUI.Font($0) } ?? .system(size: UIFont.labelFontSize))
                .foregroundColor(attr.color.map { SwiftUI.Color($0) } ?? .primary)
                .underline(attr.underlineStyle != nil, color: attr.color.map { SwiftUI.Color($0) } ?? .primary)
                .onTapGesture { attr.onTap?() }
            
            // Trailing image if any
            if let img = attr.trailingImage {
                SwiftUI.Image(uiImage: img)
                    .resizable()
                    .frame(
                      width: attr.trailingImageBounds.width,
                      height: attr.trailingImageBounds.height
                    )
            }
        }
    }
}

// 2️⃣ A generic “flow” layout that wraps its children to new lines
struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (Data.Element) -> Content
    
    @State private var totalHeight: CGFloat = .zero
    
    init(
      data: Data,
      spacing: CGFloat = 0,
      lineSpacing: CGFloat = 4,
      @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geo in
            self.generate(in: geo)
        }
        // force container to expand to the computed height
        .frame(height: totalHeight)
    }
    
    private func generate(in geo: GeometryProxy) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    // measure this child
                    .fixedSize()
                    .alignmentGuide(.leading) { d in
                        if x + d.width > geo.size.width {
                            // wrap to next line
                            x = 0
                            y -= d.height + lineSpacing
                        }
                        let result = x
                        x += d.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { d in
                        let result = y
                        return result
                    }
            }
        }
        // read total height
        .background(HeightReader())
        .onPreferenceChange(HeightPreferenceKey.self) { totalHeight = $0 }
    }
    
    // helper to capture the ZStack’s height
    private struct HeightReader: View {
        var body: some View {
            GeometryReader { gp in
                SwiftUI.Color.clear.preference(
                  key: HeightPreferenceKey.self,
                  value: gp.size.height
                )
            }
        }
    }
    private struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = .zero
        static func reduce(
          value: inout CGFloat,
          nextValue: () -> CGFloat
        ) {
            value = max(value, nextValue())
        }
    }
}

// 3️⃣ Your “pure-SwiftUI” label that uses FlowLayout + SegmentView
struct PureFlowLabel: View {
    let attributes: [TextAttributes]
    
    var body: some View {
        FlowLayout(
          data: attributes,
          spacing: 0,
          lineSpacing: 4
        ) { attr in
            SegmentView(attr: attr)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

