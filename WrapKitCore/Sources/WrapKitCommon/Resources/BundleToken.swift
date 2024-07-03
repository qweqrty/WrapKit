//
//  BundleToken.swift
//  WrapKit
//
//  Created by Stanislav Li on 3/7/24.
//

import Foundation

public final class BundleToken {
    public static let bundle: Bundle = {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        // Search for the bundle in the main bundle or among other known bundles
        let candidates = [
            Bundle(for: BundleToken.self),
            Bundle.main,
        ]

        for candidate in candidates {
            if let bundlePath = candidate.path(forResource: "WrapKit_WrapKit", ofType: "bundle"),
               let bundle = Bundle(path: bundlePath) {
                return bundle
            }
        }

        return Bundle(for: BundleToken.self)
#endif
    }()
}
