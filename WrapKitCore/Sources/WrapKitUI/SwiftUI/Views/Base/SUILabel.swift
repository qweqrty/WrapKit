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
                let attributedString = AttributedString(item.makeNSAttributedString(unsupportedUnderlines: unsupportedUnderlines))
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
        
        let textAlignment = attributes.first(where: { $0.textAlignment != nil })?.textAlignment
        let suiTextAlignment = textAlignment?.suiTextAlignment
        
        return resultText
//            .ifLet(suiTextAlignment, modifier: { $0.multilineTextAlignment($1) })
//            .overlay {
//                if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
//                    LinkTapOverlay(attributes: attributes, textAlignment: textAlignment)
//                }
//            }
            .background( // TODO: check on iOS 14
                GeometryReader { geometry in
                    LinkTapOverlay(attributes: attributes, textAlignment: textAlignment)
                }
            )
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
        let y = abs(rect.origin.y) // needed to fix image placement with Text.baselineOffset
        let resultRect = CGRect(x: x, y: y, width: rect.width, height: rect.height)
        return (resultRect, targetSize)
    }
    
    private let unsupportedUnderlines: [NSUnderlineStyle] = [.thick, .double, .byWord]
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

private struct LinkTapOverlay: UIViewRepresentable {
    private(set) var attributes: [TextAttributes]
    let attributedString: NSAttributedString
    let textAlignment: TextAlignment
    
    init(
        attributes: [TextAttributes],
//        font: Font,
//        textColor: Color,
        textAlignment: TextAlignment? = nil
    ) {
        self.attributes = attributes
        self.textAlignment = textAlignment ?? .left
        self.attributedString = self.attributes.makeNSAttributedString(textAlignment: textAlignment)
    }

    func makeUIView(context: Context) -> LinkTapOverlayView {
        let view = LinkTapOverlayView { size in
            context.coordinator.textContainer.size = size
        }
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapLabel))
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)

        return view
    }

    func updateUIView(_ uiView: LinkTapOverlayView, context: Context) {
        context.coordinator.fillAtrributedString(attributedString)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private let overlay: LinkTapOverlay

        private let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        private var textStorage: NSTextStorage = .init()

        init(_ overlay: LinkTapOverlay) {
            self.overlay = overlay

            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = .byWordWrapping
            textContainer.maximumNumberOfLines = 0
            layoutManager.addTextContainer(textContainer)
        }
        
        func fillAtrributedString(_ attributedString: NSAttributedString) {
            self.textStorage = NSTextStorage(attributedString: attributedString)
            self.textStorage.addLayoutManager(layoutManager)
        }

        func gestureRecognizer(_ gesture: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard let view = gesture.view else { return false }
            let location = touch.location(in: view)
            return tappable(location: location) != nil
        }

        @objc func didTapLabel(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view else { return }
            let location = gesture.location(in: view)
            tappable(location: location)?()
        }

        private func tappable(location: CGPoint) -> (() -> Void)? {
            for attribute in overlay.attributes {
                guard let range = attribute.range else { continue }
                if NSLayoutManager.didTapAttributedTextInLabel(
                    point: location,
                    layoutManager: layoutManager,
                    textStorage: textStorage,
                    textContainer: textContainer,
                    textAlignment: overlay.textAlignment,
                    inRange: range
                ) {
                    return attribute.onTap
                }
            }
            return nil
        }
    }
}

private class LinkTapOverlayView: UIView {
    var onUpdateBounds: ((CGSize) -> Void)?
    
    init(onUpdateBounds: @escaping ((CGSize) -> Void)) {
        self.onUpdateBounds = onUpdateBounds
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        onUpdateBounds?(bounds.size)
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
