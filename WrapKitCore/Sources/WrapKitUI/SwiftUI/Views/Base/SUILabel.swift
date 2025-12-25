//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI

public struct SUILabel: View {
    @ObservedObject var stateModel: SUILabelStateModel
    
    private let defaultFont: Font
    
    public init(
        adapter: TextOutputSwiftUIAdapter,
        font: Font = .systemFont(ofSize: 20)
    ) {
        self.stateModel = .init(adapter: adapter)
        self.defaultFont = font
    }
    
    @ViewBuilder
    public var body: some View {
        if !stateModel.isHidden {
            SUILabelView(model: stateModel.presentable, font: defaultFont)
        }
    }
}

public struct SUILabelView: View, Animatable {
    let model: TextOutputPresentableModel
    
    private let defaultFont: Font
    private let suiFont: SwiftUIFont
    
    private let simpleTextYOffset: CGFloat
    private let simpleTextLineHeightMultiple: CGFloat
    
    public init(
        model: TextOutputPresentableModel,
        font: Font = .systemFont(ofSize: 20)
    ) {
        self.model = model
        self.defaultFont = font
        self.suiFont = SwiftUIFont(font)
#if os(macOS)
        simpleTextYOffset = 4 / min(20 + (max(0, font.pointSize - 30) * 0.5), 25)
#else
        simpleTextYOffset = font.lineHeight / min(20 + (max(0, font.pointSize - 30) * 0.5), 25)
#endif
        simpleTextLineHeightMultiple = 1.139 + (0.0015 * font.pointSize) // 1.131 + (0.0015 * font.pointSize)
        
        // TODO: not handled font higher than 30, formula below breaks on 10-20-40 except 30
//        let size = font.lineHeight
//        simpleTextLineHeightMultiple = -0.00002333 * size * size + 0.002367 * size + 1.1277
    }
    
    @StateObject private var displayLinkManager = SUIDisplayLinkManager()
    
