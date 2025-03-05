//
//  SplashContentView.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/2/25.
//

import SwiftUI
import WrapKit

public struct SplashContentView: View {
    private let lifeCycleInput: LifeCycleViewOutput?
    private let ApplicationLifecycleOutput: ApplicationLifecycleOutput?

    public init(
        lifeCycleInput: LifeCycleViewOutput? = nil,
        ApplicationLifecycleOutput: ApplicationLifecycleOutput? = nil
    ) {
        self.lifeCycleInput = lifeCycleInput
        self.ApplicationLifecycleOutput = ApplicationLifecycleOutput
    }

    public var body: some View {
        LifeCycleView(
            lifeCycleInput: lifeCycleInput,
            applicationLifecycleOutput: ApplicationLifecycleOutput
        ) {
            ZStack {
                Color.red.ignoresSafeArea()
                Text("Splash Screen")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
    }
}

struct SplashContentView_Previews: PreviewProvider {
    static var previews: some View {
        SplashContentView()
    }
}
