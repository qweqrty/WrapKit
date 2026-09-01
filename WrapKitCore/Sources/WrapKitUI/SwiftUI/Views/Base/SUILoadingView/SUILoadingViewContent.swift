//
//  SUILoadingViewContent.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 16/4/26.
//

import SwiftUI

public struct SUILoadingViewContent: View {
    let color: SwiftUIColor
    let size: CGSize

    public var body: some View {
        SUICircleStrokeSpin(color: color, size: size)
    }
}
