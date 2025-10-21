//
//  Bundle+Extensions.swift
//  WrapKit
//
//  Created by Stanislav Li on 7/8/25.
//

import Foundation

public extension Bundle {
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    static var isAppStoreBuild: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }

        let receiptPath = appStoreReceiptURL.path

        if receiptPath.contains("sandboxReceipt") { return false }
        if receiptPath.contains("CoreSimulator") { return false }

        return FileManager.default.fileExists(atPath: receiptPath)
    }
}
