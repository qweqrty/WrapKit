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

    @Published var progress: Decimal = .zero

    func startAnimation(duration: TimeInterval = 0, completion: (() -> Void)? = nil) {
        guard duration > 0 else {
            progress = 1
            completion?()
            return
        }
//        guard progress == 0 || progress == 1 else { return }
        manager.startAnimation(
            duration: duration,
            onUpdateProgress: { [weak self] in self?.progress = $0 },
            completion: completion
        )
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
    private static var currentMediaTime: TimeInterval {
        #if os(watchOS)
        return ProcessInfo.processInfo.systemUptime
        #else
        return CACurrentMediaTime()
        #endif
    }

    #if os(macOS) || os(watchOS)
    private var timer: Timer?
    #else
    private var displayLink: CADisplayLink?
    #endif
    
    private var startTime: TimeInterval = .zero
    private var animationDuration: TimeInterval = .zero
    
    private var onUpdateProgress: ((Decimal) -> Void)?
    private var completion: (() -> Void)? = nil

    func startAnimation(
        duration: TimeInterval = 0,
        onUpdateProgress: ((Decimal) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.animationDuration = duration
        self.onUpdateProgress = onUpdateProgress
        self.completion = completion
        
        #if os(macOS) || os(watchOS)
        timer?.invalidate()
        startTime = Self.currentMediaTime
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        #else
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
        startTime = Self.currentMediaTime
        #endif
    }
    
    #if os(macOS) || os(watchOS)
    private func tick() {
        let elapsedTime = Self.currentMediaTime - startTime
        if elapsedTime < animationDuration {
            onUpdateProgress?(Decimal(min(1.0, elapsedTime / animationDuration)))
        } else {
            onUpdateProgress?(1.0)
            completion?()
            stopAnimation()
        }
    }
    #else
    @objc private func updateAnimation(displayLink: CADisplayLink) {
        let elapsedTime = Self.currentMediaTime - startTime
        if elapsedTime < animationDuration {
            onUpdateProgress?(Decimal(min(1.0, elapsedTime / animationDuration)))
        } else {
            onUpdateProgress?(1.0)
            completion?()
            stopAnimation()
        }
    }
    #endif

    func stopAnimation() {
    #if os(macOS) || os(watchOS)
        timer?.invalidate()
        timer = nil
    #else
        displayLink?.invalidate()
        displayLink = nil
    #endif
        startTime = .zero
        animationDuration = .zero
    }
        
    
    deinit {
    #if os(macOS) || os(watchOS)
        timer?.invalidate()
    #else
        displayLink?.invalidate()
        displayLink = nil
    #endif
    }
}

#endif
