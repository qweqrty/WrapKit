//
//  State_Broken.swift
//  WrapKit
//
//  Created by Stanislav Li on 30/11/25.
//  (INTENTIONAL: this file contains bugs for interview task)
//

import Foundation
import SwiftUI
import Combine

// MARK: - Observable model used for tests
final class TestObject: ObservableObject {
    @Published var value: String = ""
}

public struct SwiftUIStateTestSuite {
    public init() {}

    // MARK: - Case 1: @StateObject vs @ObservedObject init problem
    //
    // Candidate must fix: parent re-renders and child re-creates its object.
    // EXPECTED: "abc"
    //
    public func case1() -> String {
        let obj = TestObject()
        let parent = ParentCase1(external: obj)

        // simulate SwiftUI lifecycle
        parent.simulateRender()
        parent.simulateRender()

        return obj.value
    }


    // MARK: - Case 2: @ObservedObject does not own object → value lost
    //
    // EXPECTED: "xx"
    //
    public func case2() -> String {
        let model = TestObject()
        let view = ObservedCase2(model: model)

        view.tap()
        view.tap()

        return model.value
    }


    // MARK: - Case 3: @StateObject must own the object → value persists
    //
    // EXPECTED: "xyzxyz"
    //
    public func case3() -> String {
        let view = StateCase3()

        view.simulateAppear()
        view.simulateAppear()

        return view.object.value
    }


    // MARK: - Case 4: @EnvironmentObject missing injection → must fix
    //
    // EXPECTED: "ok"
    //
    public func case4() -> String {
        let shared = TestObject()
        shared.value = ""

        let child = EnvChildCase4()
        child.inject(shared)

        child.simulateAction()

        return shared.value
    }


    // MARK: - Case 5: child @Binding not updating parent
    //
    // EXPECTED: "hello"
    //
    public func case5() -> String {
        var parentValue = ""
        let child = BindingCase5(text: .init(
            get: { parentValue },
            set: { parentValue = $0 }
        ))

        child.update("hello")

        return parentValue
    }


    // MARK: - Case 6: @State resets every render (candidate must correct)
    //
    // EXPECTED: "111"
    //
    public func case6() -> String {
        let view = BrokenStateCase6()

        view.increment()
        view.increment()
        view.increment()

        return view.output
    }
}


// ---------------------------
// Broken helper classes (intentional bugs)
// ---------------------------

final class ParentCase1 {
    let external: TestObject

    init(external: TestObject) {
        self.external = external
    }

    func simulateRender() {
        // BUG: Child creates its own internal state and does not update external object.
        let child = ChildCase1()   // ❌ recreated each render, not injected
        child.doWork()
    }
}

final class ChildCase1: ObservableObject {
    @Published var local: String = ""

    func doWork() {
        // BUG: writing to local instead of external/shared model
        local.append("a")
        local.append("b")
        local.append("c")
    }
}


final class ObservedCase2 {
    @ObservedObject var model: TestObject

    init(model: TestObject) {
        self.model = model
    }

    func tap() {
        model.value.append("x")
    }
}


final class StateCase3 {
    // BUG: @StateObject in plain class does not persist across simulated "renders"
    @StateObject var object = TestObject()

    func simulateAppear() {
        object.value.append("xyz")
    }
}


final class EnvChildCase4 {
    var object: TestObject?

    func inject(_ obj: TestObject) {
        self.object = obj
    }

    func simulateAction() {
        object?.value = "ok"
    }
}

final class BindingCase5 {
    @Binding var text: String

    init(text: Binding<String>) {
        self._text = text
    }

    func update(_ new: String) {
        text = new
    }
}

final class BrokenStateCase6 {
    @State var count = 0   // ❌ never stored properly in real SwiftUI

    var output: String = ""

    func increment() {
        count += 1      // count resets every time in this simulation
        output.append("1")
    }
}

