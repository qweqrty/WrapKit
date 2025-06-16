//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation

public class MediaPickerPresenter {
   
    public var alertView: AlertOutput?
   
    public var pickerManager: MediaPickerManager?
   
    private let flow: MyOMediaPickerFlow
    private let sourceTypes: [MediaPickerManager.Source]
    private let callback: ((MediaPickerManager.ResultType?) -> Void)?
   
    public init(
        flow: MyOMediaPickerFlow,
        sourceTypes: [MediaPickerManager.Source],
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) {
        self.flow = flow
        self.sourceTypes = sourceTypes
        self.callback = callback
    }
}

extension MediaPickerPresenter: LifeCycleViewOutput {
    public func viewDidLoad() {
        
        alertView?.showActionSheet(
            model: .init(
                title: "NurStrings.Common.chooseSource",
                actions: sourceTypes.enumerated().map({ [weak self] index, source in
                        .init(title: "source.title") { /// TODO
                            switch source {
                            case .camera(let configuration):
                                self?.checkCameraPermissionAndPresentPicker(configuration)
                            default:
                                self?.presentPicker(source: source)
                            }
                        }
                }) + [
                    .init(title: "NurStrings.cancel", style: .cancel, handler: { [weak self] in
                        self?.flow.finish()
                    })
                ]
            )
        )
    }
}

#if canImport(UIKit)
import UIKit

extension MediaPickerPresenter {
    private func checkCameraPermissionAndPresentPicker(_ configuration: CameraPickerConfiguration) {
        pickerManager?.checkCameraAccess { [weak self] isDenied in
            guard isDenied else {
                self?.showCameraUnavailableAlert()
                return
            }
#if targetEnvironment(simulator)
//            self?.flow.showSimulatedCamera(onCapture: { [weak self] image in
//                guard let image else {
//                    self?.callback?(nil)
//                    self?.flow.finish()
//                    return
//                }
//                
//                self?.pickerManager?.deliver(image: image, using: configuration.desiredResultType) { [weak self] result in
//                    self?.callback?(result ?? nil)
//                    self?.flow.finish()
//                }
//            })
#else
            self?.presentPicker(source: .camera(configuration))
#endif
        }
    }
    
    private func presentPicker(source: MediaPickerManager.Source) {
        pickerManager?.presentPicker(source: source) { [weak self] result in
            self?.callback?(result ?? nil)
            self?.flow.finish()
        }
    }
    
    private func showCameraUnavailableAlert() {
        alertView?.showAlert(model: .init(
            title: "NurStrings.PhotoStore.cameraNowAllowed",
            text: "NurStrings.PhotoStore.giveCameraPermission",
            actions: [
                .init(title: "NurStrings.Registrator.goToSettings", handler: {
                    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(appSettingsURL) {
                        UIApplication.shared.open(appSettingsURL)
                    }
                }),
                .init(title: "NurStrings.cancel", style: .cancel, handler: { [weak self] in
                    self?.flow.finish()
                })
            ]
        ))
    }
}
#endif
