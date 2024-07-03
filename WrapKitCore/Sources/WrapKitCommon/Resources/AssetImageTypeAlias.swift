//
//  AssetImageTypeAlias.swift
//  WrapKit
//
//  Created by Stanislav Li on 3/7/24.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#elseif os(tvOS) || os(watchOS)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public typealias AssetImageTypeAlias = ImageAsset.Image

public struct ImageAsset {
    public init(name: String) {
        self.name = name
    }
    
    public fileprivate(set) var name: String
    
#if os(macOS)
    public typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
    public typealias Image = UIImage
#endif
    
    @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
    public var image: Image {
        let bundle = BundleToken.bundle
#if os(iOS) || os(tvOS)
        let image = Image(named: name, in: bundle, compatibleWith: nil)
#elseif os(macOS)
        let name = NSImage.Name(self.name)
        let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
#elseif os(watchOS)
        let image = Image(named: name)
#endif
        guard let result = image else {
            fatalError("Unable to load image asset named \(name).")
        }
        return result
    }
    
#if os(iOS) || os(tvOS)
    @available(iOS 8.0, tvOS 9.0, *)
    public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
        let bundle = BundleToken.bundle
        guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
            fatalError("Unable to load image asset named \(name).")
        }
        return result
    }
#endif
    
#if canImport(SwiftUI)
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public var swiftUIImage: SwiftUI.Image {
        SwiftUI.Image(asset: self)
    }
#endif
}

public extension ImageAsset.Image {
    @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
    @available(macOS, deprecated,
               message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
    convenience init?(asset: ImageAsset) {
#if os(iOS) || os(tvOS)
        let bundle = BundleToken.bundle
        self.init(named: asset.name, in: bundle, compatibleWith: nil)
#elseif os(macOS)
        self.init(named: NSImage.Name(asset.name))
#elseif os(watchOS)
        self.init(named: asset.name)
#endif
    }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
    init(asset: ImageAsset) {
        let bundle = BundleToken.bundle
        self.init(asset.name, bundle: bundle)
    }
    
    init(asset: ImageAsset, label: Text) {
        let bundle = BundleToken.bundle
        self.init(asset.name, bundle: bundle, label: label)
    }
    
    init(decorative asset: ImageAsset) {
        let bundle = BundleToken.bundle
        self.init(decorative: asset.name, bundle: bundle)
    }
}
#endif
