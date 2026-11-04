#!/usr/bin/env xcrun swift

import AppKit
import Foundation
import Vision

struct OCRResult: Codable {
    let path: String
    let lines: [String]
}

func recognizeText(at path: String) throws -> OCRResult {
    guard let image = NSImage(contentsOfFile: path) else {
        throw NSError(domain: "OCR", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot read image: \(path)"])
    }
    var proposedRect = CGRect(origin: .zero, size: image.size)
    guard let cgImage = image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil) else {
        throw NSError(domain: "OCR", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create CGImage: \(path)"])
    }

    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["ru-RU", "ky-KG", "en-US"]
    try VNImageRequestHandler(cgImage: cgImage).perform([request])

    let observations = (request.results ?? []).sorted {
        let verticalDifference = abs($0.boundingBox.midY - $1.boundingBox.midY)
        if verticalDifference > 0.02 {
            return $0.boundingBox.midY > $1.boundingBox.midY
        }
        return $0.boundingBox.minX < $1.boundingBox.minX
    }
    return OCRResult(path: path, lines: observations.compactMap { $0.topCandidates(1).first?.string })
}

let paths = Array(CommandLine.arguments.dropFirst())
guard paths.isEmpty == false else {
    fputs("Usage: ocr_images.swift image [image ...]\n", stderr)
    exit(2)
}

do {
    let results = try paths.map(recognizeText)
    let data = try JSONEncoder().encode(results)
    print(String(decoding: data, as: UTF8.self))
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
