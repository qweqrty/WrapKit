//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import PhotosUI
import UniformTypeIdentifiers
import Combine

public enum DesiredResultType {
    case image
    case data(DataType)
    case url
    
    public enum DataType {
        case png
        case jpeg(CGFloat)
        case heic
    }
}

public struct MediaPickerConstants {
    public static let imageIdent = "public.image"
    public static let videoIdent = "public.movie"
}

public enum MediaPickerSource<T> {
    case camera(CameraPickerConfiguration<T>)
    case gallery(GalleryPickerConfiguration)
    case file(DocumentPickerConfiguration)
}

public enum MediaPickerResultType {
    case image([Image])
    case data([Data])
    case url([URL])
}

#if canImport(UIKit)
import UIKit

public final class MediaPickerManager<T>: NSObject,
                                          UIImagePickerControllerDelegate,
                                          UINavigationControllerDelegate,
                                          UIAdaptivePresentationControllerDelegate,
                                          UIDocumentPickerDelegate {
    
    private var cancellables = Set<AnyCancellable>()
    
    public var desiredResultType: DesiredResultType = .url
    weak var presentingController: UIViewController?
    private var completion: ((MediaPickerResultType?) -> Void)?
    
    public init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }
    
    func checkCameraAccess(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func presentPicker(source: MediaPickerSource<T>, completion: @escaping (MediaPickerResultType?) -> Void) {
        self.completion = completion
        
        switch source {
        case .camera(let configuration):
            presentCamera(configuration)
        case .gallery(let configuration):
            presentGallery(configuration)
        case .file(let configuration):
            presentDocumentPicker(configuration)
        }
    }
    
    func presentCamera(_ configuration: CameraPickerConfiguration<T>) {
        let picker = configuration.asImagePicker
        picker.delegate = self
        desiredResultType = configuration.desiredResultType
        presentingController?.present(picker, animated: true)
    }
    
    private func presentGallery(_ configuration: GalleryPickerConfiguration) {
        let picker = PHPickerViewController(configuration: configuration.asPHPickerConfiguration)
        desiredResultType = configuration.desiredResultType
        picker.delegate = self
        picker.presentationController?.delegate = self as? any UIAdaptivePresentationControllerDelegate
        presentingController?.present(picker, animated: true)
    }
    
    private func presentDocumentPicker(_ configuration: DocumentPickerConfiguration) {
        let documentPicker = configuration.asDocumentPicker
        documentPicker.delegate = self as? any UIDocumentPickerDelegate
        documentPicker.presentationController?.delegate = self as? any UIAdaptivePresentationControllerDelegate
        desiredResultType = configuration.desiredResultType
        presentingController?.present(documentPicker, animated: true)
    }
    
    func deliver(image: Image, using type: DesiredResultType, simulatedCompletion: ((MediaPickerResultType?) -> Void)? = nil) {
        
        if let simulatedCompletion {
            completion = simulatedCompletion
        }
        switch type {
        case .image:
            completion?(.image([image]))
        case .data(let format):
            guard let data = image.convertToData(type: format) else {
                completion?(nil); return
            }
            completion?(.data([data]))
        case .url: /// only for simulator
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("simulated.jpg")
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: tempURL)
                completion?(.url([tempURL]))
            } else {
                completion?(nil)
            }
        }
    }
    
    private func returnImages(_ publishers: [AnyPublisher<UIImage?, Never>]) {
        Publishers.MergeMany(publishers)
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                self?.completion?(.image(images))
            }
            .store(in: &cancellables)
    }
    
    private func returnData(
        _ publishers: [AnyPublisher<Image?, Never>],
        type: DesiredResultType.DataType
    ) {
        Publishers.MergeMany(publishers)
            .compactMap { $0?.convertToData(type: type) }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dataArray in
                self?.completion?(.data(dataArray))
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion?(nil)
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        guard let mediaType = info[.mediaType] as? String else {
            completion?(nil); return
        }
        switch mediaType {
        case UTType.image.identifier, MediaPickerConstants.imageIdent:
            handlePickedImage(info)
        case UTType.movie.identifier, MediaPickerConstants.videoIdent:
            handlePickedVideo(info)
        default: completion?(nil)
        }
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        completion?(nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        switch desiredResultType {
        case .image:
            let publishers = urls.map { $0.asImage }
            returnImages(publishers)
        case .data(let type):
            let publishers = urls.map { $0.asImage }
            returnData(publishers, type: type)
        case .url:
            completion?(.url(urls))
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion?(nil)
    }
}

extension MediaPickerManager {
    
    // MARK: - Image Handling
    private func handlePickedImage(_ info: [UIImagePickerController.InfoKey: Any]) {
        switch desiredResultType {
        case .image, .data:
            if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
                deliver(image: image, using: desiredResultType)
            } else {
                completion?(nil)
            }
        case .url:
            if let imageURL = info[.imageURL] as? URL {
                completion?(.url([imageURL]))
            } else {
                completion?(nil)
            }
        }
    }
    // MARK: - Video Handling
    private func handlePickedVideo(_ info: [UIImagePickerController.InfoKey: Any]) {
        guard case .url = desiredResultType else {
            completion?(nil); return
        }
        if let url = info[.mediaURL] as? URL {
            completion?(.url([url]))
        } else {
            completion?(nil)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension MediaPickerManager: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        switch desiredResultType {
        case .image:
            let publishers = results.map { $0.asImage }
            returnImages(publishers)
        case .data(let type):
            let publishers = results.map { $0.asImage }
            returnData(publishers, type: type)
        case .url:
            loadURLs(from: results)
        }
    }
    
    private func loadURLs(from results: [PHPickerResult]) {
        let publishers = results.map { result -> AnyPublisher<URL?, Never> in
            let itemProvider = result.itemProvider
            
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                return loadFileRepresentation(for: result, typeIdentifier: UTType.image.identifier)
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                return loadFileRepresentation(for: result, typeIdentifier: UTType.movie.identifier)
            } else {
                return Just(nil).eraseToAnyPublisher()
            }
        }
        
        Publishers.MergeMany(publishers)
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] urls in
                self?.completion?(urls.isEmpty ? nil : .url(urls))
            }
            .store(in: &cancellables)
    }
    
    /// Общий метод загрузки файла с копированием в temp директорию
    private func loadFileRepresentation(for result: PHPickerResult, typeIdentifier: String) -> AnyPublisher<URL?, Never> {
        let subject = PassthroughSubject<URL?, Never>()
        let itemProvider = result.itemProvider
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
            if error != nil {
                subject.send(nil)
            } else if let url = url {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    subject.send(tempURL)
                } catch {
                    subject.send(nil)
                }
            } else {
                subject.send(nil)
            }
            subject.send(completion: .finished)
        }
        return subject.eraseToAnyPublisher()
    }
}
#endif
