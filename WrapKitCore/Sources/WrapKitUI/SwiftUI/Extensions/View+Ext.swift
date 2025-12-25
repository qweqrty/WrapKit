//
//  View+Ext.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 10/11/25.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

extension View {
//    @ViewBuilder
    func withAnimationCompletion<Result>(
        _ animation: Animation? = .default,
        duration: TimeInterval = 0.3,
        _ body: () -> Result,
        completion: @escaping () -> Void
    ) -> Result {
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            return withAnimation(animation, body, completion: completion)
        } else {
            let view = withAnimation(animation, body)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                completion()
            }
            return view
        }
    }
}
