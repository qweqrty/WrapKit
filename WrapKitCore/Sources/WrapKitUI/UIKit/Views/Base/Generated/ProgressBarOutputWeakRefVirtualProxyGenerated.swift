// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

extension ProgressBarOutput {
    public var weakReferenced: any ProgressBarOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: ProgressBarOutput where T: ProgressBarOutput {

    public func display(model: ProgressBarPresentableModel?) {
        object?.display(model: model)
    }
    public func display(progress: CGFloat) {
        object?.display(progress: progress)
    }
    public func display(style: ProgressBarStyle?) {
        object?.display(style: style)
    }
    public func display(isHidden: Bool) {
        object?.display(isHidden: isHidden)
    }

}
#endif
