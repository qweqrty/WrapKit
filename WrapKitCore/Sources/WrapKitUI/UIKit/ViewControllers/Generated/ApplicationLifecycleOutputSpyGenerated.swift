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
#if canImport(UIKit)
import UIKit
#endif

public final class ApplicationLifecycleOutputSpy: ApplicationLifecycleOutput {

    public init() {}

    enum Message: HashableWithReflection {
        case applicationWillEnterForeground()
        case applicationDidEnterBackground()
        case applicationDidBecomeActive()
        case applicationWillResignActive()
        case applicationDidChange(userInterfaceStyle: UserInterfaceStyle)
        case composed(with: ApplicationLifecycleOutput)
    }

    private(set) var messages: [Message] = []

    // MARK: - Captured values
    private(set) var capturedApplicationDidChangeUserInterfaceStyle: [UserInterfaceStyle] = []
    private(set) var capturedComposedOutput: [ApplicationLifecycleOutput] = []


    // MARK: - ApplicationLifecycleOutput methods
    public func applicationWillEnterForeground() {
        messages.append(.applicationWillEnterForeground())
    }
    public func applicationDidEnterBackground() {
        messages.append(.applicationDidEnterBackground())
    }
    public func applicationDidBecomeActive() {
        messages.append(.applicationDidBecomeActive())
    }
    public func applicationWillResignActive() {
        messages.append(.applicationWillResignActive())
    }
    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        capturedApplicationDidChangeUserInterfaceStyle.append(userInterfaceStyle)
        messages.append(.applicationDidChange(userInterfaceStyle: userInterfaceStyle))
    }
    public func composed(with output: ApplicationLifecycleOutput) {
        capturedComposedOutput.append(output)
        messages.append(.composed(with: output))
    }

    // MARK: - Properties
}
