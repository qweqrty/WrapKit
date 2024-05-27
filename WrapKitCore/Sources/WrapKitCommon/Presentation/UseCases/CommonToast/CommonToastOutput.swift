//
//  CommonToastOutput.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

import Foundation

public enum CommmonToast {
    public struct Toast {
        public let title: String
        public let subtitle: String?
        public let duration: TimeInterval
        public let trailingView: (String, (() -> Void)?)?
        
        public init(title: String, subtitle: String? = nil, duration: TimeInterval = 3.0, trailingView: (String, (() -> Void)?)? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.duration = duration
            self.trailingView = trailingView
        }
    }
    case error(Toast)
    case success(Toast)
    case warning(Toast)
    
    public var duration: TimeInterval {
        switch self {
        case .error(let toast), .success(let toast), .warning(let toast):
            return toast.duration
        }
    }
}

public protocol CommonToastOutput: AnyObject {
    func display(_ toast: CommmonToast)
}
