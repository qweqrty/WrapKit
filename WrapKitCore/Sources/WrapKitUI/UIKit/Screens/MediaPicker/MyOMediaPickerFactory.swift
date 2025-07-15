//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation
import PhotosUI

public protocol MediaPickerFactory<Controller, View> {
    associatedtype Controller
    associatedtype View
    
    func makeMediaPickerController(
        flow: any MediaPickerFlow,
        sourceTypes: [MediaPickerSource<View>],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerResultType?) -> Void)?
    ) -> Controller
}

#if canImport(UIKit)
public class MediaPickerFactoryiOS: MediaPickerFactory {
    
    public init() {
        _ = PHPickerViewController(configuration: .init())
    }
    
    public func makeMediaPickerController(
        flow: any MediaPickerFlow,
        sourceTypes: [MediaPickerSource<UIView>],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerResultType?) -> Void)?
    ) -> UIViewController {
        let presenter = MediaPickerPresenter(
            flow: flow.mainQueueDispatched,
            sourceTypes: sourceTypes,
            localizable: localizable,
            callback: callback
        )
        let vc = BottomSheetController(contentView: .init(), lifeCycleViewOutput: presenter)
        let pickerManager = MediaPickerManager<UIView>(presentingController: vc)
        presenter.pickerManager = pickerManager
        presenter.alertView = vc
            .weakReferenced
            .mainQueueDispatched
        return vc
    }
}
#endif
