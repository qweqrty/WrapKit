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
        textOutput?.display(
            attributes: [
//                .init(
//                    text: "green bold 20 (.byWord) ",
//                    color: .green,
//                    font: .boldSystemFont(ofSize: 20),
//                    underlineStyle: .byWord
//                ),
//                .init(
//                    text: "yellow bold 25 (.double) ",
//                    color: .yellow,
//                    font: .boldSystemFont(ofSize: 25),
//                    underlineStyle: .double
//                ),
//                .init(
//                    text: "blue italic 15 (.patternDash) ",
//                    color: .blue,
//                    font: .italicSystemFont(ofSize: 15),
//                    underlineStyle: .patternDash
//                ),
//                .init(
//                    text: "cyan default 25 (.patternDashDot) asdf xcvxcv asdfsdf ",
//                    color: .cyan,
//                    font: .systemFont(ofSize: 25),
//                    underlineStyle: .patternDashDot
//                ),
//                .init(
//                    text: "brown 30-500 (.patternDashDotDot) zxcvz gtfrgh vbnbvgn ",
//                    color: .brown,
//                    font: .systemFont(ofSize: 30, weight: UIFont.Weight(rawValue: 500)),
//                    underlineStyle: .patternDashDotDot
//                ),
//                .init(
//                    text: "darkGray 16-200 (.patternDashDotDot) \n\n",
//                    color: .darkGray,
//                    font: .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 200)),
//                    underlineStyle: .patternDot
//                ),
                .init(
                    text: "The quick brown fox \n\n\n",
                    color: .black,
                    font: .boldSystemFont(ofSize: 25),
                    underlineStyle: .single,
                    textAlignment: .right,
                    leadingImage: UIImage(systemName: "mail"),
                    leadingImageBounds: .init(x: 0, y: 0, width: 45, height: 56),
                    trailingImage: UIImage(systemName: "arrow.right"),
                    trailingImageBounds: .init(x: 0, y: 0, width: 15, height: 15),
                    onTap: { print("on tap full text") }
                ),
//                .init(
//                    text: "\n\njumps over the lazy dog cvdsf asdf asdf asdf asdfhaslkdfjh alsdkjfh alsdkjf",
//                    color: .gray,
//                    font: .boldSystemFont(ofSize: 26),
//                    underlineStyle: .thick,
//                    textAlignment: .natural
//                ),
//                .init(
//                    text: "button \n\n\n",
//                    color: .green,
//                    font: .boldSystemFont(ofSize: 15),
//                    onTap: { print("on tap button") }
//                ),
                
                .init(
                    text: "The quick",
                    color: .black,
                    font: .systemFont(ofSize: 14),
                    onTap: { print("The quick") }
                ),
                .init(
                    text: "brown fox",
                    color: .blue,
                    font: .systemFont(ofSize: 14),
                    onTap: { print("brown fox") }
                ),
                .init(
                    text: "jumps over",
                    color: .green,
                    font: .systemFont(ofSize: 14),
                    onTap: { print("jumps over") }
                ),
                .init(
                    text: "the lazy dog",
                    color: .yellow,
                    font: .systemFont(ofSize: 14),
                    onTap: { print("the lazy dog") }
                ),
            ]
        )
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
