//
//  Accessibility.swift
//  WrapKit
//
//  Created by Stanislav Li on 20/1/26.
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

#if canImport(UIKit)
import UIKit

final class A11yProxy: UIAccessibilityElement {
    var activate: (() -> Void)?

    override func accessibilityActivate() -> Bool {
        activate?()
        return true
    }
}

public extension UIView {
    func accessibilityTextSummary() -> String? {
        guard UIAccessibility.isVoiceOverRunning else { return nil }
        var parts: [String] = []
        var seen = Set<String>()

        func add(_ raw: String?) {
            guard var t = raw?.trimmingCharacters(in: .newlines), !t.isEmpty else { return }
            t = t.replacingOccurrences(of: "\n", with: ", ")
                .replacingOccurrences(of: "\t", with: " ")
            t = t.replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .newlines)

            guard !t.isEmpty else { return }
            // dedupe
            if seen.insert(t).inserted {
                parts.append(t)
            }
        }

        func dfs(_ v: UIView) {
            guard !v.isHidden, v.alpha > 0.01 else { return }

            if v.isAccessibilityElement {
                add(v.accessibilityLabel)
            } else {
                if let label = v as? UILabel {
                    add(label.text)
                } else if let tv = v as? UITextView {
                    add(tv.text)
                } else if let tv = v as? UIImageView {
                    add(tv.accessibilityLabel ?? tv.image?.accessibilityLabel ?? tv.image?.accessibilityIdentifier)
                }
            }

            v.subviews.forEach(dfs)
        }

        dfs(self)

        let summary = parts
            .joined(separator: ", ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return summary.isEmpty ? nil : summary
    }
}

private extension Array where Element == UIAccessibilityCustomAction {
    func uniquedByName() -> [UIAccessibilityCustomAction] {
        var seen = Set<String>()
        var res: [UIAccessibilityCustomAction] = []
        for a in self {
            if seen.insert(a.name).inserted {
                res.append(a)
            }
        }
        return res
    }
}

#endif
