//
//  SUIRefreshControlModifier.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 23/4/26.
//

import SwiftUI

public struct SUIRefreshControlModifier: ViewModifier {
    @ObservedObject var stateModel: SUIRefreshControlStateModel

    public init(adapter: RefreshControlOutputSwiftUIAdapter) {
        self.stateModel = .init(adapter: adapter)
    }

    public func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .refreshable {
                    stateModel.triggerRefresh()
                    while stateModel.isLoading {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                }
                .if(true) { view in
                    if #available(iOS 16.0, *) {
                        view.tint(stateModel.tintColor.map { SwiftUIColor($0) })
                    } else {
                        view.accentColor(stateModel.tintColor.map { SwiftUIColor($0) })
                    }
                }
        } else {
            // iOS 14 и ниже — refreshable не поддерживается
            content
        }
    }
}

public extension View {
    func refreshControl(adapter: RefreshControlOutputSwiftUIAdapter) -> some View {
        modifier(SUIRefreshControlModifier(adapter: adapter))
    }
}
