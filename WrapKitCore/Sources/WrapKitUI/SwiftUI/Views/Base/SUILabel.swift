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
    
    public init(adapter: TextOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }
    
    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUILabelView(model: stateModel.presentable)
        }
    }
}

public struct SUILabelView: View, Animatable {
    let model: TextOutputPresentableModel
    
    @StateObject private var displayLinkManager = SUIDisplayLinkManager()
    
    public var body: some View {
        switch model {
        case .text(let text):
            if let text = text?.removingPercentEncoding, !text.isEmpty {
                Text(text)
            }
            
        case .attributes(let attributes):
            if !attributes.isEmpty {
                buildSwiftUIViewFromAttributes(from: attributes)
            }
            
        case .animated(let from, let to, let mapToString, let animationStyle, let duration, let completion):

            ZStack {
                if case let .circle(color) = animationStyle {
                    SUICircularProgressView(color: color, from: 1, to: 0, duration: duration, completion: completion)
                        .padding(8)
                }
                
                SUILabelView(
                    model: mapToString?(from + (Float(displayLinkManager.progress) * (to - from))) ?? .text("")
                )
//                .modify {
//                    if #available(iOS 16.0, *) {
//                        $0.monospacedDigit()
//                    }
//                }
                .onAppear {
                    displayLinkManager.stopAnimation()
                    displayLinkManager.startAnimation(duration: duration)
                }
                
//                SUILabelView(model: data).backgroundView {
//                }
            }
            
        case .textStyled(let text, let cornerStyle, let insets):
            SUILabelView(model: text)
                .if(!insets.isZero) { $0.padding(insets.asSUIEdgeInsets) }
//                .background(SwiftUIColor.green)
                .ifLet(cornerStyle) { $0.cornerStyle($1) }
        }
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
//        guard !attributes.isEmpty else { return SwiftUI.EmptyView() }
        var result: [Text] = []

        for item in attributes {
            if let image = item.leadingImage {
                let view = buildSUIImageInText(bounds: item.leadingImageBounds, image: image)
                result.append(view)
            }
            
            if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
                let nsAttributedString = item.makeNSAttributedString(unsupportedUnderlines: unsupportedUnderlines)
                var attributedString = AttributedString(nsAttributedString)
                attributedString.link = URL(string: tappableUrlMask + item.id)
                let textView = Text(attributedString)
                result.append(textView)
            } else {
                let textView: Text = Text(item.text)
                    .ifLet(item.font) { $0.font(SwiftUIFont($1)) }
                    .ifLet(item.color) { $0.foregroundColor(SwiftUIColor($1)) }
                    .ifLet(item.underlineStyle) { view, _ in view.underline() } // underline pattern only works from iOS 16
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
        
        return resultText
            .modify {
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    $0.environment(\.openURL, OpenURLAction { url in
                        if let id = url.host {
                            attributes.first(where: { $0.id == id })?.onTap?()
                        }
                        return .discarded
                    })
                }
            }
            .ifLet(textAlignment?.suiTextAlignment, modifier: { $0.multilineTextAlignment($1) })
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
    
    private let tappableUrlMask = "tappable://"
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

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var animationProgress: Double = 0.1
    
    VStack {
        SUILabelView(
            model: .animated(
                1.2, 225,
                mapToString: { .text($0.asString()) },
                animationStyle: .circle(lineColor: .red),
                duration: 5,
                completion: { print("completed") }
            )
        ).frame(height: 100)
    }
}
