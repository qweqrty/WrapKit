//
//  CommonLoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol CommonLoadingOutput: AnyObject {
    var isLoading: Bool { get }
    
    func display(isLoading: Bool)
}
