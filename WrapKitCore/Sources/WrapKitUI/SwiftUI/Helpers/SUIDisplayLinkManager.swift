//
//  SUIDisplayLinkManager.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 10/11/25.
//

#if canImport(SwiftUI)
import SwiftUI

@MainActor
final class SUIDisplayLinkManager: ObservableObject {
    private let manager = DisplayLinkManager()

    @Published var progress: Double = .zero

    func startAnimation(duration: TimeInterval = 0) {
        manager.startAnimation(duration: duration) { [weak self] progress in
            self?.progress = progress
        }
    }

    func stopAnimation() {
        manager.stopAnimation()
    }
    
    deinit {
        manager.stopAnimation()
    }
}

#endif

#if canImport(QuartzCore)
import QuartzCore

final class DisplayLinkManager {
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval = .zero
    private var animationDuration: TimeInterval = .zero
    
    private var onUpdateProgress: ((Double) -> Void)?

    func startAnimation(duration: TimeInterval = 0, onUpdateProgress: ((Double) -> Void)? = nil) {
        self.animationDuration = duration
        self.onUpdateProgress = onUpdateProgress
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }

    @objc private func updateAnimation(displayLink: CADisplayLink) {
        let elapsedTime = CACurrentMediaTime() - startTime
        if elapsedTime < animationDuration {
            onUpdateProgress?(min(1.0, elapsedTime / animationDuration))
        } else {
            onUpdateProgress?(1.0)
            stopAnimation()
        }
    }

    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = .zero
        animationDuration = .zero
    }
    
    deinit {
        displayLink?.invalidate()
        displayLink = nil
    }
}

#endif
