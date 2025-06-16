//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//


public protocol MyOMediaPickerFlow {
    func showMediaPicker(
        sourceTypes: [MediaPickerManager.Source],
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    )

    func finish()
}

#if canImport(UIKit)
import UIKit

public class MyOMediaPickerFlowiOS: MyOMediaPickerFlow {
    
    public weak var navigationController: UINavigationController?
    public let factory: any MyOMediaPickerFactory<UIViewController>
    
    public init(
        navigationController: UINavigationController?,
        factory: any MyOMediaPickerFactory<UIViewController>
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func showMediaPicker(
        sourceTypes: [MediaPickerManager.Source],
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) {
        let vc = factory.makeMediaPickerController(
            flow: self,
            sourceTypes: sourceTypes,
            callback: callback
        )
        navigationController?.present(vc, animated: true)
    }
    
    public func finish() {
        navigationController?.dismiss(animated: true)
    }
}
#endif
