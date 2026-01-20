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
