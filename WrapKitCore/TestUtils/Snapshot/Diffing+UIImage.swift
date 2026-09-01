#if os(iOS) || os(tvOS)
import UIKit
import XCTest

extension Diffing where Value == UIImage {
    /// A pixel-diffing strategy for UIImages that normalizes color space and rejects visible changes.
    public static let image = Diffing.image()

    /// Compares a UIKit snapshot with its committed UIKit baseline.
    ///
    /// Both images are serialized and converted to the same sRGB representation. The comparison
    /// has no spatial tolerance: a moved edge is a failure. Only sub-visible channel rounding from
    /// color-space conversion and PNG serialization is accepted.
    public static let strictImage = Diffing(
        toData: encodedPNG,
        fromData: { decodedImage(from: $0, scale: UIScreen.main.scale) },
        diff: { old, new in
            guard let message = strictCanonicalDifferenceMessage(old, new) else { return nil }
            let difference = diffInverse(old, new) ?? diffOverlap(old, new)
            return (message, (new, difference))
        }
    )

    /// Compares a SwiftUI render with its corresponding UIKit render.
    ///
    /// The same canonical sRGB representation is used as for strict snapshots. A fixed physical-
    /// pixel neighborhood absorbs only bounded anti-aliasing redistribution around a two-axis
    /// contour. Geometry, scale, flat edges and non-edge pixels remain exact.
    public static let swiftUIParity = Diffing(
        toData: encodedPNG,
        fromData: { decodedImage(from: $0, scale: UIScreen.main.scale) },
        diff: { old, new in
            guard let message = SwiftUIParityImageComparator.differenceMessage(old, new) else {
                return nil
            }
            let difference = diffInverse(old, new) ?? diffOverlap(old, new)
            return (message, (new, difference))
        }
    )
    
    /// A pixel-diffing strategy for UIImage that allows customizing how precise the matching must be.
    ///
    /// Sparse differences caused by 8-bit color normalization are treated as equivalent before the
    /// requested precision settings are evaluated. Differences outside that tolerance use either
    /// byte precision or perceptual precision, depending on the requested settings.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a
    ///     match. 98-99% mimics
    ///     [the precision](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e) of the
    ///     human eye.
    ///   - alphaTolerance: Maximum allowed alpha-channel difference for every pixel when perceptual
    ///     comparison is enabled.
    ///   - allowsQuantizationTolerance: Whether sparse one- or two-step channel differences caused by
    ///     image serialization should be accepted before the requested precision is evaluated.
    ///   - scale: Scale to use when loading the reference image from disk. If `nil` or the
    ///     `UITraitCollection`s default value of `0.0`, the screens scale is used.
    /// - Returns: A new diffing strategy.
    public static func image(
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        alphaTolerance: UInt8 = 0,
        allowsQuantizationTolerance: Bool = true,
        scale: CGFloat = UIScreen.main.scale
    ) -> Diffing {
        return Diffing(
            toData: encodedPNG,
            fromData: { decodedImage(from: $0, scale: scale) },
            diff: { old, new in
                guard let message = compare(
                    old,
                    new,
                    precision: precision,
                    perceptualPrecision: perceptualPrecision,
                    alphaTolerance: alphaTolerance,
                    allowsQuantizationTolerance: allowsQuantizationTolerance
                ) else { return nil }
                let difference = diffInverse(old, new) ?? diffOverlap(old, new)
                return (message, (new, difference))
            }
        )
    }

    private static func encodedPNG(_ image: UIImage) -> Data {
        if let data = image.pngData() {
            return data
        }
        guard let fallbackData = emptyImage().pngData() else {
            preconditionFailure("The fallback snapshot image could not be encoded as PNG.")
        }
        return fallbackData
    }

    private static func decodedImage(from data: Data, scale: CGFloat) -> UIImage {
        guard let image = UIImage(data: data, scale: scale) else {
            preconditionFailure("Snapshot data could not be decoded as an image.")
        }
        return image
    }
    
