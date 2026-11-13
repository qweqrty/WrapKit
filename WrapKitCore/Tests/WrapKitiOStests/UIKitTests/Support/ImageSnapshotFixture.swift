#if os(iOS) || targetEnvironment(macCatalyst)
import Foundation

enum ImageSnapshotFixture: String {
    case light = "button-image-light"
    case dark = "button-image-dark"

    var url: URL {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: BundleToken.self)
        #endif
        guard let url = bundle.url(forResource: rawValue, withExtension: "png") else {
            preconditionFailure("Missing image snapshot fixture: \(rawValue).png")
        }
        return url
    }

    var urlString: String {
        url.absoluteString
    }
}

private final class BundleToken {}
#endif
