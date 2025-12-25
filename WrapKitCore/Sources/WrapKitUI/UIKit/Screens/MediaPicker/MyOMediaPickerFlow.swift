//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

public protocol MediaPickerFlow {
    
    func showMediaPicker(
        sourceTypes: [MediaPickerSource],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerResultType?) -> Void)?
    )

    func finish()
}

#if canImport(UIKit)
import UIKit

extension UIView: CameraGenericView {}

public class MediaPickerFlowiOS: MediaPickerFlow {
    
    public weak var navigationController: UINavigationController?
    public let factory: any MediaPickerFactory<UIViewController>
    
    public init(
        navigationController: UINavigationController?,
        factory: any MediaPickerFactory<UIViewController>
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    public func showMediaPicker(
        sourceTypes: [MediaPickerSource],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerResultType?) -> Void)?
    ) {
        let vc = factory.makeMediaPickerController(
            flow: self,
            sourceTypes: sourceTypes,
            localizable: localizable,
            callback: callback
        )
        navigationController?.view.endEditing(true)
        navigationController?.present(vc, animated: true)
    }
    
    public func finish() {
        navigationController?.dismiss(animated: true)
    }
}
#endif
