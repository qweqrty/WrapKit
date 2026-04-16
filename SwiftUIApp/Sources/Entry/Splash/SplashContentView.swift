//
//  SplashContentView.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/2/25.
//

import SwiftUI
import WrapKit

private final class SplashContentAdapters {
    let text = TextOutputSwiftUIAdapter()
    let image = ImageViewOutputSwiftUIAdapter()
    let button = ButtonOutputSwiftUIAdapter()
    let loadingView = LoadingOutputSwiftUIAdapter()
}

public struct SplashContentView: View {
    private let lifeCycleOutput: LifeCycleViewOutput?
    private let applicationLifecycleOutput: ApplicationLifecycleOutput?
    private let adapters: SplashContentAdapters

    public var adapter: TextOutputSwiftUIAdapter { adapters.text }
    public var imageViewAdapter: ImageViewOutputSwiftUIAdapter { adapters.image }
    public var buttonAdapter: ButtonOutputSwiftUIAdapter { adapters.button }
    public var loadingAdapter: LoadingOutputSwiftUIAdapter { adapters.loadingView }
    
    public init(
        lifeCycleOutput: LifeCycleViewOutput? = nil,
        applicationLifecycleOutput: ApplicationLifecycleOutput? = nil
    ) {
        self.lifeCycleOutput = lifeCycleOutput
        self.applicationLifecycleOutput = applicationLifecycleOutput
        self.adapters = SplashContentAdapters()
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
                        //  SUILabel(adapter: textOutputAdapter)
                        //                      .frame(maxWidth: .infinity, alignment: .leading)
                        //                      .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Color.white
                        SUIImageView(adapter: imageViewAdapter)
                    }
                }
                ScrollView(.vertical) {
                    SUILabel(adapter: adapter)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .background(Color.blue.opacity(0.2))
                    
                    SUIButton(adapter: buttonAdapter)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity, alignment: .center)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .center)
                .background(
                    Color.red.ignoresSafeArea().opacity(0.2)
                )
                
                SUILoadingView.circleStrokeLoader(
                    adapter: loadingAdapter,
                    loadingViewColor: .blue,
                    wrapperViewColor: SwiftUIColor(.black.withAlphaComponent(0.5)),
                    dimBackgroundColor: SwiftUIColor(.black.withAlphaComponent(0.3))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview("SwiftUI") {
    EntryViewSwiftUIFactory().makeSplashScreen()
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
