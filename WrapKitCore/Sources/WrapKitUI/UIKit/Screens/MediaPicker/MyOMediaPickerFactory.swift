//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation
import PhotosUI

#if canImport(UIKit)
import UIKit

public protocol MyOMediaPickerFactory<Controller> {
    associatedtype Controller

    func makeMediaPickerController(
        flow: MyOMediaPickerFlow,
        sourceTypes: [MediaPickerManager.Source],
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) -> Controller
    
#if targetEnvironment(simulator)
    func makeSimulatedCameraController(onCapture: ((UIImage?) -> Void)?) -> Controller
#endif
}

public class MyOMediaPickerFactoryiOS: MyOMediaPickerFactory {
    
    public init() {
        _ = PHPickerViewController(configuration: .init())
    }
    
    public func makeMediaPickerController(
        flow: any MyOMediaPickerFlow,
        sourceTypes: [MediaPickerManager.Source],
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) -> UIViewController {
        let presenter = MediaPickerPresenter(
            flow: flow.mainQueueDispatched,
            sourceTypes: sourceTypes,
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
    
#if targetEnvironment(simulator)
    public func makeSimulatedCameraController(onCapture: ((UIImage?) -> Void)?) -> UIViewController {
        let presenter = SimulatedCameraPresenter(onCapture: onCapture)
        let contentView = SimulatedCameraContentView()
        let vc = ViewController(contentView: contentView, lifeCycleViewOutput: presenter)
        vc.presentationController?.delegate = presenter
        presenter.shutterButton = contentView.shutterButton
            .weakReferenced
            .mainQueueDispatched
        presenter.cancelButton = contentView.cancelButton
            .weakReferenced
            .mainQueueDispatched
        return vc
    }
#endif
}
#endif
