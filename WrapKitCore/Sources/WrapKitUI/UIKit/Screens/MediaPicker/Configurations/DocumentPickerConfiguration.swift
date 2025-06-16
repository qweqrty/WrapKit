//
//  File.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 16/6/25.
//

import Foundation
import UniformTypeIdentifiers
import Combine

public struct DocumentPickerConfiguration {
    
    public let contentTypes: [UTType]
    public let asCopy: Bool
    public let multipleSelection: Bool
    public let showFileExtensions: Bool
    public let directoryURL: URL?
    public let desiredResultType: MediaPickerManager.DesiredResultType
 
    public init(
        contentTypes: [UTType] = [.image, .video, .pdf, .data],
        asCopy: Bool = true,
        multipleSelection: Bool = false,
        showFileExtensions: Bool = false,
        directoryURL: URL? = nil,
        desiredResultType: MediaPickerManager.DesiredResultType = .url
    ) {
        self.contentTypes = contentTypes
        self.asCopy = asCopy
        self.multipleSelection = multipleSelection
        self.showFileExtensions = showFileExtensions
        self.directoryURL = directoryURL
        self.desiredResultType = desiredResultType
    }
}

#if canImport(UIKit)
import UIKit

extension DocumentPickerConfiguration {
    var asDocumentPicker: UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: self.contentTypes,
            asCopy: self.asCopy
        )
        documentPicker.allowsMultipleSelection = self.multipleSelection
        documentPicker.directoryURL = self.directoryURL
        documentPicker.shouldShowFileExtensions = self.showFileExtensions
        return documentPicker
    }
}

extension URL {
    var asImage: AnyPublisher<UIImage?, Never> {
        Future { promise in
            if self.isImage {
                guard let image = UIImage(contentsOfFile: self.path)
                else { return promise(.success(nil)) }
                promise(.success(image))
            } else {
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }
    
    var isImage: Bool {
        guard let type = try? self.resourceValues(forKeys: [.contentTypeKey]).contentType else {
            return false
        }
        return type.conforms(to: .image)
    }

    var isVideo: Bool {
        guard let type = try? self.resourceValues(forKeys: [.contentTypeKey]).contentType else {
            return false
        }
        return type.conforms(to: .audiovisualContent) && type.conforms(to: .movie)
    }
}
#endif