    /// Used when the image size has no width or no height to generated the default empty image
    private static func emptyImage() -> UIImage {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 80))
        label.backgroundColor = .red
        label.text = "Error: No image could be generated for this view as its size was zero. Please set an explicit size in the test."
        label.textAlignment = .center
        label.numberOfLines = 3
        return label.asImage()
    }
    
    private static func diffOverlap(_ old: Value, _ new: Value) -> Value {
        guard let oldCgImage = old.cgImage, let newCgImage = new.cgImage else {
            return emptyImage()
        }
        let oldPixelSize = CGSize(width: oldCgImage.width, height: oldCgImage.height)
        let newPixelSize = CGSize(width: newCgImage.width, height: newCgImage.height)
        let size = CGSize(
            width: max(oldPixelSize.width, newPixelSize.width),
            height: max(oldPixelSize.height, newPixelSize.height)
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.preferredRange = .standard
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.setFillColorSpace(imageContextColorSpace)
            UIImage(cgImage: newCgImage, scale: 1, orientation: .up).draw(at: .zero)
            UIImage(cgImage: oldCgImage, scale: 1, orientation: .up)
                .draw(at: .zero, blendMode: .difference, alpha: 1)

            guard oldPixelSize != newPixelSize else { return }
            context.cgContext.setLineWidth(2)
            context.cgContext.setStrokeColor(UIColor.systemPink.cgColor)
            context.cgContext.stroke(CGRect(origin: .zero, size: newPixelSize).insetBy(dx: 1, dy: 1))
            context.cgContext.setStrokeColor(UIColor.systemTeal.cgColor)
            context.cgContext.stroke(CGRect(origin: .zero, size: oldPixelSize).insetBy(dx: 1, dy: 1))
        }
    }
    
    private static func diffInverse(_ old: Value, _ new: Value) -> Value? {
        guard let oldCgImage = old.cgImage, let newCgImage = new.cgImage
        else { return nil }
        guard oldCgImage.width == newCgImage.width,
              oldCgImage.height == newCgImage.height
        else { return nil }
        guard let contextOld = context(for: oldCgImage),
              let contextNew = context(for: newCgImage)
        else { return nil }
        // Get the pixel data from the context
        guard let dataOld = contextOld.data, let dataNew = contextNew.data else { return nil }
        let pixelBufferOld = dataOld.assumingMemoryBound(to: UInt8.self)
        let pixelBufferNew = dataNew.assumingMemoryBound(to: UInt8.self)
        // Create a new context for the difference image
        guard let diffContext = context(for: oldCgImage, draw: false) else { return nil }
        // Iterate through pixels and draw differences
        let width = oldCgImage.width
        let height = oldCgImage.height
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r1 = pixelBufferOld[offset]
                let g1 = pixelBufferOld[offset + 1]
                let b1 = pixelBufferOld[offset + 2]
                let a1 = pixelBufferOld[offset + 3]
                let r2 = pixelBufferNew[offset]
                let g2 = pixelBufferNew[offset + 1]
                let b2 = pixelBufferNew[offset + 2]
                let a2 = pixelBufferNew[offset + 3]
                
                if r1 != r2 || g1 != g2 || b1 != b2 || a1 != a2 {
                    let alpha = a1 == a2 ? 1 : (a1 > a2 ? a1 - a2 : a2 - a1)
                    let colorSame = r1 == r2 && g1 == g2 && b1 == b2
                    let isOverlap = a1 == 0
                    diffContext.setFillColor(red: isOverlap ? 0 : 1, green: colorSame ? 1 : 0, blue: isOverlap ? 1 : 0, alpha: CGFloat(alpha))
                    diffContext.fill(CGRect(x: x, y: height - y - 1, width: 1, height: 1))
                }
            }
        }
        guard let outputCGImage = diffContext.makeImage() else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
}

struct CanonicalSnapshot {
    let width: Int
    let height: Int
    let scale: CGFloat
    let pointSize: CGSize
    let rgba: [UInt8]
}

