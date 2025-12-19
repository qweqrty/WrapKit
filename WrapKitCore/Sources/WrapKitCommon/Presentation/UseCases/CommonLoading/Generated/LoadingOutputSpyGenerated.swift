// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
import WrapKit
#if canImport(UIKit)
import UIKit
#endif
import WrapKit

public final class LoadingOutputSpy: LoadingOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayIsLoading(isLoading: Bool)
        case NVActivityLoaderOnView(onView: UIView, type: NVActivityIndicatorType, size: CGSize, padding: UIEdgeInsets, loadingViewColor: UIColor, wrapperViewColor: UIColor)
        case setIsLoading(Bool?)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayIsLoading: [(Bool)] = []
    public private(set) var capturedNVActivityLoaderOnViewTypeSizePaddingLoadingViewColorWrapperViewColor: [(UIView, NVActivityIndicatorType, CGSize, UIEdgeInsets, UIColor, UIColor)] = []
    public private(set) var capturedSetIsLoading: [Bool?] = []

    // MARK: - LoadingOutput methods
    public func display(isLoading: Bool) {
        capturedDisplayIsLoading.append((isLoading))
        messages.append(.displayIsLoading(isLoading: isLoading))
    }
    // Static method: NVActivityLoader(onView: UIView, type: NVActivityIndicatorType = .circleStrokeSpin, size: CGSize = .init(width: 80, height: 80), padding: UIEdgeInsets = .init(top: 25, left: 25, bottom: 25, right: 25), loadingViewColor: UIColor, wrapperViewColor: UIColor)

    // MARK: - Properties
    public var isLoading: Bool? {
        didSet {
            capturedSetIsLoading.append(isLoading)
            messages.append(.setIsLoading(isLoading))
        }
    }
}
