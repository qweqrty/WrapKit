//
//  Accessibility.swift
//  WrapKit
//
//  Created by Stanislav Li on 15/1/26.
//

import Foundation

public struct Accessibility: HashableWithReflection {
    public let label: String?
    public let hint: String?

    public init(label: String? = nil, hint: String? = nil) {
        self.label = label
        self.hint = hint
    }
}

extension TextOutputPresentableModel {
    func plainTextFallback() -> String? {
        switch self {
        case .text(let s):
            return s?.trimmingCharacters(in: .whitespacesAndNewlines)

        case .attributes(let attrs):
            let s = attrs.map(\.text).joined()
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed

        case .textStyled(let text, _, _, _, _):
            return text.plainTextFallback()

        default:
            return nil
        }
    }
}

extension CardViewPresentableModel {
    func autoAccessibilityLabel() -> String? {
        var parts: [String] = []

        func add(_ t: TextOutputPresentableModel?) {
            if let s = t?.plainTextFallback(), !s.isEmpty { parts.append(s) }
        }

        add(leadingTitles?.first)
        add(leadingTitles?.second)
        add(title)
        add(valueTitle)
        add(subTitle)
        add(trailingTitles?.first)
        add(trailingTitles?.second)

        let joined = parts.joined(separator: ", ")
        return joined.isEmpty ? nil : joined
    }
}


#if canImport(UIKit)
import UIKit

extension UIView {
    /// Returns true if there is any descendant that would be an interactive accessibility element.
    /// We treat UIControl and any view with gesture recognizers as "interactive".
    func containsInteractiveDescendant(excluding excluded: UIView? = nil) -> Bool {
        var stack: [UIView] = [self]

        while let v = stack.popLast() {
            for child in v.subviews {
                if child === excluded { continue }

                // UIControls are interactive by definition (UIButton, UISwitch, etc.)
                if child is UIControl { return true }

                // Gesture recognizers usually mean tappable
                if let gr = child.gestureRecognizers, !gr.isEmpty { return true }

                // Also consider your own convention: if a view is an accessibility element and is a button.
                if child.isAccessibilityElement,
                   child.accessibilityTraits.contains(.button) {
                    return true
                }

                stack.append(child)
            }
        }
        return false
    }
}
#endif
