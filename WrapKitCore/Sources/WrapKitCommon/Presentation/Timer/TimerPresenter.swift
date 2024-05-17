//
//  TimerPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/5/24.
//

import Foundation

public protocol TimerOutput: AnyObject {
    func display(secondsRemaining: Int?)
}

public protocol TimerInput: WillEnterForegoundInput, DidEnterBacgkroundInput {
    func start(seconds: Int)
    func stop()
}

public class TimerPresenter: TimerInput {
    private var timer: DispatchSourceTimer?
    private var secondsRemained: Int?
    private var backgroundStartTime: Date?
    public weak var view: TimerOutput?
    
    public func start(seconds: Int) {
        stop()
        
        secondsRemained = seconds
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.secondsRemained = (self.secondsRemained ?? 1) - 1
            if self.secondsRemained ?? 0 <= 0 {
                self.stop()
                self.view?.display(secondsRemaining: nil)
            } else {
                self.view?.display(secondsRemaining: self.secondsRemained)
            }
        }
        timer?.resume()
    }
    
    public func stop() {
        timer?.cancel()
        timer = nil
    }
    
    public func didEnterBackground() {
        backgroundStartTime = Date()
        stop()
    }
    
    public func willEnterForeground() {
        guard let backgroundStartTime = backgroundStartTime else { return }
        let timeSpentInBackground = Int(Date().timeIntervalSince(backgroundStartTime))
        secondsRemained = (secondsRemained ?? 0) - timeSpentInBackground
        if secondsRemained ?? 0 <= 0 {
            stop()
            view?.display(secondsRemaining: nil)
        } else {
            view?.display(secondsRemaining: secondsRemained)
            start(seconds: secondsRemained ?? 0)
        }
    }
}

extension Int {
    func asSecondsToTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if self >= 3600 {
            formatter.allowedUnits = [
                .hour,
                .minute,
                .second
            ]
        } else {
            formatter.allowedUnits = [
                .minute,
                .second
            ]
        }
        
        return formatter.string(from: TimeInterval(self)) ?? "more than a day"
    }
}