struct CanonicalRGBA: Hashable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8

    subscript(channel: Int) -> UInt8 {
        switch channel {
        case 0: red
        case 1: green
        case 2: blue
        default: alpha
        }
    }
}

let canonicalBytesPerPixel = 4

/// Both renderers are converted to the same 8-bit premultiplied sRGB representation. One final
/// channel step is accepted as serialization quantization; there is no percentage pixel budget.
let canonicalQuantizationTolerance: UInt8 = 1

private func strictCanonicalDifferenceMessage(_ old: UIImage, _ new: UIImage) -> String? {
    guard let oldCanonical = canonicalSnapshot(old) else {
        return "Reference image could not be normalized."
    }
    guard let newCanonical = canonicalSnapshot(new) else {
        return "Newly-taken snapshot could not be normalized."
    }
    if let message = canonicalGeometryDifferenceMessage(
        old,
        oldCanonical,
        new,
        newCanonical
    ) {
        return message
    }

    let pixelCount = oldCanonical.width * oldCanonical.height
    for pixelIndex in 0..<pixelCount where !canonicalPixelsMatch(
        oldCanonical,
        at: pixelIndex,
        newCanonical,
        at: pixelIndex,
        tolerance: canonicalQuantizationTolerance
    ) {
        return "Canonical premultiplied sRGB differs at pixel \(pixelIndex)."
    }
    return nil
}

func canonicalGeometryDifferenceMessage(
    _ old: UIImage,
    _ oldCanonical: CanonicalSnapshot,
    _ new: UIImage,
    _ newCanonical: CanonicalSnapshot
) -> String? {
    guard oldCanonical.width == newCanonical.width,
          oldCanonical.height == newCanonical.height else {
        return "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
    }
    guard oldCanonical.scale == newCanonical.scale,
          oldCanonical.pointSize == newCanonical.pointSize else {
        return "Newly-taken snapshot scale/point size \(newCanonical.scale)/\(newCanonical.pointSize) does not match reference \(oldCanonical.scale)/\(oldCanonical.pointSize)."
    }
    return nil
}

func canonicalPixelsMatch(
    _ lhs: CanonicalSnapshot,
    at lhsPixelIndex: Int,
    _ rhs: CanonicalSnapshot,
    at rhsPixelIndex: Int,
    tolerance: UInt8
) -> Bool {
    let lhsByteIndex = lhsPixelIndex * canonicalBytesPerPixel
    let rhsByteIndex = rhsPixelIndex * canonicalBytesPerPixel
    for channel in 0..<canonicalBytesPerPixel where channelDifference(
        lhs.rgba[lhsByteIndex + channel],
        rhs.rgba[rhsByteIndex + channel]
    ) > tolerance {
        return false
    }
    return true
}

func canonicalSnapshot(_ image: UIImage) -> CanonicalSnapshot? {
    autoreleasepool {
        guard let data = image.pngData(),
              let persisted = UIImage(data: data, scale: image.scale),
              let decodedImage = persisted.cgImage,
              let cgImage = canonicalSourceImage(decodedImage),
              cgImage.width > 0,
              cgImage.height > 0
        else { return nil }

        let byteCount = cgImage.width * cgImage.height * canonicalBytesPerPixel
        var rgba = [UInt8](repeating: 0, count: byteCount)
        guard context(for: cgImage, data: &rgba)?.data != nil else { return nil }

        return CanonicalSnapshot(
            width: cgImage.width,
            height: cgImage.height,
            scale: image.scale,
            pointSize: image.size,
            rgba: rgba
        )
    }
}

