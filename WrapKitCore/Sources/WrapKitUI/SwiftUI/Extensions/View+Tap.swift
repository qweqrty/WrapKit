//
//  View+Tap.swift
//  WrapKit
//
//  Created by Dastan Mamyrov on 29/10/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func onTapGestureLocation(
        count: Int = 1,
        coordinateSpace: CoordinateSpace = .local,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        if #available(iOS 17, macOS 14, watchOS 10, *) {
            self.onTapGesture(count: count, coordinateSpace: coordinateSpace, perform: action)
        } else {
            self.gesture(
                ClickGesture(count: count, coordinateSpace: coordinateSpace)
                    .onEnded(perform: action)
            )
        }
    }
}

// For using before < iOS 17
// Source: https://stackoverflow.com/a/66504244
struct ClickGesture: Gesture {
    let count: Int
    let coordinateSpace: CoordinateSpace
    
    typealias Value = SimultaneousGesture<TapGesture, DragGesture>.Value
    
    init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        precondition(count > 0, "Count must be greater than or equal to 1.")
        self.count = count
        self.coordinateSpace = coordinateSpace
    }
    
    var body: SimultaneousGesture<TapGesture, DragGesture> {
        SimultaneousGesture(
            TapGesture(count: count),
            DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace)
        )
    }
    
    func onEnded(perform action: @escaping (CGPoint) -> Void) -> _EndedGesture<ClickGesture> {
        self.onEnded { (value: Value) in
            guard value.first != nil else { return }
            guard let location = value.second?.startLocation else { return }
            guard let endLocation = value.second?.location else { return }
            guard ((location.x-1)...(location.x+1)).contains(endLocation.x),
                  ((location.y-1)...(location.y+1)).contains(endLocation.y) else {
                return
            }
            action(location)
        }
    }
}

//            self.simultaneousGesture(combinedClickGesture)
//var combinedClickGesture: some Gesture {
//    SimultaneousGesture(
//        ExclusiveGesture(TapGesture(count: 2), TapGesture(count: 1)),
//        DragGesture(minimumDistance: 0)
//    ).onEnded { value in
//        if let v1 = value.first {
//            var count: Int
//            switch v1 {
//            case .first():  count = 2
//            case .second(): count = 1
//            }
//            if let v2 = value.second {
//                print("combinedClickGesture couunt = \(count) location = \(v2.location)")
//            }
//        }
//    }
//}
