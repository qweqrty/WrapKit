////
////  SUILabel.swift
////  SwiftUIApp
////
////  Created by Stanislav Li on 17/4/25.
////
//
//import Foundation
//import SwiftUI
//
//public struct SUILabel: View {
//    @ObservedObject var adapter: TextOutputSwiftUIAdapter
//    
//    public init(adapter: TextOutputSwiftUIAdapter) {
//        self.adapter = adapter
//    }
//    
//    public var body: some View {
//        if adapter.displayIsHiddenState?.isHidden == true {
//            SwiftUI.EmptyView()
//            
//        } else if let attrs = adapter.displayAttributesState?.attributes {
//            SwiftUI.VStack(alignment: .leading, spacing: 0) {
//                ForEach(Array(attrs.enumerated()), id: \.0) { _, attr in
//                    buildSegment(attr)
//                }
//            }
//            .fixedSize(horizontal: false, vertical: true)
//            
//        } else if let model = adapter.displayModelState?.model {
//            switch model {
//            case .text(let t):
//                SwiftUI.Text(t ?? "")
//                    .fixedSize(horizontal: false, vertical: true)
//                
//            case .attributes(let attrs):
//                SwiftUI.VStack(alignment: .leading, spacing: 0) {
//                    ForEach(Array(attrs.enumerated()), id: \.0) { _, attr in
//                        buildSegment(attr)
//                    }
//                }
//                .fixedSize(horizontal: false, vertical: true)
//                
//            case .animated, .textStyled:
//                SwiftUI.Text("Unsupported").fixedSize()
//                
//            }
//        } else {
//            SwiftUI.EmptyView()
//        }
//    }
//    
//    private func buildSegment(_ attr: TextAttributes) -> some View {
//        SwiftUI.HStack(spacing: 4) {
//            if let img = attr.leadingImage {
//                SwiftUIImage(uiImage: img)
//                    .resizable()
//                    .frame(
//                        width: attr.leadingImageBounds.width,
//                        height: attr.leadingImageBounds.height
//                    )
//                    .offset(
//                        x: attr.leadingImageBounds.origin.x,
//                        y: attr.leadingImageBounds.origin.y
//                    )
//            }
//            
//            if let style = attr.underlineStyle {
//                if #available(iOS 16, macOS 13, *) {
//                    // build an NSMutableAttributedString with effective underline bits
//                    let aStr: AttributedString? = {
//                        let raw = style.rawValue
//                        let patternMask = 0xFF00
//                        let styleBits  = raw & ~patternMask
//                        // if only pattern bits, add a single‐line bit
//                        let effectiveRaw = styleBits != 0
//                        ? raw
//                        : raw | UnderlineStyle.single.rawValue
//                        
//                        let ms = NSMutableAttributedString(string: attr.text)
//                        ms.addAttribute(
//                            .underlineStyle,
//                            value: effectiveRaw,
//                            range: NSRange(location: 0, length: ms.length)
//                        )
//                        if let fg = attr.color {
//                            ms.addAttribute(
//                                .foregroundColor,
//                                value: fg,
//                                range: NSRange(location: 0, length: ms.length)
//                            )
//                        }
//                        if let fnt = attr.font {
//                            ms.addAttribute(
//                                .font,
//                                value: fnt,
//                                range: NSRange(location: 0, length: ms.length)
//                            )
//                        }
//                        return AttributedString(ms)
//                    }()
//                    
//                    if let a = aStr {
//                        Text(a)
//                            .font(attr.font.map { SwiftUI.Font($0) })
//                            .onTapGesture { attr.onTap?() }
//                    } else {
//                        // fallback if conversion fails
//                        Text(attr.text)
//                            .font(attr.font.map { SwiftUI.Font($0) })
//                            .foregroundColor(attr.color.map { SwiftUI.Color($0) } ?? .primary)
//                            .underline(true, color: attr.color.map { SwiftUI.Color($0) } ?? .primary)
//                            .onTapGesture { attr.onTap?() }
//                    }
//                } else {
//                    // iOS14/15 fallback: simple underline
//                    Text(attr.text)
//                        .font(attr.font.map { SwiftUI.Font($0) })
//                        .foregroundColor(attr.color.map { SwiftUI.Color($0) } ?? .primary)
//                        .underline(true, color: attr.color.map { SwiftUI.Color($0) } ?? .primary)
//                        .onTapGesture { attr.onTap?() }
//                }
//            } else {
//                // no underline
//                Text(attr.text)
//                    .font(attr.font.map { SwiftUI.Font($0) })
//                    .foregroundColor(attr.color.map { SwiftUI.Color($0) } ?? .primary)
//                    .onTapGesture { attr.onTap?() }
//            }
//            
//            if let img = attr.trailingImage {
//                SwiftUI.Image(uiImage: img)
//                    .resizable()
//                    .frame(
//                        width: attr.trailingImageBounds.width,
//                        height: attr.trailingImageBounds.height
//                    )
//                    .offset(
//                        x: attr.trailingImageBounds.origin.x,
//                        y: attr.trailingImageBounds.origin.y
//                    )
//            }
//        }
//        .fixedSize(horizontal: false, vertical: true)
//    }
//}

