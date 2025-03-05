//
//  WrapperView.swift
//  WrapKit
//
//  Created by Stas Lee on 6/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

open class WrapperView<ContentView: UIView>: ViewUIKit {
    public let contentView: ContentView
    
    public var contentViewConstraints: AnchoredConstraints?
    
    public init(
        contentView: ContentView = ContentView(),
        backgroundColor: UIColor = .clear,
        isHidden: Bool = false,
        isUserInteractionEnabled: Bool = true,
        contentViewConstraints: ((ContentView, UIView) -> AnchoredConstraints)
    ) {
        self.contentView = contentView
        super.init(frame: .zero)
        addSubview(contentView)
        self.isUserInteractionEnabled = isUserInteractionEnabled
        self.backgroundColor = backgroundColor
        self.contentViewConstraints = contentViewConstraints(contentView, self)
        self.isHidden = isHidden
    }
    
    public override init(frame: CGRect) {
        contentView = ContentView()
        super.init(frame: frame)
        addSubview(contentView)
        contentViewConstraints = contentView.fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 13.0, *)
struct WrapperViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> WrapperView<UIView> {
        let view = WrapperView(
            contentView: UIView(),
            contentViewConstraints: { contentView, superView in
                contentView.fillSuperview(padding: .init(top: 20, left: 20, bottom: 20, right: 20))
            }
        )
        view.contentView.backgroundColor = .red
        return view
    }

    func updateUIView(_ uiView: WrapperView<UIView>, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct WrapperView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
            WrapperViewRepresentable()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
    }
}
#endif
