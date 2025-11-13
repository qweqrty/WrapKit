#if canImport(UIKit)
#if canImport(XCTest)
import UIKit
import XCTest

public extension XCTestCase {
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData == storedSnapshotData {
            return
        }
        guard let storedSnapshot = UIImage(data: storedSnapshotData),
              let similarity = snapshot.compareWith(image: storedSnapshot)
        else {
            XCTFail("Failed to load images or calculate MSE.", file: file, line: line)
            return
        }
        
        switch similarity {
        case 99.97...100:
            return
        default:
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            XCTFail("Images are different.: \(100-similarity) %, New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
}

extension UIImage {
    
    // Function to get pixel data of the image
    func pixelData() -> [UInt8]? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: height * bytesPerRow)
        let context = CGContext(
            data: rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return Array(UnsafeBufferPointer(start: rawData, count: height * bytesPerRow))
    }
    
    // TODO: try to use more advanced https://github.com/pointfreeco/swift-snapshot-testing/pull/664/files
    // Function to calculate similarity percentage based on Mean Squared Error
    func compareWith(image: UIImage) -> Double? {
        guard let pixelData1 = self.pixelData(),
              let pixelData2 = image.pixelData(),
              pixelData1.count == pixelData2.count else { return nil }
        
        var mse: Double = 0.0
        let pixelCount = pixelData1.count / 4
        
        fastForEach(in: 0..<pixelData1.count) { i in
            let difference = Double(pixelData1[i]) - Double(pixelData2[i])
            mse += difference * difference
        }
        
        mse /= Double(pixelCount * 4)
        
        let maxDifference = 255.0 * 255.0 * 4.0
        let similarity = max(0, 100 - (mse / maxDifference) * 100)
        
        return similarity
    }
    
    /// When the compiler doesn't have optimizations enabled, like in test targets, a `while` loop is significantly faster than a `for` loop
    /// for iterating through the elements of a memory buffer. Details can be found in [SR-6983](https://github.com/apple/swift/issues/49531)
    func fastForEach(in range: Range<Int>, _ body: (Int) -> Void) {
        var index = range.lowerBound
        while index < range.upperBound {
            body(index)
            index += 1
        }
    }
}

#endif
#endif
