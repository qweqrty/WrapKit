//
//  BundleToken.swift
//  WrapKit
//
//  Created by Stanislav Li on 3/7/24.
//

import Foundation

public final class BundleToken {
    static let bundle: Bundle = {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(for: BundleToken.self)
#endif
    }()
}
