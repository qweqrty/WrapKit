//
//  View+iOS15.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 6/11/25.
//

#if canImport(SwiftUI)
import SwiftUI

extension View {
    @ViewBuilder
    func overlayView<V: View>(view: () -> V) -> some View {
        if #available(iOS 15.0, *) {
            self.overlay { view() }
        } else {
            self.overlay(view())
        }
    }
    
    @ViewBuilder
    func backgroundView<V: View>(view: () -> V) -> some View {
        if #available(iOS 15.0, *) {
            self.background { view() }
        } else {
            self.background(view())
        }
    }
}

#endif
