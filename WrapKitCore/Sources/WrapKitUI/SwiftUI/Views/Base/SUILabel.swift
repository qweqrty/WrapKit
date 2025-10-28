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
    
    private func buildSwiftUIViewFromAttributes(from attributes: [TextAttributes]) -> some View {
        var result: [Text] = []

        for item in attributes {
            if let image = item.leadingImage {
                let view = buildSUIImageInText(bounds: item.leadingImageBounds, image: image)
                result.append(view)
            }
            
            if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
                let attributedString = AttributedString(makeNSAttributedString(item))
                let textView = Text(attributedString).ifLet(item.underlineStyle) {
                    // fix NSUnderlineStyle in SwiftUI
                    if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *), let pattern = $1.suiTextLineStylePattern {
                        $0.underline(pattern: pattern)
                    } else {
                        $0
                    }
                }
                result.append(textView)
            } else {
                let textView: Text = Text(item.text)
                    .ifLet(item.font) { $0.font(SwiftUIFont($1)) }
                    .ifLet(item.color) { $0.foregroundColor(SwiftUIColor($1)) }

                result.append(textView)
            }
            
            // SwiftUI’s Text doesn’t use a true multi-line text layout engine yet (like NSTextStorage + NSTextContainer); it batches attributed runs but applies one paragraph layout per whole Text view.
            if let image = item.trailingImage {
                let view = buildSUIImageInText(bounds: item.trailingImageBounds, image: image)
                result.append(view)
            }
        }
        
        let resultText = result.reduce(Text(""), +)
        
        let textAlignment = attributes.first(where: { $0.textAlignment != nil })?.textAlignment?.suiTextAlignment
        
        return resultText
            .ifLet(textAlignment, modifier: { $0.multilineTextAlignment($1) })
    }
    
    private func buildSUIImageInText(bounds source: CGRect, image: Image) -> Text {
        let bounds = resizeImageBoundsSUI(source)
        let imageResized = image.resized(rect: bounds.rect, container: bounds.size)
        let image = SwiftUIImage(image: imageResized)
        return Text(image)
            .baselineOffset(source.origin.y)
    }
    
    private func resizeImageBoundsSUI(_ rect: CGRect) -> (rect: CGRect, size: CGSize) {
        let targetSize = CGSize(width: abs(rect.origin.x) + rect.width, height: rect.size.height + abs(rect.origin.y))
        let x = rect.origin.x < .zero ? abs(rect.origin.x) : .zero
        let y = abs(rect.origin.y) // rect.origin.y > .zero ? abs(rect.origin.y) : .zero
        let resultRect = CGRect(x: x, y: y, width: rect.width, height: rect.height)
        return (resultRect, targetSize)
    }

    private func makeNSAttributedString(_ item: TextAttributes) -> NSAttributedString {
        var underlineStyle = item.underlineStyle
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            underlineStyle = nil // broken in SwiftUI, had to remove from iOS 16
        }
        return NSAttributedString(
            item.text,
            font: item.font, // ?? font,
            color: item.color, // ?? textColor,
            lineSpacing: 4,
            underlineStyle: underlineStyle,
            textAlignment: item.textAlignment, // ?? textAlignment,
            leadingImage: item.leadingImage,
            leadingImageBounds: item.leadingImageBounds,
            trailingImage: item.trailingImage,
            trailingImageBounds: item.trailingImageBounds
        )
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
public struct FallbackLabel: UIViewRepresentable {
    
    @ObservedObject var adapter: TextOutputSwiftUIAdapter

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }

    public func makeUIView(context: Context) -> Label {
//        context.coordinator.label = label
        return Label()
    }

    public func updateUIView(_ uiView: Label, context: Context) {
        uiView.display(attributes: adapter.displayAttributesState?.attributes ?? [])
    }
    
//    public func makeCoordinator() -> Coordinator { Coordinator() }
//    public class Coordinator {  }
}

// temporarily public
public extension UIImage {
    func resized(rect: CGRect, container: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: container).image { _ in
            draw(in: rect)
        }
        .withRenderingMode(renderingMode)
    }
}

#endif

#if canImport(Cocoa) && !targetEnvironment(macCatalyst)
import Cocoa
// temporarily public
public extension NSImage {
    /// Resizes the NSImage to the specified size.
    /// - Parameter rect: The desired size for the resized image.
    /// - Returns: A new NSImage instance with the resized image, or nil if the original image data is unavailable.

    func resized(rect: CGRect, container: CGSize) -> NSImage {
        let newImage = NSImage(size: container)
        newImage.lockFocus()

        // Get the current graphics context
        guard let context = NSGraphicsContext.current else {
            newImage.unlockFocus()
            return self
        }

        // Set interpolation quality for smoother scaling
        context.imageInterpolation = .high

        // Apply the offset by adjusting the targetRect for the drawing
        let adjustedRect = NSRect(
            x: rect.origin.x,
            y: container.height - rect.origin.y - rect.height, // Adjust y-axis for the flipped coordinate system
            width: rect.width,
            height: rect.height
        )
        self.draw(in: adjustedRect)

        newImage.unlockFocus()
        return newImage
    }
}
#endif

extension NSUnderlineStyle {
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    var suiTextLineStylePattern: Text.LineStyle.Pattern? {
        switch self {
        case .single, .double, .byWord: return .solid
        case .patternDot: return .dot
        case .patternDash: return .dash
        case .patternDashDot: return .dashDot
        case .patternDashDotDot: return .dashDotDot
        default: return nil
        }
    }
}

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
}
