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
    public var imageViewOutput: ImageViewOutput?
    public var toastView: CommonToastOutput?
    
    public init() {
        
    }
    // MARK: - View Lifecycle
    public func viewDidLoad() {
        print("SplashPresenter: viewDidLoad()")
        setupTextOutput()
        setupImageOutput()
        setupToastOutput()
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

private extension SplashPresenter {
    private func setupTextOutput() {
        textOutput?.display(text: "display(text: String) implementation - `The quick brown fox jumps over the lazy dog`")
        textOutput?.display(
            attributes: [
                .init(text: "first line"),
                .init(
                    text: "green bold 20 (.byWord) \n\n",
                    color: .green,
                    font: .boldSystemFont(ofSize: 20),
                    underlineStyle: .byWord
                ),
                .init(
                    text: "yellow bold 25 (.double) \n\n",
                    color: .yellow,
                    font: .boldSystemFont(ofSize: 25),
                    underlineStyle: .double
                ),
                .init(
                    text: "blue italic 15 (.patternDash) \n\n",
                    color: .blue,
                    font: FontFactory.italic(size: 15),
                    underlineStyle: .patternDash
                ),
                .init(
                    text: "cyan default 25 (.patternDashDot) asdf xcvxcv asdfsdf \n\n",
                    color: .cyan,
                    font: .systemFont(ofSize: 25),
                    underlineStyle: .patternDashDot
                ),
                .init(
                    text: "brown 30-500 (.patternDashDotDot) zxcvz gtfrgh vbnbvgn \n\n",
                    color: .brown,
                    font: .systemFont(ofSize: 30, weight: Font.Weight(rawValue: 500)),
                    underlineStyle: .patternDashDotDot
                ),
                .init(
                    text: "darkGray 16-200 (.patternDot) \n\n",
                    color: .darkGray,
                    font: .systemFont(ofSize: 16, weight: Font.Weight(rawValue: 200)),
                    underlineStyle: .patternDot
                ),
                .init(
                    text: "The quick brown fox ",
                    color: .black,
                    font: .boldSystemFont(ofSize: 25),
                    underlineStyle: .single,
                    textAlignment: .right,
                    leadingImage: ImageFactory.systemImage(named: "mail"),
                    leadingImageBounds: .init(x: 30, y: 40, width: 45, height: 56),
                    trailingImage: ImageFactory.systemImage(named: "arrow.right"),
                    trailingImageBounds: .init(x: -30, y: -40, width: 15, height: 15),
                    onTap: { print("didTap: The quick brown fox ") }
                )
            ]
        )
//        textOutput?.display(model: .textStyled(text: .text("some text"), cornerStyle: .automatic, insets: .init(all: 8)))
//        textOutput?.display(model: .animated(123, 456, mapToString: { value in
//                .text(value.description)
//        }, animationStyle: .none, duration: 5, completion: {
//            
//        }))
//        textOutput?.display(model: .animated(123, 456, mapToString: { value in
//                .text(value.asString(withDecimalPlaces: 2) + " som")
//        }, animationStyle: .circle(lineColor: Color.blue), duration: 5, completion: {
//            
//        }))
    }
    
    private func setupImageOutput() {
        let urlStringLight = "https://developer.apple.com/assets/elements/icons/swift/swift-64x64_2x.png"
        let urlStringDark = "https://uxwing.com/wp-content/themes/uxwing/download/web-app-development/dark-mode-icon.png"
        
        setImageAsset()
        ///
        func setImageAsset() {
            imageViewOutput?.display(
                model: .init(
                    size: .init(width: 40, height: 40),
                    image: .asset(.init(named: "mini")),
                    onPress: {
                        setImageData()
                    },
                    onLongPress: {
                        changeBorderColor()
                    },
                    contentModeIsFit: false,
                    borderWidth: 2,
                    borderColor: .red,
                    cornerRadius: 12
                )
            )
        }
        
        func setImageData() {
            // uncomment this code to get data from image
            //        if let nsImage = NSImage(named: "mini"),
            //           let tiffData = nsImage.tiffRepresentation,
            //           let bitmap = NSBitmapImageRep(data: tiffData),
            //           let pngData = bitmap.representation(using: .png, properties: [:]) {
            //
            //            let fileURL = FileManager.default
            //                .urls(for: .documentDirectory, in: .userDomainMask)[0]
            //                .appendingPathComponent("savedImage.png")
            //
            //            do {
            //                try pngData.write(to: fileURL)
            //                print("Image saved to: \(fileURL)")
            //            } catch {
            //                print("Error saving image: \(error)")
            //            }
            //        }
            
            let fileURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("savedImage.png")
            
            if let data = try? Data(contentsOf: fileURL) {
                imageViewOutput?.display(
                    model: .init(
                        size: .init(width: 60, height: 60),
                        image: .data(data),
                        onPress: {
                            setImageURL()
                        },
                        onLongPress: {
                            changeFrameSize()
                        },
                        contentModeIsFit: false,
                        borderWidth: 1,
                        borderColor: .red,
                        cornerRadius: 12
                    )
                )
            }
        }
        
        func setImageURL() {
            imageViewOutput?.display(
                model: .init(
                    image: .url(URL(string: urlStringLight), URL(string: urlStringDark)),
                    onPress: {
                        setImageURLString()
                    },
                    onLongPress: {
                        changeModel()
                    },
                    contentModeIsFit: false,
                    borderWidth: 1,
                    borderColor: .red,
                    cornerRadius: 12
                )
            )
        }
        
        func setImageURLString() {
            imageViewOutput?.display(
                model: .init(
                    size: .init(width: 60, height: 60),
                    image: .urlString(urlStringLight, urlStringDark),
                    onPress: {
                        setImageAsset()
                    },
                    onLongPress: {
                        hide()
                    },
                    contentModeIsFit: false,
                    borderWidth: 1,
                    borderColor: .red,
                    cornerRadius: 12
                )
            )
        }
        
        func changeBorderColor() {
            imageViewOutput?.display(borderColor: .black)
        }
        
        func changeFrameSize() {
            imageViewOutput?.display(size: .init(width: 24, height: 24))
        }
        
        func changeModel() {
            imageViewOutput?.display(model: .init(
                size: .init(width: 60, height: 60),
                borderWidth: 5,
                borderColor: .green
            ))
        }
        
        func hide() {
            imageViewOutput?.display(isHidden: true)
        }
    }
    
    private func setupToastOutput() {
        displaySuccessToastExample()
        displayErrorToastExample()
        displayWarningToastExample()
        displayCustomToastExample()
    }
    
    private func displaySuccessToastExample() {
        let card = CardViewPresentableModel(
            style: makeToastStyle(accentColor: .green),
            title: .text("Success toast"),
            valueTitle: .text("Top position + card onPress"),
            onPress: {
                print("SplashPresenter: success card tapped")
            },
            isUserInteractionEnabled: true
        )
        
        toastView?.display(
            .success(.init(
                cardViewModel: card,
                position: .top,
                shadowColor: .black,
                duration: 2
            ))
        )
    }
    
    private func displayErrorToastExample() {
        let card = CardViewPresentableModel(
            style: makeToastStyle(accentColor: .red),
            title: .text("Error toast"),
            valueTitle: .text("Bottom position with additional padding"),
            onPress: {
                print("SplashPresenter: error card tapped")
            },
            isUserInteractionEnabled: true
        )
        
        toastView?.display(
            .error(.init(
                cardViewModel: card,
                position: .bottom(additionalBottomPadding: 12),
                shadowColor: .black,
                duration: 2
            ))
        )
    }
    
    private func displayWarningToastExample() {
        let card = CardViewPresentableModel(
            style: makeToastStyle(accentColor: .orange),
            title: .text("Warning toast"),
            trailingImage: .init(image: .asset(.checkmark)),
            valueTitle: .text("Custom CardViewPresentableModel + card onPress"),
            onPress: {
                print("SplashPresenter: warning card tapped")
            },
            isUserInteractionEnabled: true
        )
        
        toastView?.display(
            .warning(.init(
                cardViewModel: card,
                position: .top,
                shadowColor: .black,
                duration: 2
            ))
        )
    }
    
    private func displayCustomToastExample() {
        let card = CardViewPresentableModel(
            style: makeToastStyle(
                accentColor: .blue,
                backgroundColor: .white,
                titleColor: .black,
                valueColor: .darkGray
            ),
            title: .text("Custom toast"),
            subTitle: .attributes([.init(text: "subtitle")]),
            valueTitle: .text("value"),
            switchControl: .init(
                onPress: { _ in
                    print("isOn")
                },
                isOn: false,
                isEnabled: true,
                style: .init(
                    tintColor: .red,
                    thumbTintColor: .blue,
                    backgroundColor: .darkGray,
                    cornerRadius: 12
                )
            ),
            onPress: {
                print("SplashPresenter: custom card tapped")
            }
        )
        
        toastView?.display(
            .custom(.init(
                common: .init(
                    cardViewModel: card,
                    position: .bottom(additionalBottomPadding: 16),
                    shadowColor: .black,
                    duration: nil
                ),
                image: .asset(customToastImage()),
                backgroundColor: .white
            ))
        )
    }

    private func customToastImage() -> Image? {
        ImageFactory
            .systemImage(named: "sparkles")?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
    }
    
    private func makeToastStyle(
        accentColor: Color,
        backgroundColor: Color = .white,
        titleColor: Color = .black,
        valueColor: Color = .darkGray
    ) -> CardViewPresentableModel.Style {
        .init(
            backgroundColor: backgroundColor,
            vStacklayoutMargins: .zero,
            hStacklayoutMargins: .init(horizontal: 14, vertical: 12),
            hStackViewDistribution: .fill,
            leadingTitleKeyTextColor: accentColor,
            titleKeyTextColor: titleColor,
            trailingTitleKeyTextColor: titleColor,
            titleValueTextColor: valueColor,
            subTitleTextColor: valueColor,
            leadingTitleKeyLabelFont: .boldSystemFont(ofSize: 14),
            titleKeyLabelFont: .boldSystemFont(ofSize: 16),
            trailingTitleKeyLabelFont: .systemFont(ofSize: 14),
            titleValueLabelFont: .systemFont(ofSize: 14),
            subTitleLabelFont: .systemFont(ofSize: 13),
            cornerRadius: 16,
            stackSpace: 4,
            hStackViewSpacing: 10,
            titleKeyNumberOfLines: 1,
            titleValueNumberOfLines: 2,
            borderColor: accentColor,
            borderWidth: 1
        )
    }
}
