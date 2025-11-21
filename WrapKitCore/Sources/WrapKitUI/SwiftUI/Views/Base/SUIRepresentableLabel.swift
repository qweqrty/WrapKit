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

    public func makeUIView(context: Context) -> Label {
        let label = Label()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        context.coordinator.label = label
        return label
    }

    public func updateUIView(_ uiView: Label, context: Context) {
        switch stateModel.presentable {
        case .text(let string):
            uiView.display(text: string)
        case .attributes(let array):
            uiView.display(attributes: array)
        case .animated(let from, let to, let mapToString, let animationStyle, let duration, let completion):
            uiView.display(from: from, to: to, mapToString: mapToString, animationStyle: animationStyle, duration: duration, completion: completion)
        case .textStyled(let text, let cornerStyle, let insets, let height, let backgroundColor):
            uiView.display(model: .textStyled(text: text, cornerStyle: cornerStyle, insets: insets, height: height, backgroundColor: backgroundColor))
        }
    }
    
//    public func makeCoordinator() -> Coordinator { Coordinator() }
//    public class Coordinator { }
}

#endif
