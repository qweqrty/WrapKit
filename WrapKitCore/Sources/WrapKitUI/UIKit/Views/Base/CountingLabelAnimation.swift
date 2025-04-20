//
//  CountingLabelAnimation.swift
//  WrapKit
//
//  Created by Бегайым Акунова on 17/4/25.
//

import Foundation
#if canImport(UIKit)
import UIKit

open class CountingLabelAnimation {
    private weak var label: UILabel?
    private var paymentFormat: String = ""
    
    public required init(label: UILabel) {
        self.label = label
    }
    public var floatLimit: Float? = nil
    
    var startNumber: Float? = 0.0
    var endNumber: Float? = 0.0
    var mapToString: ((Float) -> String)?
    let counterVelocity: Float = 5
    
    var progress: TimeInterval!
    var duration: TimeInterval = 1
    var lastUpdate: TimeInterval!
    
    var timer: Timer?
    
    func getCurrentCounterValue() -> String {
        let startNumber = startNumber ?? 0
        let endNumber = endNumber ?? 0
        if progress >= duration {
            return mapToString?(endNumber) ?? ""
        }
        let percentage = Float(progress / duration)
        let update = 1.0 - powf(1.0 - percentage, counterVelocity)
        
        return mapToString?(startNumber + (update * (endNumber - startNumber))) ?? ""
    }
    
    public func setupPaymentFormat(format: String) {
        paymentFormat = format
    }
    
    public func startAnimation(
        fromValue: Float,
        to toValue: Float,
        mapToString: ((Float) -> String)?
    ) {
        startNumber = fromValue
        endNumber = toValue
        self.mapToString = mapToString
        progress = 0
        lastUpdate = Date.timeIntervalSinceReferenceDate
    
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateValue),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress += (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration {
            timer?.invalidate()
            label?.text = getCurrentCounterValue()
            mapToString = nil
            return
        }
        
        label?.text = getCurrentCounterValue()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
#endif
