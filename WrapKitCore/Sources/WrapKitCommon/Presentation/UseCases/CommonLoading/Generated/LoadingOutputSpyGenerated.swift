// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if canImport(XCTest)
import XCTest
#endif
#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class LoadingOutputSpy: LoadingOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case display(isLoading: Bool)
        case NVActivityLoader(onView: UIView, type: NVActivityIndicatorType, size: CGSize, padding: UIEdgeInsets, loadingViewColor: UIColor, wrapperViewColor: UIColor)
        case setIsLoading(Bool?)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedDisplayIsLoading: [Bool] = []
    private(set) var capturedNVActivityLoaderOnView: [UIView] = []
    private(set) var capturedNVActivityLoaderType: [NVActivityIndicatorType] = []
    private(set) var capturedNVActivityLoaderSize: [CGSize] = []
    private(set) var capturedNVActivityLoaderPadding: [UIEdgeInsets] = []
    private(set) var capturedNVActivityLoaderLoadingViewColor: [UIColor] = []
    private(set) var capturedNVActivityLoaderWrapperViewColor: [UIColor] = []

    private(set) var capturedIsLoading: [Bool?] = []

    // MARK: - LoadingOutput methods
    public func display(isLoading: Bool) {
        capturedDisplayIsLoading.append(isLoading)
        messages.append(.display(isLoading: isLoading))
    }
    // Static method: NVActivityLoader(onView: UIView, type: NVActivityIndicatorType = .circleStrokeSpin, size: CGSize = .init(width: 80, height: 80), padding: UIEdgeInsets = .init(top: 25, left: 25, bottom: 25, right: 25), loadingViewColor: UIColor, wrapperViewColor: UIColor)

    // MARK: - Properties
    var isLoading: Bool? {
        didSet {
            capturedIsLoading.append(isLoading)
            messages.append(.setIsLoading(isLoading))
        }
    }
}