    public var body: some View {
        switch model {
        case .text(let string):
            if let text = string?.removingPercentEncoding, !text.isEmpty {
                Text(text)
                    .font(suiFont)
                    .offset(y: -simpleTextYOffset)
                    .modify { if #available(iOS 26.0, *) {
                        if #available(macOS 26.0, *) {
                            $0.lineHeight(.multiple(factor: simpleTextLineHeightMultiple))
                        } else {
                            // MARK: - TODO
                        }
                    } }
            }
        case .attributes(let attributes):
            if !attributes.isEmpty {
                buildSwiftUIViewFromAttributes(from: attributes)
            }
        case .animated(let id, let from, let to, let mapToString, let animationStyle, let duration, let completion):
            ZStack {
                if case let .circle(color) = animationStyle {
                    SUICircularProgressView(color: color, from: 1, to: 0, duration: duration, completion: completion)
                        .padding(8)
                }
                
                SUILabelView(
                    model: mapToString?(from + (displayLinkManager.progress.doubleValue * (to - from))) ?? .text(""),
                    font: defaultFont
                )
                .onAppear {
                    guard duration > 0 else { return }
                    displayLinkManager.startAnimation(duration: duration, completion: completion)
                }
            }
        case .textStyled(let text, let cornerStyle, let insets, let height, let backgroundColor):
            SUILabelView(model: text, font: defaultFont)
                .if(!insets.isZero) { $0.padding(insets.asSUIEdgeInsets) }
                .ifLet(height) { $0.frame(height: $1, alignment: .center) }
                .frame(maxWidth: .infinity, alignment: .leading)
                .ifLet(backgroundColor) { $0.background(SwiftUIColor($1)) }
                .ifLet(cornerStyle) { $0.cornerStyle($1) }
        case .animatedDecimal(id: let id, from: let from, to: let to, mapToString: let mapToString, animationStyle: let animationStyle, duration: let duration, completion: let completion):
            ZStack {
                if case let .circle(color) = animationStyle {
                    SUICircularProgressView(color: color, from: 1, to: 0, duration: duration, completion: completion)
                        .padding(8)
                }
                
                SUILabelView(
                    model: mapToString?(from + (displayLinkManager.progress * (to - from))) ?? .text(""),
                    font: defaultFont
                )
                .onAppear {
                    guard duration > 0 else { return }
                    displayLinkManager.startAnimation(duration: duration, completion: completion)
                }
            }
        }
    }

    // MARK: - SwiftUI AttributedString builder (text-only)

    private func buildSwiftUIViewFromAttributes(from attributes: [TextAttributes]) -> some View {
        var result: [Text] = []
        
        for item in attributes {
            if let image = item.leadingImage {
                let view = buildSUIImageInText(bounds: item.leadingImageBounds, image: image)
                result.append(view)
            }
            
            if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
                let url: URL? = item.onTap == nil ? nil : URL(string: tappableUrlMask + item.id)
                let nsAttributedString = item.makeNSAttributedString(
                    font: defaultFont,
                    link: url
                )
                var attributedString = AttributedString(nsAttributedString)
                if let style = item.underlineStyle, unsupportedUnderlines.contains(style) {
                    attributedString.underlineStyle = .single
                } // others not working without, only with OR
                print("attributedString \(attributedString)")
                let textView = Text(attributedString)
                    .font(suiFont)
                result.append(textView)
            } else {
                let textView: Text = Text(item.text)
                    .ifLet(item.font) { $0.font(SwiftUIFont($1)) }
                    .ifLet(item.color) { $0.foregroundColor(SwiftUIColor($1)) }
                    .ifLet(item.underlineStyle) { view, _ in
                        view.underline() // #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
                    }
                result.append(textView)
            }
            
            // SwiftUI’s Text doesn’t use a true multi-line text layout engine yet (like NSTextStorage + NSTextContainer); it batches attributed runs but applies one paragraph layout per whole Text view.
            if let image = item.trailingImage {
                let view = buildSUIImageInText(bounds: item.trailingImageBounds, image: image)
                result.append(view)
            }
        }
        
        let textAlignment = attributes.first(where: { $0.textAlignment != nil })?.textAlignment
        
        return result.reduce(Text(""), +)
            .modify { if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
                $0.environment(\.openURL, OpenURLAction { url in
                    if let id = url.host {
                        attributes.first(where: { $0.id == id })?.onTap?()
                    }
                    return .discarded
                })
            } }
            .ifLet(textAlignment) {
                $0.multilineTextAlignment($1.suiTextAlignment)
                    .frame(maxWidth: .infinity, alignment: $1.suiAlignment)
            }
            .ifLet(attributes.first?.lineSpacing) {
                if $1 > .zero {
                    $0.lineSpacing($1 - 0.2) // somehow SwiftUI linespacing makes bigger than UIKit
                } else {
                    $0
                }
            }
    }
    
    private func buildSUIImageInText(bounds source: CGRect, image: Image) -> Text {
//        guard !source.isEmpty else { return Text(SwiftUIImage(image: image)) } // not respecting image original size
        let rect = source.isEmpty ? CGRect(origin: .zero, size: image.size) : source
        let bounds = resizeImageBoundsSUI(rect)
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
    .modify { if #available(iOS 26.0, *) {
        if #available(macOS 26.0, *) {
            $0.lineHeight(.multiple(factor: 1.17))
        } else {
            // MARK: - TODO
        }
    } }
    .frame(height: 150, alignment: .center)
    .frame(maxWidth: .infinity, alignment: .leading)
    
    SUILabelView(
        model: .text("This is really long text that should wrap and check for number of lines")
    )
    .font(.system(size: 30))
    .offset(y: -1.2)
    .modify { if #available(iOS 26.0, *) {
        if #available(macOS 26.0, *) {
            $0.lineHeight(.multiple(factor: 1.17))
        } else {
            // MARK: - TODO
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