/// Extended-range PNGs produced by UIGraphicsImageRenderer persist associated 16-bit channels,
/// while ImageIO can decode their alpha metadata as straight. Reinterpret only that encoding as
/// premultiplied before the shared sRGB draw so alpha is not applied for a second time.
private func canonicalSourceImage(_ image: CGImage) -> CGImage? {
    guard image.bitsPerComponent > 8,
          image.colorSpace?.name == CGColorSpace.displayP3
    else { return image }

    let premultipliedAlphaInfo: CGImageAlphaInfo
    switch image.alphaInfo {
    case .last:
        premultipliedAlphaInfo = .premultipliedLast
    case .first:
        premultipliedAlphaInfo = .premultipliedFirst
    default:
        return image
    }

    guard let colorSpace = image.colorSpace,
          let provider = image.dataProvider
    else { return nil }
    let bitmapInfo = CGBitmapInfo(
        rawValue: image.bitmapInfo.rawValue
            & ~CGBitmapInfo.alphaInfoMask.rawValue
            | premultipliedAlphaInfo.rawValue
    )
    return CGImage(
        width: image.width,
        height: image.height,
        bitsPerComponent: image.bitsPerComponent,
        bitsPerPixel: image.bitsPerPixel,
        bytesPerRow: image.bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo,
        provider: provider,
        decode: image.decode,
        shouldInterpolate: image.shouldInterpolate,
        intent: image.renderingIntent
    )
}
// Remap snapshot and reference to the same device-independent color space.
private let imageContextColorSpace: CGColorSpace = {
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
        preconditionFailure("The sRGB color space is unavailable.")
    }
    return colorSpace
}()
private let imageContextBitsPerComponent = 8
private let imageContextBytesPerPixel = 4
// Independent color-space conversion and 8-bit normalization can place equivalent renders two
// channel steps apart.
private let imageContextColorTolerance: UInt8 = 2
private let imageContextAlphaTolerance: UInt8 = 1
// Quantization differences may affect at most 0.01% of the image.
private let imageContextPixelsPerAllowedQuantizationDifference = 10_000

private func compare(
    _ old: UIImage,
    _ new: UIImage,
    precision: Float,
    perceptualPrecision: Float,
    alphaTolerance: UInt8,
    allowsQuantizationTolerance: Bool
) -> String? {
    guard let oldCgImage = old.cgImage else {
        return "Reference image could not be loaded."
    }
    guard let newCgImage = new.cgImage else {
        return "Newly-taken snapshot could not be loaded."
    }
    guard newCgImage.width != 0, newCgImage.height != 0 else {
        return "Newly-taken snapshot is empty."
    }
    guard oldCgImage.width == newCgImage.width, oldCgImage.height == newCgImage.height else {
        return "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
    }
//    guard oldCgImage.colorSpace == newCgImage.colorSpace else {
//        return "Newly-taken snapshot colorSpace@\(String(describing: newCgImage.colorSpace)) does not match reference@\(String(describing: oldCgImage.colorSpace))."
//    }
    
    let pixelCount = oldCgImage.width * oldCgImage.height
    let byteCount = imageContextBytesPerPixel * pixelCount
    var oldBytes = [UInt8](repeating: 0, count: byteCount)
    guard let oldData = context(for: oldCgImage, data: &oldBytes)?.data else {
        return "Reference image's data could not be loaded."
    }
    if let newContext = context(for: newCgImage), let newData = newContext.data {
        if memcmp(oldData, newData, byteCount) == 0 { return nil }
    }
    var newerBytes = [UInt8](repeating: 0, count: byteCount)
    guard
        let pngData = new.pngData(),
        let newerCgImage = UIImage(data: pngData)?.cgImage,
        let newerContext = context(for: newerCgImage, data: &newerBytes),
        let newerData = newerContext.data
    else {
        return "Newly-taken snapshot's data could not be loaded."
    }
    if memcmp(oldData, newerData, byteCount) == 0 { return nil }
    if allowsQuantizationTolerance,
       matchesWithinQuantizationTolerance(oldData, newerData, byteCount: byteCount) {
        return nil
    }
    if precision >= 1, perceptualPrecision >= 1 {
        return "Newly-taken snapshot does not match reference."
    }
    if perceptualPrecision < 1 {
        if let alphaDifference = alphaDifferenceMessage(
            oldData,
            newerData,
            pixelCount: pixelCount,
            tolerance: alphaTolerance
        ) {
            return alphaDifference
        }
        return perceptuallyCompare(
            CIImage(cgImage: oldCgImage),
            CIImage(cgImage: newCgImage),
            pixelPrecision: precision,
            perceptualPrecision: perceptualPrecision
        )
    } else {
        let byteCountThreshold = Int((1 - precision) * Float(byteCount))
        var differentByteCount = 0
        // NB: We are purposely using a verbose 'while' loop instead of a 'for in' loop.  When the
        //     compiler doesn't have optimizations enabled, like in test targets, a `while` loop is
        //     significantly faster than a `for` loop for iterating through the elements of a memory
        //     buffer. Details can be found in [SR-6983](https://github.com/apple/swift/issues/49531)
        var index = 0
        while index < byteCount {
            defer { index += 1 }
            if oldBytes[index] != newerBytes[index] {
                differentByteCount += 1
            }
        }
        if differentByteCount > byteCountThreshold {
            let actualPrecision = 1 - Float(differentByteCount) / Float(byteCount)
            return "Actual image precision \(actualPrecision) is less than required \(precision)"
        }
    }
    return nil
}

