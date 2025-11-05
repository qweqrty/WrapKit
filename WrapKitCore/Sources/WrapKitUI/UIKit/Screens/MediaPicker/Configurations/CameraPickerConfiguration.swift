//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation

public enum VideoQualityType: Int {
    case typeHigh = 0
    case typeMedium = 1
    case typeLow = 2
    case type640x480 = 3
    case typeIFrame1280x720 = 4
    case typeIFrame960x540 = 5
}

public struct CameraPickerConfiguration {
    
    public let title: String
    public let mediaTypes: [String]
    public let allowsEditing: Bool
    public let videoMaximumDuration: TimeInterval
    public let videoQuality: VideoQualityType
    public let showsCameraControls: Bool
    public let cameraOverlayView: ViewUIKit?
    public let cameraViewTransform: CGAffineTransform
    
    /// For video, make sure to include mediaTypes "public.video"
    public let cameraCaptureMode: UIImagePickerController.CameraCaptureMode
    
    public let cameraDevice: UIImagePickerController.CameraDevice
    public let cameraFlashMode: UIImagePickerController.CameraFlashMode
    public let desiredResultType: MediaPickerManager.DesiredResultType
    
    public init(
        title: String,
        desiredResultType: MediaPickerManager.DesiredResultType = .url,
        mediaTypes: [String] = [MediaPickerManager.Constants.imageIdent],
        allowsEditing: Bool = false,
        videoMaximumDuration: TimeInterval = 10,
        videoQuality: VideoQualityType = .typeMedium,
        showsCameraControls: Bool = true,
        cameraOverlayView: ViewUIKit? = nil,
        cameraViewTransform: CGAffineTransform = .identity,
        cameraCaptureMode: UIImagePickerController.CameraCaptureMode = .photo,
        cameraDevice: UIImagePickerController.CameraDevice = .front,
        cameraFlashMode: UIImagePickerController.CameraFlashMode = .auto
    ) {
        self.mediaTypes = mediaTypes
        self.allowsEditing = allowsEditing
        self.videoMaximumDuration = videoMaximumDuration
        self.videoQuality = videoQuality
        self.showsCameraControls = showsCameraControls
        self.cameraOverlayView = cameraOverlayView
        self.cameraViewTransform = cameraViewTransform
        self.cameraCaptureMode = cameraCaptureMode
        self.cameraDevice = cameraDevice
        self.cameraFlashMode = cameraFlashMode
        self.desiredResultType = desiredResultType
        self.title = title
    }
}

#if canImport(UIKit)
import UIKit

extension CameraPickerConfiguration {
    var asImagePicker: UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = mediaTypes
        picker.allowsEditing = allowsEditing
        picker.videoMaximumDuration = videoMaximumDuration
        picker.videoQuality = videoQuality.asUIImagePickerControllerQualityType
        picker.showsCameraControls = showsCameraControls
        picker.cameraOverlayView = cameraOverlayView
        picker.cameraViewTransform = cameraViewTransform
        picker.cameraCaptureMode = cameraCaptureMode /// For video, make sure to include mediaTypes "public.video"
        picker.cameraDevice = cameraDevice
        picker.cameraFlashMode = cameraFlashMode
       
        return picker
    }
}

extension VideoQualityType {
    var asUIImagePickerControllerQualityType: UIImagePickerController.QualityType {
        switch self {
        case .typeHigh:
                .typeHigh
        case .typeMedium:
                .typeMedium
        case .typeLow:
                .typeLow
        case .type640x480:
                .type640x480
        case .typeIFrame1280x720:
                .typeIFrame1280x720
        case .typeIFrame960x540:
                .typeIFrame960x540
        }
    }
}
#endif
