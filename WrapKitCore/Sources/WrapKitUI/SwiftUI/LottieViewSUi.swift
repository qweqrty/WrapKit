//
//  LottieSwiftUI.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import Lottie

public struct LottieViewPresentableModel: HashableWithReflection {
    public let fileName: String
    public let animationSpeed: CGFloat
    public let loopMode: LottieLoopMode
    public let bundle: Bundle
    public let url: URL?
    
    public init(fileName: String, animationSpeed: CGFloat = 1.2, loopMode: LottieLoopMode, bundle: Bundle) {
        self.fileName = fileName
        self.bundle = bundle
        self.animationSpeed = animationSpeed
        self.loopMode = loopMode
        self.url = nil
    }

    public init(url: URL, animationSpeed: CGFloat = 1.2, loopMode: LottieLoopMode) {
        self.fileName = url.absoluteString
        self.bundle = .main
        self.animationSpeed = animationSpeed
        self.loopMode = loopMode
        self.url = url
    }
}

public protocol LottieViewOutput: AnyObject {
    var currentAnimationName: String? { get set }
    func display(model: LottieViewPresentableModel)
}
