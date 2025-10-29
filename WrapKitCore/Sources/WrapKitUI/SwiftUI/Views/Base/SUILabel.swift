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
//        attributes.contains(where: { $0.leadingImage != nil || $0.trailingImage != nil || $0.onTap != nil })
        attributes.contains(where: { $0.onTap != nil })
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
                let textView = Text(attributedString)
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
            .onTapGestureLocation { point in
                
            }
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
    
    private let unsupportedUnderlines: [NSUnderlineStyle] = [.thick, .double, .byWord]

    private func makeNSAttributedString(_ item: TextAttributes) -> NSAttributedString {
        var underlineStyle = item.underlineStyle
        if let style = underlineStyle, unsupportedUnderlines.contains(style) { underlineStyle = .single } // others not working without, only with OR
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

/// UIViewRepresentable by reusing Label.swift
public struct FallbackLabel: UIViewRepresentable {
    
    @ObservedObject var adapter: TextOutputSwiftUIAdapter

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }

    public func makeUIView(context: Context) -> Label {
        let label = Label()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        context.coordinator.label = label
        return label
    }

    public func updateUIView(_ uiView: Label, context: Context) {
        uiView.display(attributes: adapter.displayAttributesState?.attributes ?? [])
    }
    
//    public func makeCoordinator() -> Coordinator { Coordinator() }
//    public class Coordinator { }
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