private func alphaDifferenceMessage(
    _ oldData: UnsafeMutableRawPointer,
    _ newData: UnsafeMutableRawPointer,
    pixelCount: Int,
    tolerance: UInt8
) -> String? {
    let oldBytes = oldData.assumingMemoryBound(to: UInt8.self)
    let newBytes = newData.assumingMemoryBound(to: UInt8.self)
    var maximumDifference: UInt8 = 0
    var differentPixelCount = 0
    var pixelIndex = 0

    while pixelIndex < pixelCount {
        let alphaIndex = pixelIndex * imageContextBytesPerPixel + 3
        let difference = channelDifference(oldBytes[alphaIndex], newBytes[alphaIndex])
        if difference > tolerance {
            differentPixelCount += 1
            maximumDifference = max(maximumDifference, difference)
        }
        pixelIndex += 1
    }

    guard differentPixelCount > 0 else { return nil }
    return "Alpha channel differs in \(differentPixelCount) pixels; maximum difference \(maximumDifference) exceeds tolerance \(tolerance)."
}

private func matchesWithinQuantizationTolerance(
    _ oldData: UnsafeMutableRawPointer,
    _ newData: UnsafeMutableRawPointer,
    byteCount: Int
) -> Bool {
    let oldBytes = oldData.assumingMemoryBound(to: UInt8.self)
    let newBytes = newData.assumingMemoryBound(to: UInt8.self)
    let pixelCount = byteCount / imageContextBytesPerPixel
    let allowedChangedPixelCount = pixelCount / imageContextPixelsPerAllowedQuantizationDifference
    guard allowedChangedPixelCount > 0 else { return false }
    var changedPixelCount = 0
    var index = 0
    while index < byteCount {
        var pixelChanged = false
        let oldAlpha = oldBytes[index + 3]
        let newAlpha = newBytes[index + 3]
        for channel in 0..<3 {
            let difference = channelDifference(oldBytes[index + channel], newBytes[index + channel])
            if difference > imageContextColorTolerance { return false }
            pixelChanged = pixelChanged || difference > 0
        }
        let alphaDifference = channelDifference(oldAlpha, newAlpha)
        if alphaDifference > imageContextAlphaTolerance { return false }
        pixelChanged = pixelChanged || alphaDifference > 0
        if pixelChanged {
            changedPixelCount += 1
            if changedPixelCount > allowedChangedPixelCount { return false }
        }
        index += imageContextBytesPerPixel
    }
    return true
}

func channelDifference(_ lhs: UInt8, _ rhs: UInt8) -> UInt8 {
    lhs >= rhs ? lhs - rhs : rhs - lhs
}

