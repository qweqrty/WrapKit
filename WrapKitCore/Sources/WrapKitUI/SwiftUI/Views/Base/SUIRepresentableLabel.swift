//
//  SUIRepresentableLabel.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 6/11/25.
//

#if canImport(UIKit) && canImport(SwiftUI)
import UIKit
import SwiftUI

/// UIViewRepresentable by reusing Label.swift
public struct SUIRepresentableLabel: UIViewRepresentable {
    
    @ObservedObject var stateModel: SUILabelStateModel

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }
    
    init(model: TextOutputPresentableModel) {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.displayModelState = .init(model: model)
        self.stateModel = .init(adapter: adapter)
    }

    public func makeUIView(context: Context) -> Label {
        let label = Label()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        context.coordinator.label = label
        return label
    }

    public func updateUIView(_ uiView: Label, context: Context) {
        switch stateModel.presentable.model {
        case .text(let string):
            uiView.display(text: string)
        case .attributes(let array):
            uiView.display(attributes: array)
        case .animated(let id, let from, let to, let mapToString, let animationStyle, let duration, let completion):
            uiView.display(id: id, from: from, to: to, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        case .textStyled(let text, let cornerStyle, let insets, let height, let backgroundColor):
            uiView.display(model: .textStyled(text: text, cornerStyle: cornerStyle, insets: insets, height: height, backgroundColor: backgroundColor))
        case .animatedDecimal(id: let id, from: let from, to: let to, mapToString: let mapToString, animationStyle: let animationStyle, duration: let duration, completion: let completion):
            uiView.display(id: id, from: from, to: to, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        case .attributedString(_, _, _):
            // MARK: - TODO
            break
        default:
            break
        }
    }
    
//    public func makeCoordinator() -> Coordinator { Coordinator() }
//    public class Coordinator { }
}

#Preview {
    ScrollView(.vertical) {
        VStack(alignment: .leading) {
            SUIRepresentableLabel(
                model: .text("Hello, World!")
            )
            
            SUIRepresentableLabel(
                model: .animated(
                    1.2, 225,
                    mapToString: { .text($0.asString()) },
                    animationStyle: .circle(lineColor: .red),
                    duration: 5,
                    completion: { print("completed") }
                )
            )
            .frame(height: 100)
            
            SUIRepresentableLabel(
                model: .textStyled(
                    text: .text("some text"), cornerStyle: .automatic,
                    insets: .init(all: 8)
                )
            )
            
            SUIRepresentableLabel(
                model: .textStyled(
                    text: .attributes([.init(text: "cornerStyle: .automatic", color: .gray)]),
                    cornerStyle: .automatic,
                    insets: .init(all: 8),
                    backgroundColor: .blue
                )
            )
            
            SUIRepresentableLabel(model: .attributes(
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
            
            SUIRepresentableLabel (model: .textStyled(
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


#endif
