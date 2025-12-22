// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif

public final class SearchBarOutputSpy: SearchBarOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case displayModel(model: SearchBarPresentableModel?)
        case displayTextField(textField: TextInputPresentableModel?)
        case displayLeftView(leftView: ButtonPresentableModel?)
        case displayRightView(rightView: ButtonPresentableModel?)
        case displayPlaceholder(placeholder: String?)
        case displayBackgroundColor(backgroundColor: Color?)
        case displaySpacing(spacing: CGFloat)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedDisplayModel: [SearchBarPresentableModel?] = []
    public private(set) var capturedDisplayTextField: [TextInputPresentableModel?] = []
    public private(set) var capturedDisplayLeftView: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayRightView: [ButtonPresentableModel?] = []
    public private(set) var capturedDisplayPlaceholder: [String?] = []
    public private(set) var capturedDisplayBackgroundColor: [Color?] = []
    public private(set) var capturedDisplaySpacing: [CGFloat] = []


    // MARK: - SearchBarOutput methods
    public func display(model: SearchBarPresentableModel?) {
        capturedDisplayModel.append(model)
        messages.append(.displayModel(model: model))
    }
    public func display(textField: TextInputPresentableModel?) {
        capturedDisplayTextField.append(textField)
        messages.append(.displayTextField(textField: textField))
    }
    public func display(leftView: ButtonPresentableModel?) {
        capturedDisplayLeftView.append(leftView)
        messages.append(.displayLeftView(leftView: leftView))
    }
    public func display(rightView: ButtonPresentableModel?) {
        capturedDisplayRightView.append(rightView)
        messages.append(.displayRightView(rightView: rightView))
    }
    public func display(placeholder: String?) {
        capturedDisplayPlaceholder.append(placeholder)
        messages.append(.displayPlaceholder(placeholder: placeholder))
    }
    public func display(backgroundColor: Color?) {
        capturedDisplayBackgroundColor.append(backgroundColor)
        messages.append(.displayBackgroundColor(backgroundColor: backgroundColor))
    }
    public func display(spacing: CGFloat) {
        capturedDisplaySpacing.append(spacing)
        messages.append(.displaySpacing(spacing: spacing))
    }

    // MARK: - Properties
}
