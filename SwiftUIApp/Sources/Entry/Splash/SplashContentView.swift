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
            ScrollView(.vertical) {
                SUILabel(adapter: adapter)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color.red.ignoresSafeArea().opacity(0.2)
            )
        }
    }
}

#Preview("SwiftUI") {
    EntryViewSwiftUIFactory().makeSplashScreen()
}

#if canImport(UIKit)
@available(iOS 17, *)
#Preview("UIKit") {
    let label = Label()
    label.backgroundColor = .red.withAlphaComponent(0.2)
    let presenter = SplashPresenter()
    presenter.textOutput = label
    let viewController = ViewController(
        contentView: label,
        lifeCycleViewOutput: presenter,
        applicationLifecycleOutput: presenter
    )
    return viewController
}
#elseif canImport(AppKit)

#endif
