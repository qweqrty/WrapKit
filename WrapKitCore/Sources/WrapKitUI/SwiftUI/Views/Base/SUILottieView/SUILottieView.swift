//
//  SUILottieView.swift
//  WrapKit
//

#if canImport(SwiftUI)
import Lottie
import SwiftUI

public struct SUILottieView: View {
    @StateObject private var stateModel: SUILottieViewStateModel

    public init(adapter: LottieViewOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adapter))
    }

    public var body: some View {
        Group {
            if let animation = stateModel.animation {
                Lottie.LottieView(animation: animation)
                    .resizable()
                    .playing(loopMode: stateModel.loopMode)
                    .animationSpeed(stateModel.animationSpeed)
                    .id(stateModel.reloadToken)
            }
        }
        .accessibilityHidden(true)
    }
}
#endif