private func context(for cgImage: CGImage, data: UnsafeMutableRawPointer? = nil, draw: Bool = true) -> CGContext? {
    let bytesPerRow = cgImage.width * imageContextBytesPerPixel
    guard let context = CGContext(
        data: data,
        width: cgImage.width,
        height: cgImage.height,
        bitsPerComponent: imageContextBitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: imageContextColorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
    else { return nil }
    if draw {
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    }
    return context
}

#endif

#if os(iOS) || os(tvOS) || os(macOS)
import Accelerate.vImage
import CoreImage.CIKernel
import MetalPerformanceShaders

@available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
func perceptuallyCompare(
    _ old: CIImage, _ new: CIImage, pixelPrecision: Float, perceptualPrecision: Float
) -> String? {
    // Calculate the deltaE values. Each pixel is a value between 0-100.
    // 0 means no difference, 100 means completely opposite.
    let deltaOutputImage = old.applyingLabDeltaE(new)
    // Setting the working color space and output color space to NSNull disables color management. This is appropriate when the output
    // of the operations is computational instead of an image intended to be displayed.
    let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
    let deltaThreshold = (1 - perceptualPrecision) * 100
    let actualPixelPrecision: Float
    var maximumDeltaE: Float = 0
    
    // Metal is supported by all iOS/tvOS devices (2013 models or later) and Macs (2012 models or later).
    // Older devices do not support iOS/tvOS 13 and macOS 10.15 which are the minimum versions of swift-snapshot-testing.
    // However, some virtualized hardware do not have GPUs and therefore do not support Metal.
    // In this case, macOS falls back to a CPU-based OpenGL ES renderer that silently fails when a Metal command is issued.
    // We need to check for Metal device support and fallback to CPU based vImage buffer iteration.
    if ThresholdImageProcessorKernel.isSupported {
        // Fast path - Metal processing
        guard
            let thresholdOutputImage = try? deltaOutputImage.applyingThreshold(deltaThreshold),
            let averagePixel = thresholdOutputImage.applyingAreaAverage().renderSingleValue(in: context)
        else {
            return "Newly-taken snapshot's data could not be processed."
        }
        actualPixelPrecision = 1 - averagePixel
        if actualPixelPrecision < pixelPrecision {
            maximumDeltaE = deltaOutputImage.applyingAreaMaximum().renderSingleValue(in: context) ?? 0
        }
    } else {
        // Slow path - CPU based vImage buffer iteration
        guard let buffer = deltaOutputImage.render(in: context) else {
            return "Newly-taken snapshot could not be processed."
        }
        defer { buffer.free() }
        var failingPixelCount: Int = 0
        // rowBytes must be a multiple of 8, so vImage_Buffer pads the end of each row with bytes to meet the multiple of 0 requirement.
        // We must do 2D iteration of the vImage_Buffer in order to avoid loading the padding garbage bytes at the end of each row.
        //
        // NB: We are purposely using a verbose 'while' loop instead of a 'for in' loop.  When the
        //     compiler doesn't have optimizations enabled, like in test targets, a `while` loop is
        //     significantly faster than a `for` loop for iterating through the elements of a memory
        //     buffer. Details can be found in [SR-6983](https://github.com/apple/swift/issues/49531)
        let componentStride = MemoryLayout<Float>.stride
        var line = 0
        while line < buffer.height {
            defer { line += 1 }
            let lineOffset = buffer.rowBytes * line
            var column = 0
            while column < buffer.width {
                defer { column += 1 }
                let byteOffset = lineOffset + column * componentStride
                let deltaE = buffer.data.load(fromByteOffset: byteOffset, as: Float.self)
                if deltaE > deltaThreshold {
                    failingPixelCount += 1
                    if deltaE > maximumDeltaE {
                        maximumDeltaE = deltaE
                    }
                }
            }
        }
        let failingPixelPercent = Float(failingPixelCount) / Float(deltaOutputImage.extent.width * deltaOutputImage.extent.height)
        actualPixelPrecision = 1 - failingPixelPercent
    }
    
    guard actualPixelPrecision < pixelPrecision else { return nil }
    // The actual perceptual precision is the perceptual precision of the pixel with the highest DeltaE.
    // DeltaE is in a 0-100 scale, so we need to divide by 100 to transform it to a percentage.
    let minimumPerceptualPrecision = 1 - min(maximumDeltaE / 100, 1)
    return """
      The percentage of pixels that match \(actualPixelPrecision) is less than required \(pixelPrecision)
      The lowest perceptual color precision \(minimumPerceptualPrecision) is less than required \(perceptualPrecision)
      """
}

extension CIImage {
    func applyingLabDeltaE(_ other: CIImage) -> CIImage {
        applyingFilter("CILabDeltaE", parameters: ["inputImage2": other])
    }
    
    func applyingThreshold(_ threshold: Float) throws -> CIImage {
        try ThresholdImageProcessorKernel.apply(
            withExtent: extent,
            inputs: [self],
            arguments: [ThresholdImageProcessorKernel.inputThresholdKey: threshold]
        )
    }
    
    func applyingAreaAverage() -> CIImage {
        applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: extent])
    }
    
    func applyingAreaMaximum() -> CIImage {
        applyingFilter("CIAreaMaximum", parameters: [kCIInputExtentKey: extent])
    }
    
    func renderSingleValue(in context: CIContext) -> Float? {
        guard let buffer = render(in: context) else { return nil }
        defer { buffer.free() }
        return buffer.data.load(fromByteOffset: 0, as: Float.self)
    }
    
    func render(in context: CIContext, format: CIFormat = CIFormat.Rh) -> vImage_Buffer? {
        // Some hardware configurations (virtualized CPU renderers) do not support 32-bit float output formats,
        // so use a compatible 16-bit float format and convert the output value to 32-bit floats.
        guard
            var buffer16 = try? vImage_Buffer(
                width: Int(extent.width), height: Int(extent.height), bitsPerPixel: 16)
        else { return nil }
        defer { buffer16.free() }
        context.render(
            self,
            toBitmap: buffer16.data,
            rowBytes: buffer16.rowBytes,
            bounds: extent,
            format: format,
            colorSpace: nil
        )
        guard
            var buffer32 = try? vImage_Buffer(
                width: Int(buffer16.width), height: Int(buffer16.height), bitsPerPixel: 32),
            vImageConvert_Planar16FtoPlanarF(&buffer16, &buffer32, 0) == kvImageNoError
        else { return nil }
        return buffer32
    }
}

