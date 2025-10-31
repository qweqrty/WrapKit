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
            if let isHidden = adapter.displayIsHiddenState?.isHidden, isHidden {
                SwiftUICore.EmptyView()
            } else if let attributes = adapter.displayAttributesState?.attributes {
                AttributedText(attributes: attributes)
            } else {
                Text(displayText)
            }
        }
    }

    private var displayText: String {
        if let text = adapter.displayTextState?.text {
            return text
        } else if case let .text(text)? = adapter.displayModelState?.model {
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
    typealias UIViewType = UIView
    let attributes: [TextAttributes]

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        // allow SwiftUI to size this view
        container.translatesAutoresizingMaskIntoConstraints = true

        let label = TapableLabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        // Pin label to all edges of container
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        context.coordinator.label = label
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let label = context.coordinator.label else { return }
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

        label.setAttributedText(result, actions: actions)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator { var label: TapableLabel? }
}

/// UILabel subclass that handles tap gestures and wraps text within its width.
private class TapableLabel: UILabel {
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
}
