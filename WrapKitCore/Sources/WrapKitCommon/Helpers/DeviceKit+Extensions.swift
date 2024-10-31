import DeviceKit
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension Device {
    var imei: String {
            #if canImport(UIKit)
            return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            #else
            return UUID().uuidString
            #endif
    }
}
