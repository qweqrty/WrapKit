//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation
import PhotosUI
import Combine

public struct GalleryPickerConfiguration {
    public enum FilterType {
        case images, videos, livePhotos
        case any([FilterType])
    }
    
    public let title: String
    public let desiredResultType: DesiredResultType ///
    public let type: FilterType
    public let selectionLimit: Int
    
    public init(
        title: String,
        type: FilterType = .images,
        selectionLimit: Int = 1,
        desiredResultType: DesiredResultType = .image
    ) {
        self.type = type
        self.selectionLimit = selectionLimit
        self.desiredResultType = desiredResultType
        self.title = title
    }
}

#if canImport(UIKit)

extension GalleryPickerConfiguration {
    var asPHPickerConfiguration: PHPickerConfiguration {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = self.selectionLimit
        
        switch self.type {
        case .images:
            configuration.filter = .images
        case .videos:
            configuration.filter = .videos
        case .livePhotos:
            configuration.filter = .livePhotos
        case .any(let types):
            let filters: [PHPickerFilter] = types.compactMap { type in
                switch type {
                case .images:
                    return .images
                case .videos:
                    return .videos
                case .livePhotos:
                    return .livePhotos
                case .any:
                    return nil
                }
            }
            configuration.filter = PHPickerFilter.any(of: filters)
        }
        return configuration
    }
}

extension UIImage {
    func convertToData(type: MediaPickerManager.DesiredResultType.DataType) -> Data? {
        switch type {
        case .png:
            return self.pngData()
        case .jpeg(let quality):
            return self.jpegData(compressionQuality: quality)
        case .heic:
            if #available(iOS 17.0, *) {
                return self.heicData()
            } else {
                return nil
            }
        }
    }
}

extension PHPickerResult {
    var asImage: AnyPublisher<UIImage?, Never> {
        Future { promise in
            if self.itemProvider.canLoadObject(ofClass: UIImage.self) {
                self.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    promise(.success(object as? UIImage))
                }
            } else {
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif
