//
//  LoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol LoadingOutput: AnyObject {
    func display(model: LoadingOutputPresentableModel?)
}

public struct LoadingOutputPresentableModel {
    let isLoading: Bool?
}
