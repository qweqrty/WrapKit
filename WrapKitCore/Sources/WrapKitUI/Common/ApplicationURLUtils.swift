//
//  ApplicationURLUtils.swift
//  WrapKit
//
//  Created by Gulzat Zheenbek kyzy on 21/8/26.
//

public enum URLTarget {
    case url(URL)
    case urlString(String)
    case appSettings
}

#if canImport(UIKit)
import UIKit

public enum ApplicationURLUtils {
    
    @discardableResult
    public static func open(
        _ destination: URLTarget,
        options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:],
        completionHandler: ((Bool) -> Void)? = nil
    ) -> Bool {
        guard let url = makeURL(from: destination),
              UIApplication.shared.canOpenURL(url) else {
            completionHandler?(false)
            return false
        }
        
        UIApplication.shared.open(
            url,
            options: options,
            completionHandler: completionHandler
        )
        
        return true
    }
    
    private static func makeURL(from destination: URLTarget) -> URL? {
        switch destination {
        case .url(let url):
            url
        case .urlString(let urlString):
            urlString.asUrl
        case .appSettings:
            URL(string: UIApplication.openSettingsURLString)
        }
    }
}
#endif