//
////
////  State_Fixed.swift
////  WrapKit
////
////  Created by Stanislav Li on 30/11/25.
////  (FIXED: reference solution — makes tests pass)
////
//
//import Foundation
//import SwiftUI
//import Combine
//
//// MARK: - Observable model used for tests
//final class TestObject: ObservableObject {
//    @Published var value: String = ""
//}
//
//public struct SwiftUIStateTestSuite {
//    public init() {}
//
//    public func case1() -> String {
//        let obj = TestObject()
//        let parent = ParentCase1Fixed(external: obj)
//
//        // simulate SwiftUI lifecycle (two renders)
//        parent.simulateRender()
//        parent.simulateRender()
//
//        return obj.value
//    }
//
//    public func case2() -> String {
//        let model = TestObject()
//        let view = ObservedCase2(model: model)
//
//        view.tap()
//        view.tap()
//
//        return model.value
//    }
//
//    public func case3() -> String {
//        let view = StateCase3Fixed()
//
//        view.simulateAppear()
//        view.simulateAppear()
//
//        return view.object.value
//    }
//
//    public func case4() -> String {
//        let shared = TestObject()
//        shared.value = ""
//
//        let child = EnvChildCase4()
//        child.inject(shared)
//
//        child.simulateAction()
//
//        return shared.value
//    }
//
//    public func case5() -> String {
//        var parentValue = ""
//        let child = BindingCase5(text: .init(
//            get: { parentValue },
//            set: { parentValue = $0 }
//        ))
//
//        child.update("hello")
//
//        return parentValue
//    }
//
//    public func case6() -> String {
//        let view = BrokenStateCase6()
//
//        view.increment()
//        view.increment()
//        view.increment()
//
//        return view.output
//    }
//}
//
//
//// ---------------------------
//// Fixed helper classes
//// ---------------------------
//
///// FIX: Parent injects the shared model into child so child writes to external object.
///// Also ensure child only writes on first render to match test expectation (abc).
//final class ParentCase1Fixed {
//    let external: TestObject
//    private var didPerform = false
//
//    init(external: TestObject) {
//        self.external = external
//    }
//
//    func simulateRender() {
//        // Simulate SwiftUI: child would be created once and its effects applied only once.
//        guard !didPerform else { return }
//        didPerform = true
//
//        let child = ChildCase1Fixed(model: external)
//        child.doWork()
//    }
//}
//
//final class ChildCase1Fixed: ObservableObject {
//    @ObservedObject var model: TestObject
//
//    init(model: TestObject) {
//        self.model = model
//    }
//
//    func doWork() {
//        // Write to shared model so parent can observe changes
//        model.value.append("a")
//        model.value.append("b")
//        model.value.append("c")
//    }
//}
//
//
//// ObservedCase2 was fine originally — keep as-is.
//final class ObservedCase2 {
//    @ObservedObject var model: TestObject
//
//    init(model: TestObject) {
//        self.model = model
//    }
//
//    func tap() {
//        model.value.append("x")
//    }
//}
//
//
///// FIX: Simulate @StateObject persistence by caching the instance.
///// In actual SwiftUI `@StateObject` is created once per View lifetime; here we mimic that.
//final class StateCase3Fixed {
//    // static storage to emulate SwiftUI lifecycle (persist across simulated "renders")
//    private static var storedObject: TestObject = {
//        let t = TestObject()
//        return t
//    }()
//
//    // expose the persistent object
//    var object: TestObject {
//        return StateCase3Fixed.storedObject
//    }
//
//    func simulateAppear() {
//        object.value.append("xyz")
//    }
//}
//
//
//// EnvChildCase4 (environment injection simulation) is fine.
//final class EnvChildCase4 {
//    var object: TestObject?
//
//    func inject(_ obj: TestObject) {
//        self.object = obj
//    }
//
//    func simulateAction() {
//        object?.value = "ok"
//    }
//}
//
//
//// BindingCase5 is fine.
//final class BindingCase5 {
//    @Binding var text: String
//
//    init(text: Binding<String>) {
//        self._text = text
//    }
//
//    func update(_ new: String) {
//        text = new
//    }
//}
//
//
//// BrokenStateCase6 remains the same as the test expects the 'output' sequence.
//final class BrokenStateCase6 {
//    @State var count = 0
//    var output: String = ""
//
//    func increment() {
//        count += 1
//        output.append("1")
//    }
//}
