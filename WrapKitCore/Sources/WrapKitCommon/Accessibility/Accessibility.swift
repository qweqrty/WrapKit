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
    func collectAccessibilityActionsForContainer() -> [UIAccessibilityCustomAction] {
        var out: [UIAccessibilityCustomAction] = []

        func walk(_ v: UIView) {
            if v !== self, v.isAccessibilityElement {
                if let actions = v.accessibilityCustomActions, !actions.isEmpty {
                    out.append(contentsOf: actions)
                }

                else if v.looksActivatable {
                    weak let weakView = v
                    let name = (v.accessibilityLabel?.trimmingCharacters(in: .newlines)).flatMap { $0.isEmpty ? nil : $0 }
                    if let name, !name.isEmpty {
                        out.append(UIAccessibilityCustomAction(name: name, actionHandler: { _ in
                            guard let vv = weakView else { return false }
                            return vv.accessibilityActivate()
                        }))
                    }
                }
            }

            for s in v.subviews {
                walk(s)
            }
        }

        walk(self)
        return out.uniquedByName()
    }
    
    func accessibilityTextSummary() -> String? {
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


    func containsInteractiveAccessibleDescendant() -> Bool {
        func dfs(_ v: UIView) -> Bool {
            guard !v.isHidden, v.alpha > 0.01 else { return false }

            if v.isAccessibilityElement {
                let t = v.accessibilityTraits
                if t.contains(.button) || t.contains(.link) || t.contains(.adjustable) || t.contains(.selected) {
                    return true
                }
            }

            for s in v.subviews {
                if dfs(s) { return true }
            }
            return false
        }
        return dfs(self)
    }

    var looksActivatable: Bool {
        let t = accessibilityTraits
        return t.contains(.button) || t.contains(.link)
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
