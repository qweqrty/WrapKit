//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation
import PhotosUI

public protocol MyOMediaPickerFactory<Controller> {
    associatedtype Controller

    func makeMediaPickerController(
        flow: MyOMediaPickerFlow,
        sourceTypes: [MediaPickerManager.Source],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) -> Controller
}

#if canImport(UIKit)

public class MyOMediaPickerFactoryiOS: MyOMediaPickerFactory {
    
    public init() {
        _ = PHPickerViewController(configuration: .init())
    }
    
    public func makeMediaPickerController(
        flow: any MyOMediaPickerFlow,
        sourceTypes: [MediaPickerManager.Source],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) -> UIViewController {
        let presenter = MediaPickerPresenter(
            flow: flow.mainQueueDispatched,
            sourceTypes: sourceTypes,
            localizable: localizable,
            callback: callback
        )
        let vc = BottomSheetController(contentView: .init(), lifeCycleViewOutput: presenter)
        let pickerManager = MediaPickerManager(presentingController: vc)
        presenter.pickerManager = pickerManager
        presenter.alertView = vc
            .weakReferenced
            .mainQueueDispatched
        return vc
    }
}
#endif
