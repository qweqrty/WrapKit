//
//  SUICircularProgressView.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 6/11/25.
//

#if canImport(SwiftUI)
import SwiftUI

struct SUICircularProgressView: View {
    @State private var animationProgress: CGFloat = 0
    
    private let color: Color
    private let lineWidth: CGFloat
    private let animationStart: CGFloat
    private let animationEnd: CGFloat
    private let animationDuration: TimeInterval
    private let completion: (() -> Void)?
    
    init(
        color: Color,
        lineWidth: CGFloat = 2,
        from: CGFloat,
        to: CGFloat,
        duration: TimeInterval,
        completion: (() -> Void)?
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.animationStart = from
        self.animationEnd = to
        self.animationProgress = from
        self.animationDuration = duration
        self.completion = completion
    }
    
    public let startAngle: Angle = .degrees(90) // 6 o`clock counterside
    
    var body: some View {
        Circle()
            .trim(from: min(animationEnd, animationStart), to: animationProgress)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .foregroundColor(SwiftUIColor(color))
            .rotationEffect(startAngle)
            .padding(lineWidth/2)
            .onAppear {
                withAnimationCompletion(.linear(duration: animationDuration), duration: animationDuration) {
                    animationProgress = animationEnd
                } completion: {
                    completion?()
                }
            }
    }
}

@available(iOS 17.0, *)
#Preview {
    VStack {
        SUICircularProgressView(color: .red, from: 1, to: 0, duration: 2) {
            print("Animation finished")
        }
        SUICircularProgressView(color: .red, from: 0, to: 1, duration: 2) {
            print("Animation finished")
        }
    }.padding(32)
}

#endif
