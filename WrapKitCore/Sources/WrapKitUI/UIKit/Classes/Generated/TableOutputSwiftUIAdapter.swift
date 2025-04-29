// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
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
#if canImport(Foundation)
import Foundation
#endif
#if canImport(UIKit)
import UIKit
#endif
public class TableOutputSwiftUIAdapter<Cell: Hashable,Footer: Any,Header: Any>: ObservableObject, TableOutput {

    // Initializer
    public init(
    ) {
    }

    @Published public var displaySectionsState: DisplaySectionsState? = nil
    public struct DisplaySectionsState {
        public let sections: [TableSection<Header, Cell, Footer>]
    }
    public func display(sections: [TableSection<Header, Cell, Footer>]) {
        displaySectionsState = .init(
            sections: sections
        )
    }
    @Published public var displayActionsState: DisplayActionsState? = nil
    public struct DisplayActionsState {
        public let actions: [TableContextualAction]
    }
    public func display(actions: [TableContextualAction]) {
        displayActionsState = .init(
            actions: actions
        )
    }
}
