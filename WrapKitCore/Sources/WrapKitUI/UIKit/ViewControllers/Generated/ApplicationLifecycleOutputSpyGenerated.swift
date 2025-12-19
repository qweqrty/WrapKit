// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(UIKit)
import UIKit
#endif

public final class ApplicationLifecycleOutputSpy: ApplicationLifecycleOutput {

    public init() {}

    public enum Message: HashableWithReflection {
        case applicationWillEnterForeground
        case applicationDidEnterBackground
        case applicationDidBecomeActive
        case applicationWillResignActive
        case applicationDidChangeUserInterfaceStyle(userInterfaceStyle: UserInterfaceStyle)
        case composedOutput(with: ApplicationLifecycleOutput)
    }

    public private(set) var messages: [Message] = []

    // MARK: - Captured values
    public private(set) var capturedApplicationDidChangeUserInterfaceStyle: [UserInterfaceStyle] = []
    public private(set) var capturedComposedOutput: [ApplicationLifecycleOutput] = []


    // MARK: - ApplicationLifecycleOutput methods
    public func applicationWillEnterForeground() {
        messages.append(.applicationWillEnterForeground)
    }
    public func applicationDidEnterBackground() {
        messages.append(.applicationDidEnterBackground)
    }
    public func applicationDidBecomeActive() {
        messages.append(.applicationDidBecomeActive)
    }
    public func applicationWillResignActive() {
        messages.append(.applicationWillResignActive)
    }
    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        capturedApplicationDidChangeUserInterfaceStyle.append(userInterfaceStyle)
        messages.append(.applicationDidChangeUserInterfaceStyle(userInterfaceStyle: userInterfaceStyle))
    }
    public func composed(with output: ApplicationLifecycleOutput) {
        capturedComposedOutput.append(output)
        messages.append(.composedOutput(with: output))
    }

    // MARK: - Properties
}
