//
//  PlaceholderedPresentableModel.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/11/23.
//

import Foundation

public enum PlaceholderedPresentableModel<PresentableModel> {
    case model(PresentableModel)
    case placeholder
    
    public var isPlaceholder: Bool {
        switch self {
        case .model:
            return false
        case .placeholder:
            return true
        }
    }
}
