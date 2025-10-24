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
                Color.red.ignoresSafeArea().opacity(0.2)

                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        
                        SUILabel(adapter: adapter)

                        Text(
                            Image(uiImage: ImageFactory.systemImage(named: "mail") ?? UIImage())
                            // .resized(rect: CGRect(x: 0, y: 0, width: 45, height: 55), maxHeight: 100) ?? UIImage())
                        )
                        .font(SwiftUIFont.system(size: 20, weight: .bold))
                        .baselineOffset(20) + Text("The quick fox")
                            .underlineIfAvailable(.patternDashDotDot)
                        + Text(
                            Image(uiImage: ImageFactory.systemImage(named: "arrow.right") ?? UIImage())
                            // .resized(rect: CGRect(x: -30, y: -40, width: 15, height: 15), maxHeight: 100) ?? UIImage())
                        )
                        .baselineOffset(-20) + Text(Image(systemName: "star"))
                         + Text(
                            "blue italic"
                         )
                         .color(Color.blue)
                         .font(SwiftUIFont(FontFactory.italic(size: 15)))
                         .underlineIfAvailable(.patternDash)
                        
//                        FallbackLabel(adapter: adapter)
//                            .frame(width: 300, alignment: .leading)
////                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding(.horizontal, .zero)
                    }
                }
            }
        }
    }
}

#Preview {
    EntryViewSwiftUIFactory().makeSplashScreen()
}

extension Text {
    func color(_ color: SwiftUIColor) -> Self {
        if #available(iOS 17.0, *) {
            foregroundStyle(color)
        } else {
            foregroundColor(color)
        }
    }
}
