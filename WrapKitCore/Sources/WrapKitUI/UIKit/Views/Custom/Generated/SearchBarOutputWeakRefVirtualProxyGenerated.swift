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

extension SearchBarOutput {
    public var weakReferenced: any SearchBarOutput {
        return WeakRefVirtualProxy(self)
    }
}

extension WeakRefVirtualProxy: SearchBarOutput where T: SearchBarOutput {

    public func display(model: SearchBarPresentableModel?) {
        object?.display(model: model)
    }
    public func display(textField: TextInputPresentableModel?) {
        object?.display(textField: textField)
    }
    public func display(leftView: ButtonPresentableModel?) {
        object?.display(leftView: leftView)
    }
    public func display(rightView: ButtonPresentableModel?) {
        object?.display(rightView: rightView)
    }
    public func display(placeholder: String?) {
        object?.display(placeholder: placeholder)
    }
    public func display(backgroundColor: Color?) {
        object?.display(backgroundColor: backgroundColor)
    }
    public func display(spacing: CGFloat) {
        object?.display(spacing: spacing)
    }

}
#endif
