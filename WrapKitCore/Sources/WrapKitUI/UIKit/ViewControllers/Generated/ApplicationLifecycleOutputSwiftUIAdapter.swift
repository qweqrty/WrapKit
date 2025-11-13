// Generated using Sourcery 2.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all

#if canImport(WrapKit)
import WrapKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif
public class ApplicationLifecycleOutputSwiftUIAdapter: ObservableObject, ApplicationLifecycleOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var applicationWillEnterForegroundState: ApplicationWillEnterForegroundState? = nil
    public struct ApplicationWillEnterForegroundState {
    }
    public func applicationWillEnterForeground() {
        applicationWillEnterForegroundState = .init(
        )
    }
    @Published public var applicationDidEnterBackgroundState: ApplicationDidEnterBackgroundState? = nil
    public struct ApplicationDidEnterBackgroundState {
    }
    public func applicationDidEnterBackground() {
        applicationDidEnterBackgroundState = .init(
        )
    }
    @Published public var applicationDidBecomeActiveState: ApplicationDidBecomeActiveState? = nil
    public struct ApplicationDidBecomeActiveState {
    }
    public func applicationDidBecomeActive() {
        applicationDidBecomeActiveState = .init(
        )
    }
    @Published public var applicationWillResignActiveState: ApplicationWillResignActiveState? = nil
    public struct ApplicationWillResignActiveState {
    }
    public func applicationWillResignActive() {
        applicationWillResignActiveState = .init(
        )
    }
    @Published public var applicationDidChangeUserInterfaceStyleState: ApplicationDidChangeUserInterfaceStyleState? = nil
    public struct ApplicationDidChangeUserInterfaceStyleState {
        public let userInterfaceStyle: UserInterfaceStyle
    }
    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        applicationDidChangeUserInterfaceStyleState = .init(
            userInterfaceStyle: userInterfaceStyle
        )
    }
    @Published public var composedOutputState: ComposedOutputState? = nil
    public struct ComposedOutputState {
        public let output: ApplicationLifecycleOutput
    }
    public func composed(with output: ApplicationLifecycleOutput) {
        composedOutputState = .init(
            output: output
        )
    }
}
