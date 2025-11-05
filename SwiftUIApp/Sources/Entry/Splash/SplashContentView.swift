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
    private let applicationLifecycleOutput: ApplicationLifecycleOutput?
    public let adapter = TextOutputSwiftUIAdapter()

    public init(
        lifeCycleOutput: LifeCycleViewOutput? = nil,
        applicationLifecycleOutput: ApplicationLifecycleOutput? = nil
    ) {
        self.lifeCycleOutput = lifeCycleOutput
        self.applicationLifecycleOutput = applicationLifecycleOutput
    }

    public var body: some View {
        LifeCycleView(
            lifeCycleOutput: lifeCycleOutput,
            applicationLifecycleOutput: applicationLifecycleOutput
        ) {
            ZStack {
                Color.red.ignoresSafeArea()

                VStack {
                    ZStack {
                        Color.red.ignoresSafeArea()
//                        SUILabel(adapter: textOutputAdapter)
//                                             .frame(maxWidth: .infinity, alignment: .leading)
//                                             .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Color.white
                        SUIImageView(adapter: imageViewAdapter)
                    }
                   
                    SUILabel(adapter: adapter)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.horizontal)

                    Spacer()
                }
            }
        }
    }
}
