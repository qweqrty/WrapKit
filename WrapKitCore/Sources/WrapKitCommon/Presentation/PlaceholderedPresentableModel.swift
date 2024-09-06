//
//  PlaceholderedPresentableModel.swift
//  WrapKit
//
//  Created by Stanislav Li on 17/11/23.
//

import Foundation

public enum ShimmeredCellModel<PresentableModel: Hashable>: Hashable {
    case model(PresentableModel)
    case shimmer(UUID)

    public var isPlaceholder: Bool {
        switch self {
        case .model:
            return false
        case .shimmer:
            return true
        }
    }

    public var model: PresentableModel? {
        switch self {
        case .model(let model):
            return model
        default:
            return nil
        }
    }

    public static func ==(lhs: ShimmeredCellModel<PresentableModel>, rhs: ShimmeredCellModel<PresentableModel>) -> Bool {
        switch (lhs, rhs) {
        case (.model(let lhsModel), .model(let rhsModel)):
            return lhsModel == rhsModel
        case (.shimmer(let lhsID), .shimmer(let rhsID)):
            return lhsID == rhsID
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .model(let model):
            hasher.combine(model)
        case .shimmer(let id):
            hasher.combine(id)
        }
    }
}