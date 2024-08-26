//
//  CommonToastOutput.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

import Foundation

public enum CommonToast {
    public enum Position: Equatable {
        case top
        case bottom(additionalBottomPadding: CGFloat = 0)
        
        var spacing: CGFloat {
            switch self {
            case .top:
                return 0
            case .bottom(let bottomSpacing):
                return bottomSpacing
            }
        }
    }
    
    public struct Toast {
        public let keyTitle: String
        public let valueTitle: String?
        public let position: Position
        public let shadowColor: Color?
        public let backgroundColor: Color?
        public let textColor: Color?
        public let duration: TimeInterval
        public let onPress: (() -> Void)?
        
        public init(
            keyTitle: String,
            valueTitle: String? = nil,
            position: Position,
            shadowColor: Color? = nil,
            backgroundColor: Color?,
            textColor: Color?,
            duration: TimeInterval = 3.0,
            onPress: (() -> Void)? = nil
        ) {
            self.keyTitle = keyTitle
            self.valueTitle = valueTitle
            self.position = position
            self.shadowColor = shadowColor
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.duration = duration
            self.onPress = onPress
        }
    }
    
    public struct CustomToast {
        public let common: Toast
        public let leadingImage: ImageEnum?
        public let trailingTitle: String?
        
        public init(common: Toast, leadingImage: ImageEnum?, trailingTitle: String?) {
            self.common = common
            self.leadingImage = leadingImage
            self.trailingTitle = trailingTitle
        }
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
