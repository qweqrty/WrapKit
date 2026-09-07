#if canImport(UIKit)
import ImageIO
import UIKit
import UniformTypeIdentifiers

public enum SnapshotBaselineValidationError: Error, Equatable {
    case missing
    case empty
    case notPNG
    case corruptPNG
    case invalidReferenceBitmap
    case invalidSnapshotBitmap
    case incompatiblePixelDimensions(
        expectedWidth: Int,
        expectedHeight: Int,
        actualWidth: Int,
        actualHeight: Int
    )
    case incompatibleScale(expected: CGFloat, actual: CGFloat)
    case incompatibleOrientation(expected: Int, actual: Int)
}

/// Side-effect-free validation used before snapshot assertions report an XCTest failure.
public enum SnapshotBaselineValidator {
    private static let pngSignature = Data([137, 80, 78, 71, 13, 10, 26, 10])

    public static func validateBaselineData(_ data: Data?) -> SnapshotBaselineValidationError? {
        guard let data else { return .missing }
        guard !data.isEmpty else { return .empty }
        guard data.starts(with: pngSignature) else { return .notPNG }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let sourceType = CGImageSourceGetType(source),
              CFEqual(sourceType, UTType.png.identifier as CFString),
              CGImageSourceGetCount(source) > 0,
              CGImageSourceGetStatus(source) == .statusComplete,
              CGImageSourceGetStatusAtIndex(source, 0) == .statusComplete,
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
              image.width > 0,
              image.height > 0 else {
            return .corruptPNG
        }
        return nil
    }

    public static func validateSnapshotPair(
        reference: UIImage,
        snapshot: UIImage
    ) -> SnapshotBaselineValidationError? {
        guard let referenceImage = reference.cgImage,
              referenceImage.width > 0,
              referenceImage.height > 0 else {
            return .invalidReferenceBitmap
        }
        guard let snapshotImage = snapshot.cgImage,
              snapshotImage.width > 0,
              snapshotImage.height > 0 else {
            return .invalidSnapshotBitmap
        }
        guard referenceImage.width == snapshotImage.width,
              referenceImage.height == snapshotImage.height else {
            return .incompatiblePixelDimensions(
                expectedWidth: referenceImage.width,
                expectedHeight: referenceImage.height,
                actualWidth: snapshotImage.width,
                actualHeight: snapshotImage.height
            )
        }
        guard reference.scale == snapshot.scale else {
            return .incompatibleScale(expected: reference.scale, actual: snapshot.scale)
        }
        guard reference.imageOrientation == snapshot.imageOrientation else {
            return .incompatibleOrientation(
                expected: reference.imageOrientation.rawValue,
                actual: snapshot.imageOrientation.rawValue
            )
        }
        return nil
    }
}
#endif
