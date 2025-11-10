//
//  View+CornerStyle.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 5/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func cornerStyle(_ style: CornerStyle) -> some View {
        switch style {
        case .automatic:
            self.clipShape(.capsule)
        case .fixed(let size):
            self.clipShape(.rect(cornerRadius: size))
        default:
            self
        }
    }
}
