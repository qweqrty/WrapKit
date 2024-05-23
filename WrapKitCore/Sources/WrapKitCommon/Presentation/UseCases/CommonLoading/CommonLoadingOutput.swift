//
//  CommonLoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol CommonLoadingOutput: AnyObject {
    func display(isLoading: Bool)
}
