//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

//import Foundation
//import SwiftUI
//import WrapKit

//struct SUILabel: View {
//    @ObservedObject var adapter: TextOutputSwiftUIAdapter
//    
//    var body: some View {
//        Group {
//            if let isHiddenState = adapter.displayIsHiddenState, isHiddenState.isHidden {
//                SwiftUICore.EmptyView()
//            } else {
//                Text(displayText)
//            }
//        }
//    }
//    
//    private var displayText: String {
//        if let textState = adapter.displayTextState, let text = textState.text {
//            return text
//        } else if let modelState = adapter.displayModelState, case .text(let text) = modelState.model {
//            return text ?? ""
//        }
//        return ""
//    }
//    
//}

//struct SUILabel: View {
//    @ObservedObject var adapter: TextOutputSwiftUIAdapter
//    @State private var cornerStyle: CornerStyle?
//    @State private var textInsets: SwiftUICore.EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
//    @State private var backgroundColor: SwiftUIColor = .clear
//    @State private var font: SwiftUIFont? = .system(.body)
//    @State private var textColor: SwiftUIColor = .primary
//    @State private var textAlignment: SwiftUI.TextAlignment = .leading
//    @State private var numberOfLines: Int = 0
//    @State private var minimumScaleFactor: CGFloat = 0
//    @State private var adjustsFontSizeToFitWidth: Bool = false
//
//    init(
//        adapter: TextOutputSwiftUIAdapter,
//        backgroundColor: SwiftUIColor = .clear,
//        font: SwiftUIFont? = .system(.body),
//        textColor: SwiftUIColor = .primary,
//        textAlignment: SwiftUI.TextAlignment = .leading,
//        numberOfLines: Int = 0,
//        minimumScaleFactor: CGFloat = 0,
//        adjustsFontSizeToFitWidth: Bool = false,
//        cornerStyle: CornerStyle? = nil,
//        textInsets: SwiftUI.EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
//    ) {
//        self.adapter = adapter
//        self._backgroundColor = .init(initialValue: backgroundColor)
//        self._font = .init(initialValue: font)
//        self._textColor = .init(initialValue: textColor)
//        self._textAlignment = .init(initialValue: textAlignment)
//        self._numberOfLines = .init(initialValue: numberOfLines)
//        self._minimumScaleFactor = .init(initialValue: minimumScaleFactor)
//        self._adjustsFontSizeToFitWidth = .init(initialValue: adjustsFontSizeToFitWidth)
//        self._cornerStyle = .init(initialValue: cornerStyle)
//        self._textInsets = .init(initialValue: textInsets)
//    }
//
//    var body: some View {
//        GeometryReader { geometry in
//            Group {
//                if let isHiddenState = adapter.displayIsHiddenState, isHiddenState.isHidden {
//                    SwiftUI.EmptyView()
//                } else if let attributesState = adapter.displayAttributesState, !attributesState.attributes.isEmpty {
//                    AttributedTextView(
//                        attributes: attributesState.attributes,
//                        font: font ?? .system(.body),
//                        textColor: textColor,
//                        textAlignment: textAlignment,
//                        geometry: geometry
//                    )
//                } else {
//                    Text(displayText)
//                        .font(font)
//                        .foregroundColor(textColor)
//                        .multilineTextAlignment(textAlignment)
//                        .lineLimit(numberOfLines == 0 ? nil : numberOfLines)
//                        .minimumScaleFactor(minimumScaleFactor)
//                        .allowsTightening(adjustsFontSizeToFitWidth)
//                }
//            }
//            .padding(textInsets)
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius(for: geometry.size)))
//        }
//    }
//
//    private var displayText: String {
//        if let textState = adapter.displayTextState, let text = textState.text {
//            return text.removingPercentEncoding ?? text
//        } else if let modelState = adapter.displayModelState, case .text(let text) = modelState.model {
//            return text?.removingPercentEncoding ?? text ?? ""
//        }
//        return ""
//    }
//
//    private func cornerRadius(for size: CGSize) -> CGFloat {
//        guard let cornerStyle = cornerStyle else { return 0 }
//        switch cornerStyle {
//        case .automatic:
//            return size.height / 2
//        case .fixed(let radius):
//            return radius
//        case .none:
//            return 0
//        }
//    }
//}
//
//// Вспомогательная вью для обработки атрибутированного текста
//struct AttributedTextView: View {
//    let attributes: [TextAttributes]
//    let font: SwiftUIFont
//    let textColor: SwiftUIColor
//    let textAlignment: SwiftUI.TextAlignment
//    let geometry: GeometryProxy
//
//    var body: some View {
//        let attributedString = makeAttributedString()
//        Text(AttributedString(attributedString))
//            .multilineTextAlignment(textAlignment)
//            .gesture(
//                TapGesture()
//                    .onEnded { _ in
//                        handleTap(in: geometry)
//                    }
//            )
//    }
//
//    private func makeAttributedString() -> NSMutableAttributedString {
//        let combinedAttributedString = NSMutableAttributedString()
//        for attribute in attributes {
//            let swiftUIFont = attribute.font ?? font
//            let swiftUIColor = attribute.color ?? textColor
//            let attributedText = NSAttributedString(
//                string: attribute.text.removingPercentEncoding ?? attribute.text,
//                attributes: [
//                    .font: swiftUIFont.uiFont,
//                    .foregroundColor: UIColor(swiftUIColor),
//                    .underlineStyle: attribute.underlineStyle?.rawValue ?? 0
//                ]
//            )
//            combinedAttributedString.append(attributedText)
//        }
//        return combinedAttributedString
//    }
//
//    private func handleTap(in geometry: GeometryProxy) {
//        for attribute in attributes where attribute.onTap != nil {
//            // Реализация проверки, попал ли тап в область текста, требует сложной логики
//            // Например, использование TextRenderer или других инструментов для определения области
//            attribute.onTap?()
//        }
//    }
//}
//
//
