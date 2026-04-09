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
                        Text("Splash")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Color.white
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                    }
                }
            }
        }
    }
}

#Preview("SwiftUI") {
    SplashScreen()
}

#if canImport(UIKit)
@available(iOS 17, *)
#Preview("UIKit") {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .red.withAlphaComponent(0.2)
    let presenter = SplashPresenter()
    let viewController = ExampleViewController(
        contentView: scrollView,
        lifeCycleViewOutput: presenter,
        applicationLifecycleOutput: presenter
    )
    presenter.textOutput = viewController.label
    return viewController
}

private final class ExampleViewController: ViewController<UIScrollView> {
    let label = Label()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.backgroundColor = .blue.withAlphaComponent(0.2)
        contentView.addSubview(label)
        label.fillSuperviewSafeAreaLayoutGuide()
        label.anchor(.widthTo(contentView.widthAnchor))
        label.sizeToFit()
    }
}

#elseif canImport(AppKit)

#endif