// Copied from https://developer.apple.com/documentation/coreimage/ciimageprocessorkernel
@available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
final class ThresholdImageProcessorKernel: CIImageProcessorKernel {
    static let inputThresholdKey = "thresholdValue"
    static let device = MTLCreateSystemDefaultDevice()
    
    static var isSupported: Bool {
        guard let device = device else {
            return false
        }
#if targetEnvironment(simulator)
        guard #available(iOS 14.0, tvOS 14.0, *) else {
            // The MPSSupportsMTLDevice method throws an exception on iOS/tvOS simulators < 14.0
            return false
        }
#endif
        return MPSSupportsMTLDevice(device)
    }
    
    override class func process(
        with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?,
        output: CIImageProcessorOutput
    ) throws {
        guard
            let device = device,
            let commandBuffer = output.metalCommandBuffer,
            let input = inputs?.first,
            let sourceTexture = input.metalTexture,
            let destinationTexture = output.metalTexture,
            let thresholdValue = arguments?[inputThresholdKey] as? Float
        else {
            return
        }
        
        let threshold = MPSImageThresholdBinary(
            device: device,
            thresholdValue: thresholdValue,
            maximumValue: 1.0,
            linearGrayColorTransform: nil
        )
        
        threshold.encode(
            commandBuffer: commandBuffer,
            sourceTexture: sourceTexture,
            destinationTexture: destinationTexture
        )
    }
}
#endif
