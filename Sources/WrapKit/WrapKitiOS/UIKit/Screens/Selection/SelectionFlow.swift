//
//  SelectionFlow.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public protocol SelectionFlow: AnyObject {
    typealias Model = SelectionPresenterModel
    
    var model: SelectionPresenterModel { get }
    
    func showSelection()
    func close(with result: SelectionType?)
}
