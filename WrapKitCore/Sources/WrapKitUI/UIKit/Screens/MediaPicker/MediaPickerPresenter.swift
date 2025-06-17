//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation

public struct MediaPickerLocalizable {
    public let sourceASTitle: String
    public let cancel: String
    public let cameraAlertTitle: String
    public let cameraAlertText: String
    public let settingsButtonTitle: String
    
    public init(
        sourceASTitle: String,
        cancel: String,
        cameraAlertTitle: String,
        cameraAlertText: String,
        settingsButtonTitle: String
    ) {
        self.sourceASTitle = sourceASTitle
        self.cancel = cancel
        self.cameraAlertTitle = cameraAlertTitle
        self.cameraAlertText = cameraAlertText
        self.settingsButtonTitle = settingsButtonTitle
    }
}

public class MediaPickerPresenter {
   
    public var alertView: AlertOutput?
   
    public var pickerManager: MediaPickerManager?
    
    public let localizable: MediaPickerLocalizable
    private let flow: MyOMediaPickerFlow
    private let sourceTypes: [MediaPickerManager.Source]
    private let callback: ((MediaPickerManager.ResultType?) -> Void)?
   
    public init(
        flow: MyOMediaPickerFlow,
        sourceTypes: [MediaPickerManager.Source],
        localizable: MediaPickerLocalizable,
        callback: ((MediaPickerManager.ResultType?) -> Void)?
    ) {
        self.flow = flow
        self.sourceTypes = sourceTypes
        self.callback = callback
        self.localizable = localizable
    }
}

extension MediaPickerPresenter: LifeCycleViewOutput {
    public func viewDidLoad() {
        
        alertView?.showActionSheet(
            model: .init(
                title: localizable.sourceASTitle,
                actions: sourceTypes.enumerated().map({ [weak self] index, source in
                    switch source {
                    case .camera(let configuration):
                        .init(title: configuration.title) {
                            self?.checkCameraPermissionAndPresentPicker(configuration)
                        }
                    case .file(let configuration):
                        .init(title: configuration.title) {
                            self?.presentPicker(source: source)
                        }
                    case .gallery(let configuration):
                        .init(title: configuration.title) {
                            self?.presentPicker(source: source)
                        }
                    }
                }) + [
                    .init(title: localizable.cancel, style: .cancel, handler: { [weak self] in
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
            let vc = SimulatedCameraViewController(contentView: .init()) { result in
                guard let result else {
                    self?.callback?(nil)
                    self?.flow.finish()
                    return
                }

                self?.pickerManager?.deliver(image: result, using: configuration.desiredResultType) { [weak self] result in
                    self?.callback?(result ?? nil)
                    self?.flow.finish()
                }
            }
            self?.pickerManager?.presentingController?.present(vc, animated: true)
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
            title: localizable.cameraAlertTitle,
            text: localizable.cameraAlertText,
            actions: [
                .init(
                    title: localizable.settingsButtonTitle,
                    handler: {
                    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(appSettingsURL) {
                        UIApplication.shared.open(appSettingsURL)
                    }
                }),
                .init(title: localizable.cancel, style: .cancel, handler: { [weak self] in
                    self?.flow.finish()
                })
            ]
        ))
    }
}
#endif
