//
//  CommonToastOutput.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

import Foundation

public enum CommonToast {
    public struct Toast {
        public let title: String
        public let subtitle: String?
        public let duration: TimeInterval
        public let onPress: (() -> Void)?
        
        public init(
            title: String,
            subtitle: String? = nil,
            duration: TimeInterval = 3.0,
            onPress: (() -> Void)? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.duration = duration
            self.onPress = onPress
        }
    }
    
    public struct CustomToast {
        let common: Toast
        let leadingImage: Image
        let trailingImage: Image
        let trailingTitle: String?
    }
    
    case error(Toast)
    case success(Toast)
    case warning(Toast)
    case custom(CustomToast)
    
    public var duration: TimeInterval {
        switch self {
        case .error(let toast), .success(let toast), .warning(let toast):
            return toast.duration
        case .custom(let toast):
            return toast.common.duration
        }
    }
}

public protocol CommonToastOutput: AnyObject {
    func display(_ toast: CommonToast)
}
