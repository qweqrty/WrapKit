//
//  SUIWrapperView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 15/4/26.
//

import SwiftUI

public struct SUIWrapperView<Content: View>: View {
    let content: Content
    let backgroundColor: SwiftUIColor
    let cornerRadius: CGFloat
    let isHidden: Bool
    let padding: EdgeInsets
    
    public init(
        backgroundColor: SwiftUIColor = .clear,
        cornerRadius: CGFloat = 0,
        isHidden: Bool = false,
        padding: EdgeInsets = .zero,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.isHidden = isHidden
        self.padding = padding
    }
    
    public var body: some View {
        if !isHidden {
            content
                .padding(padding.asSUIEdgeInsets)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
    }
}
