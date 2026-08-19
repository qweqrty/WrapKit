//
//  SplashContentView.swift
//  WrapKit
//
//  Created by Stanislav Li on 28/2/25.
//

import SwiftUI
import WrapKit

private final class SplashContentAdapters {
    let text = TextOutputSwiftUIAdapter()
    let image = ImageViewOutputSwiftUIAdapter()
    let stack = StackViewOutputSwiftUIAdapter()
    let toast = CommonToastOutputSwiftUIAdapter()
    let button = ButtonOutputSwiftUIAdapter()
    let buttonLoading = LoadingOutputSwiftUIAdapter()
    let loadingView = LoadingOutputSwiftUIAdapter()
    let buttonWithShrink = ButtonOutputSwiftUIAdapter()
    let switchControl = SwitchCotrolOutputSwiftUIAdapter()
    let progressBar = ProgressBarOutputSwiftUIAdapter()
    let refreshControl = RefreshControlOutputSwiftUIAdapter()
    let datePicker = DatePickerViewOutputSwiftUIAdapter()
    let textField = TextInputOutputSwiftUIAdapter()
    let picker = PickerViewOutputSwiftUIAdapter()
    let textView = TextInputOutputSwiftUIAdapter()
    let tableView = TableOutputSwiftUIAdapter<TestCell, Void, TestHeader>()
    let emptyView = EmptyViewOutputSwiftUIAdapter()
    let chunkedTextField = TextInputOutputSwiftUIAdapter()
}

public struct TestCell: Hashable {
    let id: Int
    let title: String
}

public struct TestHeader {
    let title: String
}

public struct SplashContentView: View {
    private let lifeCycleOutput: LifeCycleViewOutput?
    private let applicationLifecycleOutput: ApplicationLifecycleOutput?
    private let adapters: SplashContentAdapters

    public var adapter: TextOutputSwiftUIAdapter { adapters.text }
    public var imageViewAdapter: ImageViewOutputSwiftUIAdapter { adapters.image }
    public var stackViewAdapter: StackViewOutputSwiftUIAdapter { adapters.stack }
    public var toastViewAdapter: CommonToastOutputSwiftUIAdapter { adapters.toast }
    
    public var buttonAdapter: ButtonOutputSwiftUIAdapter { adapters.button }
    public var buttonLoadingAdapter: LoadingOutputSwiftUIAdapter { adapters.buttonLoading }
    public var loadingAdapter: LoadingOutputSwiftUIAdapter { adapters.loadingView }
    public var buttonWithShrinkAdapter: ButtonOutputSwiftUIAdapter { adapters.buttonWithShrink }
    public var switchControlAdapter: SwitchCotrolOutputSwiftUIAdapter { adapters.switchControl }
    public var progressBarAdapter: ProgressBarOutputSwiftUIAdapter { adapters.progressBar }
    public var refreshControlAdapter: RefreshControlOutputSwiftUIAdapter { adapters.refreshControl }
    public var datePickerAdapter: DatePickerViewOutputSwiftUIAdapter { adapters.datePicker }
    public var textFieldAdapter: TextInputOutputSwiftUIAdapter { adapters.textField }
    public var pickerViewAdapter: PickerViewOutputSwiftUIAdapter { adapters.picker }
    public var textViewAdapter: TextInputOutputSwiftUIAdapter { adapters.textView }
    public var tableViewAdapter: TableOutputSwiftUIAdapter<TestCell, Void, TestHeader> { adapters.tableView }
    public var emptyViewAdapter: EmptyViewOutputSwiftUIAdapter { adapters.emptyView }
    public var chunkedTextFieldAdapter: TextInputOutputSwiftUIAdapter { adapters.chunkedTextField }

    public init(
        lifeCycleOutput: LifeCycleViewOutput? = nil,
        applicationLifecycleOutput: ApplicationLifecycleOutput? = nil
    ) {
        self.lifeCycleOutput = lifeCycleOutput
        self.applicationLifecycleOutput = applicationLifecycleOutput
        self.adapters = SplashContentAdapters()
    }

    @State private var selected = 0

