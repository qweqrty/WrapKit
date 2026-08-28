//
//  TooltipView.swift
//  WrapKit
//
//  Created by Stanislav Li on 21/4/26.
//

import Foundation

public protocol TooltipViewOutput: AnyObject {
    func display(tooltipModel: TooltipViewPresentableModel?)
}

public struct TooltipViewPresentableModel {
    public enum Trigger: HashableWithReflection {
        case immediate(anchorPoint: CGPoint? = nil)
        case tap
        case longPress(minimumPressDuration: TimeInterval = 0.5)
    }

    public struct Item {
        public let title: String
        public let onTap: () -> Void

        public init(title: String, onTap: @escaping () -> Void) {
            self.title = title
            self.onTap = onTap
        }
    }

    public let items: [Item]
    public let trigger: Trigger
    public let onDismiss: (() -> Void)?

    public init(
        items: [Item],
        trigger: Trigger = .longPress(),
        onDismiss: (() -> Void)? = nil
    ) {
        self.items = items
        self.trigger = trigger
        self.onDismiss = onDismiss
    }
}
