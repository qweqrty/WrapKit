//
//  SplashContentView.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/2/25.
//

import SwiftUI
import WrapKit

public struct SplashContentView: View {
    private let lifeCycleOutput: LifeCycleViewOutput?
    private let ApplicationLifecycleOutput: ApplicationLifecycleOutput?
    private let adapter: TextOutputSwiftUIAdapter

    public init(
        lifeCycleOutput: LifeCycleViewOutput? = nil,
        ApplicationLifecycleOutput: ApplicationLifecycleOutput? = nil,
        adapter: TextOutputSwiftUIAdapter
    ) {
        self.lifeCycleOutput = lifeCycleOutput
        self.ApplicationLifecycleOutput = ApplicationLifecycleOutput
        self.adapter = adapter
    }

    public var body: some View {
        LifeCycleView(
            lifeCycleOutput: lifeCycleOutput,
            applicationLifecycleOutput: ApplicationLifecycleOutput
        ) {
            ZStack {
                Color.red.ignoresSafeArea()
                SUILabel(adapter: adapter)
                    .padding()
                Spacer()
            }
        }
    }
}
