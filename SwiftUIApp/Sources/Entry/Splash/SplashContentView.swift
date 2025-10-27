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
                VStack(alignment: .leading) {
                    
                    SUILabel(adapter: adapter)
                    
                    Text(
                        SwiftUIImage(
                            image: ImageFactory.systemImage(named: "mail")? //  ?? UIImage())
                                .resized(rect: CGRect(x: 0, y: 20, width: 45, height: 55), container: CGSize(width: 75, height: 75))
                            ?? Image()
                        )
                    )
                    .font(SwiftUIFont.system(size: 22, weight: .bold))
                    .baselineOffset(20)
                    +
                    Text("The quick fox")
                    + Text(
                        SwiftUIImage(
                            image: ImageFactory.systemImage(named: "arrow.right")?
                                .resized(rect: CGRect(x: 30, y: 40, width: 15, height: 15), container: CGSize(width: 45, height: 55))
                            ?? Image()
                        )
                    )
                    .baselineOffset(-20) + Text(Image(systemName: "star"))
                    + Text(
                        "blue italic"
                    )
                    .textColor(Color.blue)
                    .font(SwiftUIFont(FontFactory.italic(size: 15)))
                    
                    if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
                        Text(
                            AttributedString(NSAttributedString(string: "NSUnderlineStyle.double", attributes: [.underlineStyle: NSUnderlineStyle.double]))
                        )
                        .textColor(Color.blue)
                        .font(SwiftUIFont(FontFactory.italic(size: 15)))
                    }
                    
//                    FallbackLabel(adapter: adapter)
//                        .frame(width: 300, alignment: .leading)
//                    //                            .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, .zero)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .background(
                Color.red.ignoresSafeArea().opacity(0.2)
            )
        }
    }
}

#Preview {
    EntryViewSwiftUIFactory().makeSplashScreen()
}
