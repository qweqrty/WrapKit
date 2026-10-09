//
//  SnapshotBackgroundImage.swift
//  WrapKitTests
//
//  Created by Stanislav Li on 20/7/26.
//

import UIKit

func makeSnapshotBackgroundImage() -> UIImage {
    let size = CGSize(width: 320, height: 96)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    format.opaque = true

    return UIGraphicsImageRenderer(size: size, format: format).image { context in
        context.cgContext.setFillColor(UIColor(red: 0.82, green: 0.94, blue: 0.93, alpha: 1).cgColor)
        context.cgContext.fill(CGRect(x: 0, y: 0, width: 112, height: size.height))

        context.cgContext.setFillColor(UIColor(red: 0.91, green: 0.87, blue: 0.98, alpha: 1).cgColor)
        context.cgContext.fill(CGRect(x: 112, y: 0, width: 112, height: size.height))

        context.cgContext.setFillColor(UIColor(red: 1, green: 0.90, blue: 0.82, alpha: 1).cgColor)
        context.cgContext.fill(CGRect(x: 224, y: 0, width: 96, height: size.height))
    }
}
