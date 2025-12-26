//
//  Text+Ext.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 27/10/25.
//

import SwiftUI

public extension Text {
    func textColor(_ color: SwiftUIColor) -> Self {
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            foregroundStyle(color)
        } else {
            foregroundColor(color)
        }
    }
}
