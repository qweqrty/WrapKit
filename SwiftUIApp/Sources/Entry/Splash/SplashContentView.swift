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
    @StateObject private var navigationBarAdapter = HeaderOutputSwiftUIAdapter()
    @State private var splashTitle = "Splash"
    
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
                    SUINavigationBar(adapter: navigationBarAdapter)
                        .frame(height: 56)

                    ZStack {
                        Color.red.ignoresSafeArea()
                        Text(splashTitle)
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
            .onAppear {
                configureNavigationBarIfNeeded()
            }
        }
    }

    private func configureNavigationBarIfNeeded() {
        guard navigationBarAdapter.displayModelState == nil else { return }

        navigationBarAdapter.display(
            model: HeaderPresentableModel(
                style: .init(
                    backgroundColor: .lightGray,
                    horizontalSpacing: 8,
                    primeFont: .boldSystemFont(ofSize: 24),
                    primeColor: .white,
                    secondaryFont: .systemFont(ofSize: 14),
                    secondaryColor: .white.withAlphaComponent(0.85)
                ),
                centerView: .keyValue(.init(.text("Splash preview"), nil)),
                leadingCard: .init(
                    title: .text("Back"),
                    onPress: {
                        splashTitle = "Leading card tapped"
                    }
                ),
                primeTrailingImage: .init(
                    image: ImageFactory.systemImage(named: "bell.fill"),
                    onPress: {
                        splashTitle = "Prime trailing image tapped"
                    }
                ),
                secondaryTrailingImage: .init(
                    image: ImageFactory.systemImage(named: "gearshape.fill"),
                    onPress: {
                        splashTitle = "Secondary trailing image tapped"
                    }
                )
            )
        )
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
