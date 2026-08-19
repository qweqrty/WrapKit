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
    public var buttonOutput: ButtonOutput?
    public var buttonLoadingOutput: LoadingOutput? 
    public var loadingOutput: LoadingOutput?
    public var buttonWithShrink: ButtonOutput?
    public var switchControl: SwitchCotrolOutput?
    public var switchControlLoading: LoadingOutput?
    public var progressBar: ProgressBarOutput?
    public var segmentedControl: SegmentedControlOutput?
    public var refreshControlOutput: RefreshControlOutput?
    public var datePickerOutput: DatePickerViewOutput?
    public var textField: TextInputOutput?
    public var picker: PickerViewOutput?
    public var textView: TextInputOutput?
    public var tableView: (any TableOutput<TestHeader, TestCell, Void>)?
    public var emptyView: EmptyViewOutput?
    public var chunkedTextField: TextInputOutputSwiftUIAdapter?
    
    public init() {
        
    }
    // MARK: - View Lifecycle
    public func viewDidLoad() {
        print("SplashPresenter: viewDidLoad()")
//        setupTextOutput()
//        setupImageOutput()
//        setupButtonOutup()
        setupProgressBar()
        setupSwitchControl()
        setupRefreshControl()
        setupDatePicker()
        setupTextFied()
        setupPickerView()
        setupTextView()
        setupTableView()
        setupEmptyView()
        setupChunkedTextField()
        
//        loadingOutput?.display(isLoading: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
//            self?.loadingOutput?.display(isLoading: false)
//        }
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
    // MARK: = Label
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
    
    // MARK: - CHunkedTextfield
    private func setupChunkedTextField() {
        chunkedTextField?.display(text: "Hello")
    }
    
    // MARK: - EmptyView
    private func setupEmptyView() {
        emptyView?.display(model: .init(title: .init(model: .text("Hello")), subTitle: .init(model: .text("world!"))))
    }
    
    // MARK: - TableView
    private func setupTableView() {
        tableView?.display(sections: [
            .init(
                header: TestHeader(title: "Section 1"),
                cells: [
                    .init(cell: TestCell(id: 1, title: "Cell 1")),
                    .init(cell: TestCell(id: 2, title: "Cell 2")),
                    .init(cell: TestCell(id: 3, title: "Cell 3")),
                ]
            ),
            .init(
                header: TestHeader(title: "Section 2"),
                cells: [
                    .init(cell: TestCell(id: 4, title: "Cell 4")),
                    .init(cell: TestCell(id: 5, title: "Cell 5")),
                    .init(cell: TestCell(id: 5, title: "Cell 5")),
                ]
            )
        ])
    }
    
    // MARK: Textview
    private func setupTextView() {
        textView?.display(model: .init(
            placeholder: "Enter your text"
        ))
    }
    
    // MARK: - Picker
    private func setupPickerView() {
        let items = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь"]
        picker?.display(model: .init(
            rowsCount: { items.count },
            titleForRowAt: { index in items[index] },
            didSelectAt: { index in
                print("Selected: \(items[index])")
            },
            selectedRow: .init(row: 0)
        ))
    }
    
    // MARK: - TextField
    private func setupTextFied() {
        textField?.display(model: .init(
            placeholder: "Enter your text"
        ))
    }
    
    // MARK: - DatePicker
    private func setupDatePicker() {
        var minComponents = DateComponents()
        minComponents.year = 2025
        minComponents.month = 4
        minComponents.day = 25
        let minDate = Calendar.current.date(from: minComponents)
        
        var maxComponents = DateComponents()
        maxComponents.year = 2025
        maxComponents.month = 4
        maxComponents.day = 30
        let maxDate = Calendar.current.date(from: maxComponents)
        
        datePickerOutput?.display(model: .init(
            value: Date(),
            minimumDate: minDate,
            maximumDate: maxDate,
            mode: .date,
            dateChanged: { date in
                print(date)
            }
        ))
    }
    
    // MARK: - RefreshControl
    private func setupRefreshControl() {
        refreshControlOutput?.display(model: .init(
            style: .init(tintColor: .blue),
            onRefresh: { [weak self] in
                print("refreshing...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.refreshControlOutput?.display(isLoading: false)
                }
            },
            isLoading: false
        ))
    }
    
    // MARK: - Button
    private func setupButtonOutup() {
        
        buttonLoadingOutput?.display(isLoading: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.buttonLoadingOutput?.display(isLoading: false)
        }
        
        buttonOutput?.display(model: .init(title: "Common button",
                                           image: .init(systemName: "star.fill"),
                                           height: 50,
                                           width: 300,
                                           style: .init(
                                            backgroundColor: .green,
                                            titleColor: .red,
                                            borderWidth: 3,
                                            borderColor: .black,
                                            pressedColor: .cyan,
                                            pressedTintColor: .brown,
                                            loadingIndicatorColor: .red
                                           )))
        
        buttonOutput?.display {
            print("asd")
        }
        
        buttonWithShrink?.display(model: .init(title: "Button with shrink",
                                           image: .init(systemName: "star.fill"),
                                           height: 50,
                                           width: 300,
                                           style: .init(
                                            backgroundColor: .green,
                                            titleColor: .red,
                                            borderWidth: 3,
                                            borderColor: .black,
                                            pressedColor: .cyan,
                                            pressedTintColor: .brown,
                                            loadingIndicatorColor: .red
                                           )))
    }
    
    // MARK: - ProgressBar
    private func setupProgressBar() {
        progressBar?.display(model: .init(
            progress: 50,
            style: .init(backgroundColor: .systemGreen, progressBarColor: .systemBlue, height: 8, cornerRadius: 16)
        ))
    }
    
    // MARK: - SwitchControl
    private func setupSwitchControl() {
        switchControl?.display(model: .init(
            onPress: { [weak self] _ in
                self?.progressBar?.display(progress: 80)
            },
            isOn: true,
            style: .init(
                tintColor: .red,
                thumbTintColor: .white,
                backgroundColor: .lightGray,
                cornerRadius: 16,
                shimmerStyle: .init(
                    backgroundColor: .lightGray,
                    gradientColorOne: .clear,
                    gradientColorTwo: UIColor(white: 0.95, alpha: 0.6),
                    cornerRadius: 16
                )
            )
        ))
        
        switchControlLoading?.display(isLoading: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.switchControlLoading?.display(isLoading: false)
        }
    }
    
    // MARK: - ImageView
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
