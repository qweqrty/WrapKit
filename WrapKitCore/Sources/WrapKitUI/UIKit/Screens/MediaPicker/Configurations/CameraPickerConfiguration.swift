//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation
import CoreGraphics

public enum VideoQualityType: Int {
    case typeHigh = 0
    case typeMedium = 1
    case typeLow = 2
    case type640x480 = 3
    case typeIFrame1280x720 = 4
    case typeIFrame960x540 = 5
}

public enum CameraCaptureMode: Int {
    case photo = 0
    case video = 1
}

public enum CameraDevice: Int {
    case rear = 0
    case front = 1
}

public enum CameraFlashMode: Int {
    case off = -1
    case auto = 0
    case on = 1
}

public struct CameraPickerConfiguration<T> {
    
    public let title: String
    public let mediaTypes: [String]
    public let allowsEditing: Bool
    public let videoMaximumDuration: TimeInterval
    public let videoQuality: VideoQualityType
    public let showsCameraControls: Bool
    
    /// For video, make sure to include mediaTypes "public.video"
    public let cameraCaptureMode: CameraCaptureMode
    public let cameraOverlayView: T?
    public let cameraViewTransform: CGAffineTransform
    public let cameraDevice: CameraDevice
    public let cameraFlashMode: CameraFlashMode
    
    public let desiredResultType: DesiredResultType
    
    public init(
        title: String,
        desiredResultType: DesiredResultType = .url,
        mediaTypes: [String] = [MediaPickerConstants.imageIdent],
        allowsEditing: Bool = false,
        videoMaximumDuration: TimeInterval = 10,
        videoQuality: VideoQualityType = .typeMedium,
        showsCameraControls: Bool = true,
        cameraOverlayView: T? = nil,
        cameraViewTransform: CGAffineTransform = .identity,
        cameraCaptureMode: CameraCaptureMode = .photo,
        cameraDevice: CameraDevice = .front,
        cameraFlashMode: CameraFlashMode = .auto
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
        picker.videoQuality = videoQuality.asUIImagePickerQualityType
        picker.showsCameraControls = showsCameraControls
        picker.cameraOverlayView = cameraOverlayView as? UIView
        picker.cameraViewTransform = cameraViewTransform
        picker.cameraCaptureMode = cameraCaptureMode.asUIImagePickerCameraCaptureMode /// For video, make sure to include mediaTypes "public.video"
        picker.cameraDevice = cameraDevice.asUIImagePickerCameraDevice
        picker.cameraFlashMode = cameraFlashMode.asUIImagePickerCameraFlashMode
        return picker
    }
}

extension VideoQualityType {
    var asUIImagePickerQualityType: UIImagePickerController.QualityType {
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

extension CameraCaptureMode {
    var asUIImagePickerCameraCaptureMode: UIImagePickerController.CameraCaptureMode {
        switch self {
        case .photo:
                .photo
        case .video:
                .video
        }
    }
}

extension CameraDevice {
    var asUIImagePickerCameraDevice: UIImagePickerController.CameraDevice {
        switch self {
        case .rear:
                .rear
        case .front:
                .front
        }
    }
}

extension CameraFlashMode {
    var asUIImagePickerCameraFlashMode: UIImagePickerController.CameraFlashMode {
        switch self {
        case .off:
                .off
        case .auto:
                .auto
        case .on:
                .on
        }
    }
}
#endif