    public var body: some View {
        LifeCycleView(
            lifeCycleOutput: lifeCycleOutput,
            applicationLifecycleOutput: applicationLifecycleOutput
        ) {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView(.vertical) {
                        SUIProgressBar(adaper: progressBarAdapter)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SUILabel(adapter: adapter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.2))
                        
                        SUIChunkedTextField(
                            adapter: chunkedTextFieldAdapter,
                            count: 4,
                            appearance: .init(
                                colors: .init(
                                    textColor: .black,
                                    selectedBorderColor: .red,
                                    selectedBackgroundColor: .cyan,
                                    selectedErrorBorderColor: .red,
                                    errorBorderColor: .red,
                                    errorBackgroundColor: .red,
                                    deselectedBorderColor: .blue,
                                    deselectedBackgroundColor: .white,
                                    disabledTextColor: .gray,
                                    disabledBackgroundColor: .gray
                                ),
                                font: .boldSystemFont(ofSize: 20)
                            )
                        )
                        
                        SUIEmptyView(adapter: emptyViewAdapter)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SUIButton(adapter: buttonAdapter, loadingAdapter: buttonLoadingAdapter)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SUIButton(adapter: buttonWithShrinkAdapter, pressAnimations: [.shrink])
                            .frame(maxWidth: .infinity, alignment: .center)

                        SUISwitchControl(adapter: switchControlAdapter)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SUIDatePicker(adapter: datePickerAdapter)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SUITextField(
                            adapter: textFieldAdapter,
                            appearance: .init(
                                colors: .init(
                                    textColor: .black,
                                    selectedBorderColor: .red,
                                    selectedBackgroundColor: .cyan,
                                    selectedErrorBorderColor: .red,
                                    errorBorderColor: .red,
                                    errorBackgroundColor: .red,
                                    deselectedBorderColor: .blue,
                                    deselectedBackgroundColor: .black,
                                    disabledTextColor: .gray,
                                    disabledBackgroundColor: .gray
                                ),
                                font: .boldSystemFont(ofSize: 14)
                            ),
                            trailingView: .init(SwiftUI.Image(systemName: "star.fill"))
                        )
                        .frame(maxWidth: .infinity, alignment: .center)

                        SUIPickerView(adapter: pickerViewAdapter)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SUITextView(
                            adapter: textFieldAdapter,
                            appearance: .init(
                                colors: .init(
                                    textColor: .black,
                                    selectedBorderColor: .red,
                                    selectedBackgroundColor: .cyan,
                                    selectedErrorBorderColor: .red,
                                    errorBorderColor: .red,
                                    errorBackgroundColor: .red,
                                    deselectedBorderColor: .blue,
                                    deselectedBackgroundColor: .black,
                                    disabledTextColor: .gray,
                                    disabledBackgroundColor: .gray
                                ),
                                font: .boldSystemFont(ofSize: 14)
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    SUITableView(
                        adapter: tableViewAdapter,
                        style: .lazyVStack(scrollable: true),
                        cellContent: { cell, indexPath in
                            Text("\(cell.title) - row \(indexPath.row)")
                                .padding()
                        },
                        headerContent: { header in
                            Text(header.title)
                        },
                        footerContent: { _ in EmptyView() }
                    )
                    .frame(maxWidth: .infinity)
                }
                SUIScrollableContentView(
                    contentInset: .init(horizontal: 16, vertical: 24),
                    backgroundColor: .red.withAlphaComponent(0.2)
                ) {
                    VStack(spacing: 16) {
                        SUIStackView(
                            adapter: stackViewAdapter,
                            backgroundColor: .systemYellow.withAlphaComponent(0.25)
                        ) {
                            stackDemoItem(
                                title: "SUIStackView text",
                                imageName: "square.stack.3d.up.fill",
                                color: .blue
                            )
                            stackDemoItem(
                                title: "SUIStackView image",
                                imageName: "photo.fill",
                                color: .purple
                            )
                            stackDemoItem(
                                title: "Presenter setup",
                                imageName: "slider.horizontal.3",
                                color: .orange
                            )
                        }
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)

                        SUIFillStackView(
                            axis: .horizontal,
                            spacing: 8,
                            backgroundColor: .systemGreen.withAlphaComponent(0.2)
                        ) {
                            fillStackDemoItem(
                                title: "SUIFillStackView",
                                imageName: "rectangle.3.group.fill",
                                color: .green
                            )
                            fillStackDemoItem(
                                title: "text + image",
                                imageName: "text.badge.plus",
                                color: .red
                            )
                        }
                        .frame(height: 110)
                        .frame(maxWidth: .infinity)

                        ForEach(1..<7, id: \.self) { index in
                            SUIStackView(
                                adapter: stackViewAdapter,
                                backgroundColor: .systemYellow.withAlphaComponent(0.2)
                            ) {
                                stackDemoItem(
                                    title: "Scrollable stack \(index)",
                                    imageName: "arrow.up.and.down",
                                    color: .blue
                                )
                                stackDemoItem(
                                    title: "Content item \(index)",
                                    imageName: "photo.on.rectangle.angled",
                                    color: .purple
                                )
                                stackDemoItem(
                                    title: "Check scroll \(index)",
                                    imageName: "hand.draw.fill",
                                    color: .orange
                                )
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                        }

                        SUILabel(adapter: adapter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .background(Color.blue.opacity(0.2))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .refreshControl(adapter: refreshControlAdapter)
        }
        .toastView(adapter: toastViewAdapter)
    }

    private func stackDemoItem(
        title: String,
        imageName: String,
        color: SwiftUIColor
    ) -> some View {
        VStack(spacing: 6) {
            SwiftUIImage(systemName: imageName)
                .font(.system(size: 28, weight: .semibold))
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .cornerRadius(12)
    }

    private func fillStackDemoItem(
        title: String,
        imageName: String,
        color: SwiftUIColor
    ) -> some View {
        HStack(spacing: 8) {
            SwiftUIImage(systemName: imageName)
                .font(.system(size: 24, weight: .bold))
            Text(title)
                .font(.headline)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color)
        .cornerRadius(12)
    }
}

#Preview("SwiftUI") {
    EntryViewSwiftUIFactory().makeSplashScreen()
}

#if canImport(UIKit)
@available(iOS 17, *)
#Preview("UIKit") {
    let scrollView = UIScrollView()
    scrollView.backgroundColor = .red.withAlphaComponent(0.2)
    let presenter = SplashPresenter()
    let viewController = ExampleViewController(
        contentView: scrollView,
        lifeCycleViewOutput: presenter,
        applicationLifecycleOutput: presenter
    )
    presenter.textOutput = viewController.label
    return viewController
}

private final class ExampleViewController: ViewController<UIScrollView> {
    let label = Label()

    override func viewDidLoad() {
        super.viewDidLoad()
        label.backgroundColor = .blue.withAlphaComponent(0.2)
        contentView.addSubview(label)
        label.fillSuperviewSafeAreaLayoutGuide()
        label.anchor(.widthTo(contentView.widthAnchor))
        label.sizeToFit()
    }
}

#elseif canImport(AppKit)
#endif
