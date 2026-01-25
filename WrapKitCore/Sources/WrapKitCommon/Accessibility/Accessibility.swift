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
            // Пропускаем сам контейнер-элемент, если он already isAccessibilityElement (т.е. CardView)
            // но мы вызываем walk на контейнере, поэтому важно не зациклиться.
            if v !== self, v.isAccessibilityElement {

                // 1) если у элемента уже есть custom actions — берём их как есть
                if let actions = v.accessibilityCustomActions, !actions.isEmpty {
                    out.append(contentsOf: actions)
                }

                // 2) если это "активируемый" элемент и customActions пустые,
                // можно добавить action, который дернет accessibilityActivate()
                else if v.looksActivatable {
                    weak let weakView = v
                    let name = (v.accessibilityLabel?.trimmingCharacters(in: .newlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "Activate"
                    out.append(UIAccessibilityCustomAction(name: name, actionHandler: { _ in
                        guard let vv = weakView else { return false }
                        return vv.accessibilityActivate()
                    }))
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
