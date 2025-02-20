import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(Photos)
import Photos
#endif

#if canImport(CoreLocation)
import CoreLocation
#endif

#if canImport(Contacts)
import Contacts
#endif

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

#if canImport(UserNotifications)
import UserNotifications
#endif

public final class AppPermissions {
    // MARK: - Camera Permission
    public static func requestCameraAccess(permissionCallback: @escaping ((Bool) -> Void)) {
        #if canImport(AVFoundation)
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                permissionCallback(true)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    permissionCallback(granted)
                }
            }
        default:
            DispatchQueue.main.async {
                permissionCallback(false)
            }
        }
        #else
        permissionCallback(false)
        #endif
    }

    // MARK: - Photo Library Permission
    public static func requestLibraryAccess(permissionCallback: @escaping ((Bool) -> Void)) {
        #if canImport(Photos)
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            DispatchQueue.main.async {
                permissionCallback(true)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if #available(iOS 14, *), status == .limited {
                        permissionCallback(true)
                    } else if status == .authorized {
                        permissionCallback(true)
                    } else {
                        permissionCallback(false)
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                permissionCallback(false)
            }
        }
        #else
        permissionCallback(false)
        #endif
    }

    // MARK: - Location Permission
    public static func requestLocationAccess(status: CLAuthorizationStatus, permissionCallback: @escaping ((Bool) -> Void)) {
        #if canImport(CoreLocation)
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            DispatchQueue.main.async {
                permissionCallback(true)
            }
        case .notDetermined, .denied, .restricted:
            permissionCallback(false)
        default:
            permissionCallback(true)
        }
        #else
        permissionCallback(false)
        #endif
    }

    // MARK: - Contacts Permission
    public static func requestContactAccess(permissionCallback: @escaping ((Bool) -> Void)) {
        #if canImport(Contacts)
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch status {
        case .authorized:
            permissionCallback(true)

        case .notDetermined:
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, _) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    permissionCallback(granted)
                })
            })

        case .restricted, .denied:
            permissionCallback(false)
        @unknown default:
            permissionCallback(false)
        }
        #else
        permissionCallback(false)
        #endif
    }

    // MARK: - Tracking Permission (iOS 14+)
    @available(iOS 14, *)
    public static func requestTrackingAccess(permissionCallback: @escaping ((Bool) -> Void)) {
        if #available(macOS 11.0, *) {
#if canImport(AppTrackingTransparency)
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        permissionCallback(true)
                    }
                case .notDetermined, .restricted, .denied:
                    DispatchQueue.main.async {
                        permissionCallback(false)
                    }
                @unknown default:
                    DispatchQueue.main.async {
                        permissionCallback(false)
                    }
                }
            }
#else
            permissionCallback(false)
#endif
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Notification Permission
    public static func requestNotificationAccess(permissionCallback: @escaping ((Bool) -> Void)) {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    permissionCallback(true)
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async {
                        permissionCallback(granted)
                    }
                }
            default:
                DispatchQueue.main.async {
                    permissionCallback(false)
                }
            }
        }
        #else
        permissionCallback(false)
        #endif
    }

    // MARK: - Microphone Permission
    public static func requestMicrophoneAccess(permissionCallback: @escaping ((Bool) -> Void)) {
        #if canImport(AVFoundation)
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                permissionCallback(true)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    permissionCallback(granted)
                }
            }
        default:
            permissionCallback(false)
        }
        #else
        permissionCallback(false)
        #endif
    }
}
