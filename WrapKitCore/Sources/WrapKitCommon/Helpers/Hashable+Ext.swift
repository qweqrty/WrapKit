//
//  Hashable+extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 19/5/24.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public protocol HashableWithReflection: Hashable {}

public extension HashableWithReflection {

    // MARK: - Helpers

    private func enumCaseName(_ value: Any) -> String {
        // "asset(Optional(<UIImage:0x...>))" -> "asset"
        let full = String(describing: value)
        return full.split(separator: "(").first.map(String.init) ?? full
    }

    private func isReflectionHashable(_ value: Any) -> Bool {
        // Avoid recursion through AnyHashable for our own reflection-hashable models
        value is any HashableWithReflection
    }

    // MARK: - Recursive Hash

    private func hashAny(_ value: Any, into hasher: inout Hasher) {
        // 1) Platform images (must be before string fallback)
        #if canImport(UIKit)
        if let image = value as? UIImage {
            hasher.combine(image.size.width)
            hasher.combine(image.size.height)
            hasher.combine(image.renderingMode.rawValue)
            hasher.combine(image.accessibilityIdentifier ?? "")
            return
        }
        #endif

        #if canImport(AppKit)
        if let image = value as? NSImage {
            hasher.combine(image.size.width)
            hasher.combine(image.size.height)
            hasher.combine(image.isTemplate)
            return
        }
        #endif

        let mirror = Mirror(reflecting: value)

        // 2) Optional: hash nil vs some(value)
        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                hasher.combine(1)
                hashAny(child.value, into: &hasher)
            } else {
                hasher.combine(0)
            }
            return
        }

        // 3) Enum: hash case name + recursively hash payload
        if mirror.displayStyle == .enum {
            hasher.combine(enumCaseName(value))
            for child in mirror.children {
                hashAny(child.value, into: &hasher)
            }
            return
        }

        // 4) Fast path for normal Hashable values — BUT NOT for HashableWithReflection
        // (otherwise AnyHashable will call our hash(into:) again -> recursion)
        if let h = value as? AnyHashable, !isReflectionHashable(value) {
            hasher.combine(h)
            return
        }

        // 5) Struct/class: hash children recursively (include labels to reduce collisions)
        if !mirror.children.isEmpty {
            for child in mirror.children {
                hasher.combine(child.label ?? "")
                hashAny(child.value, into: &hasher)
            }
            return
        }

        // 6) Fallback
        hasher.combine(String(describing: value))
    }

    // MARK: - Recursive Equality

    private func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        // 1) Platform images
#if canImport(UIKit)
        if let li = lhs as? UIImage, let ri = rhs as? UIImage {
            return ((li.accessibilityIdentifier ?? "") == (ri.accessibilityIdentifier ?? "")
                    && li.size == ri.size
                    && li.renderingMode == ri.renderingMode) || (li.pngData() == ri.pngData())
        }
        if let li = lhs as? UIColor, let ri = rhs as? UIColor {
            return li.resolvedColor(with: .init(userInterfaceStyle: .light)) == ri.resolvedColor(with: .init(userInterfaceStyle: .light))
            && li.resolvedColor(with: .init(userInterfaceStyle: .dark)) == ri.resolvedColor(with: .init(userInterfaceStyle: .dark))
        }
        if let li = lhs as? UIFont, let ri = rhs as? UIFont {
            return li == ri // TODO: check HeaderViewStyle Tests, probably need to add check font details check
        }
#endif
        
#if canImport(AppKit)
        if let li = lhs as? NSImage, let ri = rhs as? NSImage {
            return (li.tiffRepresentation == ri.tiffRepresentation) || (li.size == ri.size && li.isTemplate == ri.isTemplate)
        }
        if let li = lhs as? NSColor, let ri = rhs as? NSColor {
            return li == ri
        }
#endif

        let lm = Mirror(reflecting: lhs)
        let rm = Mirror(reflecting: rhs)

        // 2) Optional
        if lm.displayStyle == .optional || rm.displayStyle == .optional {
            guard lm.displayStyle == .optional, rm.displayStyle == .optional else { return false }

            let lChild = lm.children.first
            let rChild = rm.children.first

            switch (lChild, rChild) {
            case (nil, nil):
                return true
            case (let l?, let r?):
                return areEqual(l.value, r.value)
            default:
                return false
            }
        }

        // 3) Enum: compare case name + compare payload recursively
        if lm.displayStyle == .enum || rm.displayStyle == .enum {
            guard lm.displayStyle == .enum, rm.displayStyle == .enum else { return false }
            guard enumCaseName(lhs) == enumCaseName(rhs) else { return false }

            let lChildren = Array(lm.children)
            let rChildren = Array(rm.children)
            guard lChildren.count == rChildren.count else { return false }

            for (l, r) in zip(lChildren, rChildren) {
                if !areEqual(l.value, r.value) { return false }
            }
            return true
        }

        // 4) Fast path for normal Hashable values — BUT NOT for HashableWithReflection
        // (otherwise AnyHashable equality will call our == again -> recursion)
        if let lh = lhs as? AnyHashable,
           let rh = rhs as? AnyHashable,
           !isReflectionHashable(lhs),
           !isReflectionHashable(rhs) {
            return lh == rh
        }

        // 5) Struct/class: compare children recursively
        if !lm.children.isEmpty || !rm.children.isEmpty {
            let lChildren = Array(lm.children)
            let rChildren = Array(rm.children)
            guard lChildren.count == rChildren.count else { return false }

            for (l, r) in zip(lChildren, rChildren) {
                if l.label != r.label { return false }
                if !areEqual(l.value, r.value) { return false }
            }
            return true
        }

        // 6) Fallback
        return String(describing: lhs) == String(describing: rhs)
    }

    // MARK: - HashableWithReflection

    func hash(into hasher: inout Hasher) {
        hashAny(self, into: &hasher)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.areEqual(lhs, rhs)
    }
}
