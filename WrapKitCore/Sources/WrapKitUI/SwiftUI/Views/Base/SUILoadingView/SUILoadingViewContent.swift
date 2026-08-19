//
//  SUILoadingViewContent.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 16/4/26.
//

import SwiftUI

public struct SUILoadingViewContent: View {
    let color: SwiftUIColor
    let size: CGSize
    
    @State private var isAnimating = false
    
    public var body: some View {
        Circle()
            .trim(from: 0.1, to: 0.9)
            .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
            .onDisappear { isAnimating = false }
    }
}
