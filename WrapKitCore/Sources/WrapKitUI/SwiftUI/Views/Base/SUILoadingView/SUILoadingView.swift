//
//  SUILoadingView.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 16/4/26.
//

import SwiftUI

public struct SUILoadingView: View {
    @ObservedObject var stateModel: SUILoadingStateModel
    let color: SwiftUIColor
    let wrapperColor: SwiftUIColor
    let size: CGSize
    let padding: EdgeInsets
    let dimBackgroundColor: SwiftUIColor
    
    public init(
        adapter: LoadingOutputSwiftUIAdapter,
        color: SwiftUIColor = .white,
        wrapperColor: SwiftUIColor = .clear,
        size: CGSize = .init(width: 80, height: 80),
        padding: EdgeInsets = .init(top: 25, leading: 25, bottom: 25, trailing: 25),
        dimBackgroundColor: SwiftUIColor = .clear
    ) {
        self.stateModel = .init(adapter: adapter)
        self.color = color
        self.wrapperColor = wrapperColor
        self.size = size
        self.padding = padding
        self.dimBackgroundColor = dimBackgroundColor
    }
    
    public var body: some View {
        if stateModel.isLoading {
            ZStack {
                dimBackgroundColor
                
                SUIWrapperView(
                    backgroundColor: wrapperColor,
                    cornerRadius: 12,
                    padding: padding
                ) {
                    SUILoadingViewContent(
                        color: color,
                        size: CGSize(
                            width: size.width - padding.leading - padding.trailing,
                            height: size.height - padding.top - padding.bottom
                        )
                    )
                }
            }
        }
    }
    
}

public extension SUILoadingView {
    static func circleStrokeLoader(
        adapter: LoadingOutputSwiftUIAdapter,
        loadingViewColor: SwiftUIColor,
        wrapperViewColor: SwiftUIColor = .clear,
        size: CGSize = .init(width: 80, height: 80),
        padding: EdgeInsets = .init(top: 25, leading: 25, bottom: 25, trailing: 25),
        dimBackgroundColor: SwiftUIColor = .clear
    ) -> SUILoadingView {
        SUILoadingView(
            adapter: adapter,
            color: loadingViewColor,
            wrapperColor: wrapperViewColor,
            size: size,
            padding: padding,
            dimBackgroundColor: dimBackgroundColor
        )
    }
}
