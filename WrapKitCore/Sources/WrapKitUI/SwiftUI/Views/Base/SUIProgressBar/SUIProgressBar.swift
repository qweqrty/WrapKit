//
//  SUIProgressBar.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import SwiftUI

public struct SUIProgressBar: View {
    @ObservedObject var stateModel: SUIProgressBarStateModel
    
    public init(adaper: ProgressBarOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adaper)
    }
    
    public var body: some View {
        if !stateModel.isHidden {
            SUIProgressBarView(
                progress: stateModel.progress,
                style: stateModel.style
            )
        }
    }
}

public struct SUIProgressBarView: View {
    let progress: CGFloat // 0-100
    let style: ProgressBarStyle?
    
    public init(
        progress: CGFloat = 0,
        style: ProgressBarStyle? = nil
    ) {
        self.progress = progress
        self.style = style
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // background track
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(style?.backgroundColor.map { SwiftUIColor($0) } ?? SwiftUIColor(.lightGray))
                
                // progress fill
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(style?.progressBarColor.map { SwiftUIColor($0) } ?? SwiftUIColor(.green))
                    .frame(width: geo.size.width * (progress / 100))
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: style?.height ?? 4)
    }

    private var cornerRadius: CGFloat {
        switch style?.cornerStyle ?? .fixed(4) {
        case .automatic:
            return (style?.height ?? 4) / 2
        case .fixed(let radius):
            return radius
        case .corners(let corners):
            return corners.maximum
        case .none:
            return .zero
        }
    }
}

#Preview {
    SUIProgressBarView(
        progress: 50,
        style: .init(
            backgroundColor: .lightGray,
            progressBarColor: .systemBlue,
            height: 20,
            cornerStyle: .fixed(16)
        )
    )
    .padding()
}
