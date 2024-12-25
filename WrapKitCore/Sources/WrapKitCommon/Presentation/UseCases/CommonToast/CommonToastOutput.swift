//
//  CommonToastOutput.swift
//  WrapKit
//
//  Created by Stanislav Li on 27/5/24.
//

import Foundation

public protocol CommonToastOutput: AnyObject {
    func display(_ toast: CommonToast)
}

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
        public let cardViewModel: CardViewPresentableModel
        public let position: Position
        public let shadowColor: Color?
        public let duration: TimeInterval?
        public let onPress: (() -> Void)?
        
        public init(
            keyTitle: String,
            valueTitle: String? = nil,
            position: Position,
            shadowColor: Color? = nil,
            duration: TimeInterval? = 3.0,
            onPress: (() -> Void)? = nil
        ) {
            self.cardViewModel = .init(
                title: [.init(text: keyTitle)],
                valueTitle: valueTitle == nil ? [] : [.init(text: valueTitle ?? "")]
            )
            self.position = position
            self.shadowColor = shadowColor
            self.duration = duration
            self.onPress = onPress
        }
        
        public init(
            cardViewModel: CardViewPresentableModel,
            position: Position,
            shadowColor: Color? = nil,
            duration: TimeInterval? = 3.0,
            onPress: (() -> Void)? = nil
        ) {
            self.cardViewModel = cardViewModel
            self.position = position
            self.shadowColor = shadowColor
            self.duration = duration
            self.onPress = onPress
        }
    }
    
    public struct CustomToast {
        public struct Button {
            public let title: String
            public let onPress: (() -> Void)?
            
            public init(title: String, onPress: (() -> Void)? = nil) {
                self.title = title
                self.onPress = onPress
            }
        }
        
        public let common: Toast
        public let image: ImageEnum?
        public let backgroundColor: Color?
        public let buttons: [Button]?
        
        public init(
            common: Toast,
            image: ImageEnum? = nil,
            backgroundColor: Color? = nil,
            buttons: [Button]? = nil
        ) {
            self.common = common
            self.backgroundColor = backgroundColor
            self.buttons = buttons
            self.image = image
        }
    }
    
    case error(Toast)
    case success(Toast)
    case warning(Toast)
    case custom(CustomToast)
    
    public var duration: TimeInterval? {
        switch self {
        case .error(let toast), .success(let toast), .warning(let toast):
            return toast.duration
        case .custom(let toast):
            return toast.common.duration
        }
    }
}
