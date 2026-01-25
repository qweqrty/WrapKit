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
