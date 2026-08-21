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
    case notificationSettings
    case defaultAppsSettings
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
            return url
            
        case .urlString(let urlString):
            return urlString.asUrl
            
        case .appSettings:
            return URL(string: UIApplication.openSettingsURLString)
            
        case .notificationSettings:
            guard #available(iOS 16.0, *) else {
                return nil
            }
            
            return URL(string: UIApplication.openNotificationSettingsURLString)
        case .defaultAppsSettings:
            guard #available(iOS 18.3, *) else {
                return nil
            }
            
            return URL(string: UIApplication.openDefaultApplicationsSettingsURLString)
        }
    }
}
#endif
