//
//  TimerPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/5/24.
//

import Foundation

public protocol TimerOutput: AnyObject {
    func display(timerInput: TimerInput, secondsRemaining: Int?)
}

public protocol TimerInput: ApplicationLifecycleInput {
    func start(seconds: Int)
    func stop()
}

public class TimerPresenter: TimerInput {
    private var timer: DispatchSourceTimer?
    private var secondsRemained: Int?
    private var backgroundStartTime: Date?
    public weak var view: TimerOutput?
    
    public init(timer: DispatchSourceTimer? = nil, secondsRemained: Int? = nil, backgroundStartTime: Date? = nil, view: TimerOutput? = nil) {
        self.timer = timer
        self.secondsRemained = secondsRemained
        self.backgroundStartTime = backgroundStartTime
        self.view = view
    }
    
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
                self.view?.display(timerInput: self, secondsRemaining: nil)
            } else {
                self.view?.display(timerInput: self, secondsRemaining: self.secondsRemained)
            }
        }
        timer?.resume()
    }
    
    public func stop() {
        timer?.cancel()
        timer = nil
    }
    
    public func applicationWillEnterForeground(){
        guard let backgroundStartTime = backgroundStartTime else { return }
        let timeSpentInBackground = Int(Date().timeIntervalSince(backgroundStartTime))
        secondsRemained = (secondsRemained ?? 0) - timeSpentInBackground
        if secondsRemained ?? 0 <= 0 {
            stop()
            view?.display(timerInput: self, secondsRemaining: nil)
        } else {
            view?.display(timerInput: self, secondsRemaining: secondsRemained)
            start(seconds: secondsRemained ?? 0)
        }
    }
    
    public func applicationDidEnterBackground() {
        backgroundStartTime = Date()
        stop()
    }
}
