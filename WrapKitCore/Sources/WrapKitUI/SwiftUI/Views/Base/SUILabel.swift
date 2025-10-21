//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

import Foundation
import SwiftUI

public struct SUILabel: View {

    @ObservedObject var adapter: TextOutputSwiftUIAdapter

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }

    public var body: some View {
        Group {
            if let isHidden = adapter.displayIsHiddenState?.isHidden, isHidden {
                SwiftUI.EmptyView()
            } else if let attributes = adapter.displayAttributesState?.attributes {
                buildSwiftUIViewFromAttributes(from: attributes)
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

    // MARK: - Rendering decision helpers

    private func needsUIKit(_ attributes: [TextAttributes]) -> Bool {
        // SwiftUI's AttributedString cannot embed images or attach per-range tap handlers.
        // If any attribute contains an image or tap action, use the UIKit path.
        attributes.contains(where: { $0.leadingImage != nil || $0.trailingImage != nil || $0.onTap != nil })
    }

    // MARK: - SwiftUI AttributedString builder (text-only)

    // Standardize to a single concrete return type using AnyView to fix opaque type mismatch.
    private func buildSwiftUIViewFromAttributes(from attributes: [TextAttributes]) -> Text {
        var result: [Text] = []

        for item in attributes {
            if let image = item.leadingImage {
                let imageResized = image.resized(rect: item.leadingImageBounds)
                let view = Text(SwiftUI.Image(uiImage: imageResized))
                result.append(view)
            }
            if #available(iOS 15, *) {
                let textView = Text(AttributedString(makeNSAttributedString(item)))
                result.append(textView)
            } else {
                let textView = Text(makeNSAttributedString(item).string)
                    .ifLet(item.font) { $0.font(SwiftUIFont($1 as CTFont)) }
                    .ifLet(item.color) { $0.foregroundColor(SwiftUIColor($1)) }
//                    .ifLet(item.underlineStyle, transform: { $0.underline() }) // available only from iOS 16
                    .ifLet(item.textAlignment) { $0.multilineTextAlignment($1.suiTextAlignment) }
                as! Text

                result.append(textView)
            }
            if let image = item.trailingImage {
                let imageResized = image.resized(rect: item.trailingImageBounds)
                let imageView = SwiftUI.Image(uiImage: imageResized)
//                    .ifLet(item.trailingImageBounds) { view, bounds in
//                        view.frame(width: bounds.width, height: bounds.height)
////                    .scaledToFit()
//                    } as! SwiftUIImage
                let view = Text(imageView)
                result.append(view)
            }
        }

        return result.reduce(Text(""), +)
    }

    private func makeNSAttributedString(_ current: TextAttributes) -> NSAttributedString {
//        return attributes.reduce(into: NSMutableAttributedString()) { result, current in
            return NSAttributedString(
                current.text,
                font: current.font, // ?? font,
                color: current.color, // ?? textColor,
                lineSpacing: 4,
                underlineStyle: current.underlineStyle ?? [],
                textAlignment: current.textAlignment, // ?? textAlignment,
                leadingImage: current.leadingImage,
                leadingImageBounds: current.leadingImageBounds,
                trailingImage: current.trailingImage,
                trailingImageBounds: current.trailingImageBounds
            )
//            result.append(item)
//        }
    }
}

extension NSTextAlignment {
    var suiTextAlignment: SwiftUI.TextAlignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        case .justified: .center
        case .natural: .center
        @unknown default: fatalError()
        }
    }
}

#if canImport(UIKit)
import UIKit

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

/// UIViewRepresentable by reusing Label.swift
private struct FallbackText: UIViewRepresentable {
//    typealias UIViewType = Label
    let attributes: [TextAttributes]

    func makeUIView(context: Context) -> Label {
        return Label()
    }

    func updateUIView(_ uiView: Label, context: Context) {
        uiView.display(attributes: attributes)
    }
}

#endif

#if os(macOS)
import Cocoa

extension NSImage {
    /// Resizes the NSImage to the specified size.
    /// - Parameter targetSize: The desired size for the resized image.
    /// - Returns: A new NSImage instance with the resized image, or nil if the original image data is unavailable.
    func resized(to targetSize: NSSize) -> NSImage? {
        return resized(rect: .init(size: targetSize))
    }

    func resized(rect: CGRect) -> UIImage {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()

        // Get the current graphics context
        guard let context = NSGraphicsContext.current else {
            newImage.unlockFocus()
            return nil
        }

        // Set interpolation quality for smoother scaling
        context.imageInterpolation = .high

        // Draw the original image into the new context, scaled to the target size
        self.draw(
            in: NSRect(origin: rect.origin, size: rect.size),
            from: NSRect(origin: .zero, size: self.size),
            operation: .sourceOver,
            fraction: 1.0
        )

        newImage.unlockFocus()
        return newImage
    }
}

#elseif os(iOS) || os(tvOS) || os(watchOS)

extension UIImage {
    func resized(rect: CGRect) -> UIImage {
        // bounds: rect - not works, so we have to calc targetSize
//        return UIGraphicsImageRenderer(bounds: rect).image { _ in
//            draw(in: rect)
//        }
//        .withRenderingMode(renderingMode)
        let targetSize = CGSize(width: rect.origin.x + rect.width, height: rect.origin.y + rect.size.height)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            draw(in: rect)
        }
        .withRenderingMode(renderingMode)
    }
}

#endif
