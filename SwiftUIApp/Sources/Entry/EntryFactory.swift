//
//  EntryFactory.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @StateObject private var presenter = SplashPresenter()
    @State private var didSetupOutputs = false

    var body: some View {
        SplashContentView(
            lifeCycleOutput: presenter,
            applicationLifecycleOutput: presenter
        )
        .onAppear {
            guard !didSetupOutputs else { return }
            didSetupOutputs = true
        }
    }
}

enum EntryViewSwiftUIFactory {
    static func makeSplashScreen() -> SplashScreen {
        SplashScreen()
    }
}
