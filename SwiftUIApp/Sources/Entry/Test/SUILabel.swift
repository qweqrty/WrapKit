//
//  SUILabel.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 17/4/25.
//

import Foundation
import SwiftUI
import WrapKit

struct SUILabel: View {
    @ObservedObject var adapter: TextOutputSwiftUIAdapter
    
    var body: some View {
        Group {
            if let isHiddenState = adapter.displayIsHiddenState, isHiddenState.isHidden {
                SwiftUICore.EmptyView()
            } else {
                Text(displayText)
            }
        }
    }
    
    private var displayText: String {
        if let textState = adapter.displayTextState, let text = textState.text {
            return text
        } else if let modelState = adapter.displayModelState, case .text(let text) = modelState.model {
            return text ?? ""
        }
        return ""
    }
    
}
