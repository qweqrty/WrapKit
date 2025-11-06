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

#endif
