import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

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

#if os(iOS) || targetEnvironment(macCatalyst)
public enum MediaPickerSource {
    case camera(CameraPickerConfiguration)
    case gallery(GalleryPickerConfiguration)
    case file(DocumentPickerConfiguration)
}
#endif

public enum MediaPickerResultType {
    case image([Image])
    case data([Data])
    case url([URL])
}
