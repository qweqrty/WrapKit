//
//  SplashPresenter.swift
//  SwiftUIApp
//
//  Created by Stanislav Li on 28/2/25.
//

import Foundation
import WrapKit
import GameKit

public class SplashPresenter: LifeCycleViewOutput, ApplicationLifecycleOutput {
    public var lottieView: LottieViewOutput?
    public var textOutput: TextOutput?
    
    public init() {
       
    }

    // MARK: - View Lifecycle
    public func viewDidLoad() {
        print("SplashPresenter: viewDidLoad()")
        textOutput?.display(text: "display(text: String) implementation - `The quick brown fox jumps over the lazy dog`")
//        textOutput?.display(
//            attributes: [
//                .init(text: "first line"),
//                .init(
//                    text: "green bold 20 (.byWord) \n\n",
//                    color: .green,
//                    font: .boldSystemFont(ofSize: 20),
//                    underlineStyle: .byWord
//                ),
//                .init(
//                    text: "yellow bold 25 (.double) \n\n",
//                    color: .yellow,
//                    font: .boldSystemFont(ofSize: 25),
//                    underlineStyle: .double
//                ),
//                .init(
//                    text: "blue italic 15 (.patternDash) \n\n",
//                    color: .blue,
//                    font: FontFactory.italic(size: 15),
//                    underlineStyle: .patternDash
//                ),
//                .init(
//                    text: "cyan default 25 (.patternDashDot) asdf xcvxcv asdfsdf \n\n",
//                    color: .cyan,
//                    font: .systemFont(ofSize: 25),
//                    underlineStyle: .patternDashDot
//                ),
//                .init(
//                    text: "brown 30-500 (.patternDashDotDot) zxcvz gtfrgh vbnbvgn \n\n",
//                    color: .brown,
//                    font: .systemFont(ofSize: 30, weight: Font.Weight(rawValue: 500)),
//                    underlineStyle: .patternDashDotDot,
//                    onTap: { print("didTap: brown patternDashDotDot ") }
//                ),
//                .init(
//                    text: "darkGray 16-200 (.patternDot) \n\n",
//                    color: .darkGray,
//                    font: .systemFont(ofSize: 16, weight: Font.Weight(rawValue: 200)),
//                    underlineStyle: .patternDot,
//                    onTap: { print("didTap: patternDot ") }
//                ),
//                .init(
//                    text: "The quick brown fox ",
//                    color: .black,
//                    font: .boldSystemFont(ofSize: 25),
//                    underlineStyle: .single,
//                    textAlignment: .right,
//                    leadingImage: ImageFactory.systemImage(named: "mail"),
//                    leadingImageBounds: .init(x: 30, y: 40, width: 45, height: 56),
//                    trailingImage: ImageFactory.systemImage(named: "arrow.right"),
//                    trailingImageBounds: .init(x: -30, y: -40, width: 15, height: 15),
//                    onTap: { print("didTap: The quick brown fox ") }
//                )
//            ]
//        )
//        textOutput?.display(model: .textStyled(text: .text("some text"), cornerStyle: .automatic, insets: .init(all: 8)))
//        textOutput?.display(model: .animated(123, 456, mapToString: { value in
//                .text(value.description)
//        }, animationStyle: .none, duration: 5, completion: {
//            
//        }))
        textOutput?.display(model: .animated(123, 456, mapToString: { value in
                .text(value.asString(withDecimalPlaces: 2) + " som")
        }, animationStyle: .circle(lineColor: Color.blue), duration: 5, completion: {
            
        }))
    }

    public func viewWillAppear() {
        print("SplashPresenter: viewWillAppear()")
    }

    public func viewWillDisappear() {
        print("SplashPresenter: viewWillDisappear()")
    }

    public func viewDidAppear() {
        print("SplashPresenter: viewDidAppear()")
    }

    public func viewDidDisappear() {
        print("SplashPresenter: viewDidDisappear()")
    }

    // MARK: - Application Lifecycle
    public func applicationWillEnterForeground() {
        print("SplashPresenter: applicationWillEnterForeground()")
    }

    public func applicationDidEnterBackground() {
        print("SplashPresenter: applicationDidEnterBackground()")
    }

    public func applicationDidBecomeActive() {
        print("SplashPresenter: applicationDidBecomeActive()")
    }

    public func applicationWillResignActive() {
        print("SplashPresenter: applicationWillResignActive()")
    }

    public func applicationDidChange(userInterfaceStyle: UserInterfaceStyle) {
        print("SplashPresenter: applicationDidChange(userInterfaceStyle: \(userInterfaceStyle))")
    }
}
