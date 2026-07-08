//
//  SUIShimmerView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 21/4/26.
//

import SwiftUI

public struct SUIShimmerView: View {
    let style: ShimmerStyle?
    
    @State private var isAnimating = false
    
    public init(style: ShimmerStyle? = nil) {
        self.style = style
    }
    
    public var body: some View {
        let colorOne = style.map { SwiftUIColor($0.gradientColorOne) } ?? SwiftUIColor(.clear)
        let colorTwo = style.map { SwiftUIColor($0.gradientColorTwo) } ?? SwiftUIColor(UIColor(white: 0.95, alpha: 0.6))
        let cornerRadius = style?.cornerRadius ?? 0
        let backgroundColor = style.map { SwiftUIColor($0.backgroundColor) } ?? SwiftUIColor(.clear)
        
        ZStack {
            backgroundColor
            
            LinearGradient(
                colors: [colorOne, colorTwo, colorOne],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? 400 : -400)
            .animation(
                SwiftUI.Animation.linear(duration: 1.4)
                    .delay(0)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
        }
        .cornerRadius(cornerRadius)
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }
}
