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
    var adapter = TextOutputSwiftUIAdapter()

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
                Color.gray.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        if #available(iOS 16, *) {
                            SUILabel(adapter: adapter)
                        } else {
                            // Fallback on earlier versions
                        }
                        
//                        let sample = BonusGiftPillPresentableModel(
//                            image: ImageViewPresentableModel(
//                                size: CGSize(width: 16, height: 16),
//                                image: .asset(UIImage(systemName: "mail"))
//                            ),
//                            title: .attributes([
//                                .init(
//                                    text: "Gift for you",
//                                    color: .white,
//                                    font: .boldSystemFont(ofSize: 13)
//                                )
//                            ]),
//                            gradient: [.green, .blue],
//                            onTap: { print("Tapped!") }
//                        )
//                        BonusGiftPillViewSwiftUI(model: sample)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct ImageViewWrapper: UIViewRepresentable {
    let model: ImageViewPresentableModel
    func makeUIView(context: Context) -> ImageView { ImageView() }
    func updateUIView(_ uiView: ImageView, context: Context) {
        uiView.display(model: model)
    }
}

public struct BonusGiftPillViewSwiftUI: View {
    public let model: BonusGiftPillPresentableModel
    
    @StateObject private var adapter = TextOutputSwiftUIAdapter()
    
    public init(model: BonusGiftPillPresentableModel) {
      self.model = model
    }
    
    public var body: some View {
        HStack(spacing: 1) {
            ImageViewWrapper(model: model.image)
            if #available(iOS 16, *) {
                SUILabel(adapter: adapter)
            } else {
                // Fallback on earlier versions
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(.vertical, 4)
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: model.gradient.map { SwiftUI.Color($0) }),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .contentShape(Capsule())
        .simultaneousGesture(
            TapGesture().onEnded {
                model.onTap?()
            }
        )
        .onAppear {
            adapter.display(model: model.title)
        }
    }
}

// MARK: — Preview

struct BonusGiftPillView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = BonusGiftPillPresentableModel(
            image: ImageViewPresentableModel(
                size: CGSize(width: 16, height: 16),
                image: .asset(UIImage(systemName: "mail"))
            ),
            title: .attributes(
                [.init(
                    text: "Gift for you",
                    color: .white,
                    font: .boldSystemFont(ofSize: 13),
                    underlineStyle: .byWord,
                    textAlignment: .center
                )]
            ),
            gradient: [
                .red,
                .blue
            ],
            onTap: { print("Tapped!") }
        )
        BonusGiftPillViewSwiftUI(model: sample)
    }
}

public protocol BonusGiftPillOutput: AnyObject {
    func display(model: BonusGiftPillPresentableModel)
}

public struct BonusGiftPillPresentableModel {
    public let image: ImageViewPresentableModel
    public let title: TextOutputPresentableModel
    public let gradient: [WrapKit.Color]
    public let onTap: (() -> Void)?
    
    public init(
        image: ImageViewPresentableModel,
        title: TextOutputPresentableModel,
        gradient: [WrapKit.Color],
        onTap: (() -> Void)?
    ) {
        self.image = image
        self.title = title
        self.gradient = gradient
        self.onTap = onTap
    }
}