/// ----------------------------


import SwiftUI

// MARK: - FlowLayout

/// A pure-SwiftUI flow layout that wraps its child views onto multiple lines
/// when they exceed the width of the container.
public struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Index: Hashable {
    private let items: Data
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    public init(
        items: Data,
        horizontalSpacing: CGFloat = 4,
        verticalSpacing: CGFloat = 4,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(items.indices, id: \.self) { index in
                content(items[index])
                    .alignmentGuide(.leading) { dimension in
                        if abs(x - dimension.width) > geometry.size.width {
                            x = 0
                            y -= dimension.height + verticalSpacing
                        }
                        let result = x
                        x -= dimension.width + horizontalSpacing
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = y
                        return result
                    }
            }
        }
        .background(
            GeometryReader { proxy in
                SwiftUIColor.clear
                    .preference(key: MaxHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(MaxHeightPreferenceKey.self) { height in
            totalHeight = height
        }
    }
}

private struct MaxHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
/*

// MARK: - SUILabel Using FlowLayout

public struct SUILabel: View {
    @ObservedObject public var adapter: TextOutputSwiftUIAdapter

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }

    public var body: some View {
        if adapter.displayIsHiddenState?.isHidden == true {
            SwiftUI.EmptyView()
        }
        else if let attrs = adapter.displayAttributesState?.attributes {
            FlowLayout(
                items: attrs,
                horizontalSpacing: 4,
                verticalSpacing: 4
            ) { attr in
                buildSegment(attr)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        else if let model = adapter.displayModelState?.model {
            switch model {
            case .text(let t):
                Text(t ?? "").fixedSize(horizontal: false, vertical: true)

            case .attributes(let attrs):
                FlowLayout(
                    items: attrs,
                    horizontalSpacing: 4,
                    verticalSpacing: 4
                ) { attr in buildSegment(attr) }
                .fixedSize(horizontal: false, vertical: true)

            case .animated, .textStyled:
                Text("Unsupported").fixedSize()
            }
        }
        else {
            SwiftUI.EmptyView()
        }
    }

    private func buildSegment(_ attr: TextAttributes) -> some View {
        HStack(spacing: 4) {
            if let img = attr.leadingImage {
                SwiftUIImage(uiImage: img)
                    .resizable()
                    .frame(width: attr.leadingImageBounds.width,
                           height: attr.leadingImageBounds.height)
                    .offset(x: attr.leadingImageBounds.origin.x,
                            y: attr.leadingImageBounds.origin.y)
            }

            Group {
                if let style = attr.underlineStyle, #available(iOS 16, *) {
                    let run = buildAttributedRun(attr)
                    Text(run)
                        .onTapGesture { attr.onTap?() }
                } else {
                    Text(attr.text)
                        .font(attr.font.map { SwiftUIFont($0) })
                        .foregroundColor(attr.color.map { SwiftUIColor($0) } ?? .primary)
                        .underline(attr.underlineStyle != nil,
                                   color: attr.color.map { SwiftUIColor($0) } ?? .primary)
                        .onTapGesture { attr.onTap?() }
                }
            }

            if let img = attr.trailingImage {
                SwiftUIImage(uiImage: img)
                    .resizable()
                    .frame(width: attr.trailingImageBounds.width,
                           height: attr.trailingImageBounds.height)
                    .offset(x: attr.trailingImageBounds.origin.x,
                            y: attr.trailingImageBounds.origin.y)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @available(iOS 16, *)
    private func buildAttributedRun(_ attr: TextAttributes) -> AttributedString {
        var run = AttributedString(attr.text)
        run.font = attr.font.map { SwiftUIFont($0) }
        run.foregroundColor = attr.color.map { SwiftUIColor($0) } ?? .primary
        if let style = attr.underlineStyle {
            run.underlineStyle = style
        }
        return run
    }
}
*/
//
//import SwiftUI
//import UIKit    // for NSTextAttachment
//
///// 100% SwiftUI view (iOS 16+)
//@available(iOS 16, *)
//public struct SUILabel: View {
//    @ObservedObject public var adapter: TextOutputSwiftUIAdapter
//
//    public init(adapter: TextOutputSwiftUIAdapter) {
//        self.adapter = adapter
//    }
//
//    public var body: some View {
//        // 1) hidden?
//        if adapter.displayIsHiddenState?.isHidden == true {
//            SwiftUI.EmptyView()
//
//        // 2) attributed runs?
//        } else if let attrs = adapter.displayAttributesState?.attributes {
//            let (attrString, actionMap) = buildAttributed(from: attrs)
//
//            // Single Text view that wraps + handles taps via openURL action:
//            Text(attrString)
//                .fixedSize(horizontal: false, vertical: true)
//                .environment(\.openURL, OpenURLAction { url in
//                    if let action = actionMap[url] {
//                        action()
//                        return .handled            // consume it
//                    }
//                    return .systemAction           // let other URLs pass through
//                })
//
//        // 3) plain-text fallback
//        } else if case .text(let t)? = adapter.displayModelState?.model {
//            Text(t ?? "")
//                .fixedSize(horizontal: false, vertical: true)
//
//        // 4) nothing
//        } else {
//            SwiftUI.EmptyView()
//        }
//    }
//
//    @available(iOS 16, *)
//    private func buildAttributed(from attrs: [TextAttributes])
//      -> (AttributedString, [URL: ()->Void])
//    {
//        var full       = AttributedString()
//        var actionMap = [URL: () -> Void]()
//
//        for attr in attrs {
//            // Leading image
//            if let uiImg = attr.leadingImage {
//                let attachment = NSTextAttachment()
//                attachment.image = uiImg
//                attachment.bounds = CGRect(
//                    x: 0,
//                    y: attr.leadingImageBounds.origin.y,      // small vertical tweak if you need
//                    width: attr.leadingImageBounds.width,
//                    height: attr.leadingImageBounds.height
//                )
//                let ns = NSAttributedString(attachment: attachment)
//                if let run = try? AttributedString(ns) {
//                    full.append(run)
//                }
//            }
//
//            // Text run…
//            var run = AttributedString(attr.text)
//            if let f = attr.font       { run.font            = SwiftUIFont(f) }
//            if let c = attr.color      { run.foregroundColor = SwiftUIColor(c) }
//            if let u = attr.underlineStyle {
//                run.underlineStyle = u
//            }
//            if let tap = attr.onTap {
//                let url = URL(string: "suilabel://\(UUID())")!
//                run.link      = url
//                actionMap[url] = tap
//            }
//            full.append(run)
//
//            // Trailing image
//            if let uiImg = attr.trailingImage {
//                let attachment = NSTextAttachment()
//                attachment.image = uiImg
//                attachment.bounds = CGRect(
//                    x: 0,
//                    y: attr.trailingImageBounds.origin.y,
//                    width: attr.trailingImageBounds.width,
//                    height: attr.trailingImageBounds.height
//                )
//                let ns = NSAttributedString(attachment: attachment)
//                if let run = try? AttributedString(ns) {
//                    full.append(run)
//                }
//            }
//        }
//
//        return (full, actionMap)
//    }
//}
// SUILabel.swift
// SUILabel.swift

import SwiftUI

@available(iOS 16, *)
public struct SUILabel: View {
    @ObservedObject public var adapter: TextOutputSwiftUIAdapter

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }

    public var body: some View {
        if adapter.displayIsHiddenState?.isHidden == true {
            SwiftUI.EmptyView()
        }
        else if let attrs = adapter.displayAttributesState?.attributes {
            FlowLayout(items: attrs, horizontalSpacing: 4, verticalSpacing: 4) { attr in
                HStack(spacing: 4) {
                    // leading UIImage
                    if let img = attr.leadingImage {
                        SwiftUIImage(uiImage: img)
                            .resizable()
                            .frame(
                              width: attr.leadingImageBounds.width,
                              height: attr.leadingImageBounds.height
                            )
                    }

                    // the text
                    Text(attr.text)
                        .font(attr.font.map { SwiftUIFont($0) } ?? .body)
                        .foregroundColor(attr.color.map { SwiftUIColor($0) } ?? .primary)
                        .underline(attr.underlineStyle != nil, color: attr.color.map { SwiftUIColor($0) } ?? .primary)

                    // trailing UIImage
                    if let img = attr.trailingImage {
                        SwiftUIImage(uiImage: img)
                            .resizable()
                            .frame(
                              width: attr.trailingImageBounds.width,
                              height: attr.trailingImageBounds.height
                            )
                    }
                }
                .contentShape(Rectangle())  // make the whole HStack tappable
                .onTapGesture {
                    attr.onTap?()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        else if case .text(let t)? = adapter.displayModelState?.model {
            Text(t ?? "")
                .fixedSize(horizontal: false, vertical: true)
        }
        else {
            SwiftUI.EmptyView()
        }
    }
}
