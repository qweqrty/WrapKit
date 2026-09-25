import Foundation

public extension Data {
    func resizeToJpegData(sizeInMB: Double, deltaInMB: Double = 0.2) -> Data {
        #if canImport(UIKit) && !os(watchOS)
        return UIImage(data: self)?.resizeToJpegData(sizeInMB: sizeInMB, deltaInMB: deltaInMB) ?? self
        #else
        return self
        #endif
    }
}

#if canImport(UIKit) && !os(watchOS)
import Foundation
import UIKit

public extension UIImage {
    
    fileprivate static let MIN_COMPRESSION: CGFloat = 0.1
    fileprivate static let MAX_COMPRESSION: CGFloat = 0.9
    
    func resizeToJpegData(sizeInMB: Double, deltaInMB: Double = 0.2) -> Data? {
        
        let allowedSizeInBytes = Int(sizeInMB * 1024 * 1024)
        let deltaInBytes = Int(0.2 * 1024 * 1024)
        
        // check if data already less then sizeInMB
        guard let fullResImageData = self.jpegData(compressionQuality: UIImage.MAX_COMPRESSION) else { return nil }
        if fullResImageData.count < Int(deltaInBytes + allowedSizeInBytes) {
            return fullResImageData
        }
        
        let compressionResult = resizeBinarySearchCompressionMethod(image: self,
                                                                    allowedSizeInBytes: allowedSizeInBytes,
                                                                    deltaInBytes: deltaInBytes)
        
        guard let compressionResultData = compressionResult.data else { return nil }
        
        return compressionResult.success ?
        compressionResultData :
        resizeImageSize(data: compressionResultData, allowedSizeInBytes: allowedSizeInBytes)
    }
    
    // compress image
    private func resizeBinarySearchCompressionMethod(image: UIImage, allowedSizeInBytes: Int, deltaInBytes: Int) -> (success: Bool, data: Data?) {
        
        var left: CGFloat = 0.0, right: CGFloat = 1.0
        var mid = (left + right) / 2.0
        guard var newResImageData = image.jpegData(compressionQuality: mid) else { return (success: false, data: nil) }
        
        while (mid > UIImage.MIN_COMPRESSION && mid < UIImage.MAX_COMPRESSION) {
            
            if newResImageData.count < (allowedSizeInBytes - deltaInBytes) {
                left = mid
            } else if newResImageData.count > (allowedSizeInBytes + deltaInBytes) {
                right = mid
            } else {
                return (success: true, data: newResImageData)
            }
            mid = (left + right) / 2.0
            guard let data = image.jpegData(compressionQuality: mid) else { return (success: false, data: nil) }
            newResImageData = data
        }
        return (success: false, data: newResImageData)
    }
    
    // resize image
    private func resizeImageSize(data: Data, allowedSizeInBytes: Int) -> Data? {
        guard var image = UIImage(data: data) else { return nil }
        var outputData = data
        
        while outputData.count > allowedSizeInBytes {
            guard let resizedImage = image.resized(withPercentage: 0.8),
                  let imageData = resizedImage.jpegData(compressionQuality: UIImage.MIN_COMPRESSION) else { return nil }
            
            image = resizedImage
            outputData = imageData
        }
        return outputData
    }
    
    private func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func normalizedImage() -> UIImage {
        if imageOrientation == .up, let cgImage {
            return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func croppedToPixelRect(_ pixelRect: CGRect) -> UIImage? {
        guard let cgImage else { return nil }

        let imageBounds = CGRect(
            x: 0,
            y: 0,
            width: cgImage.width,
            height: cgImage.height
        )

        let clippedRect = pixelRect.intersection(imageBounds)

        guard !clippedRect.isNull,
              clippedRect.width > 1,
              clippedRect.height > 1 else {
            return nil
        }

        let cropRect = clippedRect.integral.intersection(imageBounds)

        guard cropRect.width > 1,
              cropRect.height > 1,
              let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: croppedCGImage, scale: 1, orientation: .up)
    }
}
#endif

