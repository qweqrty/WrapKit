//
//  LoadingPresenter.swift
//  WrapKit
//
//  Created by Stanislav Li on 23/5/24.
//

import Foundation

public protocol LoadingOutput: AnyObject {
    var isLoading: Bool? { get set }
    
    func display(isLoading: Bool)
}
