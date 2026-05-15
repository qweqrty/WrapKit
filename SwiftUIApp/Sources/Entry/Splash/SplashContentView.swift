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
    let button = ButtonOutputSwiftUIAdapter()
    let buttonLoading = LoadingOutputSwiftUIAdapter()
    let loadingView = LoadingOutputSwiftUIAdapter()
    let buttonWithShrink = ButtonOutputSwiftUIAdapter()
    let switchControl = SwitchCotrolOutputSwiftUIAdapter()
    let progressBar = ProgressBarOutputSwiftUIAdapter()
    let segmentedControl = SegmentedControlOutputSwiftUIAdapter()
    let refreshControl = RefreshControlOutputSwiftUIAdapter()
    let datePicker = DatePickerViewOutputSwiftUIAdapter()
    let textField = TextInputOutputSwiftUIAdapter()
    let picker = PickerViewOutputSwiftUIAdapter()
    let textView = TextInputOutputSwiftUIAdapter()
    let tableView = TableOutputSwiftUIAdapter<TestCell, Void, TestHeader>()
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
    public var buttonAdapter: ButtonOutputSwiftUIAdapter { adapters.button }
    public var buttonLoadingAdapter: LoadingOutputSwiftUIAdapter { adapters.buttonLoading }
    public var loadingAdapter: LoadingOutputSwiftUIAdapter { adapters.loadingView }
    public var buttonWithShrinkAdapter: ButtonOutputSwiftUIAdapter { adapters.buttonWithShrink }
    public var switchControlAdapter: SwitchCotrolOutputSwiftUIAdapter { adapters.switchControl }
    public var progressBarAdapter: ProgressBarOutputSwiftUIAdapter { adapters.progressBar }
    public var segmentedControlAdapter: SegmentedControlOutputSwiftUIAdapter { adapters.segmentedControl }
    public var refreshControlAdapter: RefreshControlOutputSwiftUIAdapter { adapters.refreshControl }
    public var datePickerAdapter: DatePickerViewOutputSwiftUIAdapter { adapters.datePicker }
    public var textFieldAdapter: TextInputOutputSwiftUIAdapter { adapters.textField }
    public var pickerViewAdapter: PickerViewOutputSwiftUIAdapter { adapters.picker }
    public var textViewAdapter: TextInputOutputSwiftUIAdapter { adapters.textView }
    public var tableViewAdapter: TableOutputSwiftUIAdapter<TestCell, Void, TestHeader> { adapters.tableView }

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

                        SUISegmentedControl(adapter: segmentedControlAdapter)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SUILabel(adapter: adapter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.2))

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

                SUILoadingView.circleStrokeLoader(
                    adapter: loadingAdapter,
                    loadingViewColor: .blue,
                    wrapperViewColor: SwiftUIColor(.black.withAlphaComponent(0.5)),
                    dimBackgroundColor: SwiftUIColor(.black.withAlphaComponent(0.3))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
            .refreshControl(adapter: refreshControlAdapter)
        }
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
