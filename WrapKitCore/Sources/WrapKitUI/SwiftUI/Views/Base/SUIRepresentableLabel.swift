//
//  SUIRepresentableLabel.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 6/11/25.
//

#if canImport(SwiftUI)
import SwiftUI

/// Compatibility wrapper that keeps the original public name while using the native SwiftUI
/// label implementation on every supported platform.
public struct SUIRepresentableLabel: View {
    private let adapter: TextOutputSwiftUIAdapter

    public init(adapter: TextOutputSwiftUIAdapter) {
        self.adapter = adapter
    }

    init(model: TextOutputPresentableModel) {
        let adapter = TextOutputSwiftUIAdapter()
        adapter.display(model: model)
        self.adapter = adapter
    }

    public var body: some View {
        SUILabel(adapter: adapter)
    }
}
#endif
