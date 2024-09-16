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
    func showServicedSelection<Request, Response>(
        service: any Service<Request, Response>,
        request: @escaping (() -> Request),
        response: @escaping ((Result<Response, ServiceError>) -> [SelectionType.SelectionCellPresentableModel])
    )
    func close(with result: SelectionType?)
}
