#if os(iOS)
import Combine
import SwiftUI

public final class SelectionFlowSwiftUI: ObservableObject, SelectionFlow {
    public let configuration: SelectionFlow.Model

    @Published public private(set) var isPresented = false
    @Published public private(set) var prefersFullHeight = false
    public private(set) var presentedScene: AnyView?
    private var interactiveDismissalCallback: ((SelectionType?) -> Void)?

    private let factory: SelectionFactorySwiftUI

    public init(
        configuration: SelectionFlow.Model,
        factory: SelectionFactorySwiftUI = .init()
    ) {
        self.configuration = configuration
        self.factory = factory
    }

    public func showSelection(model: SelectionPresenterModel) {
        prefersFullHeight = model.items.count > SelectionPresenter.shouldShowSearchBarThresholdCount
        interactiveDismissalCallback = model.callback
        presentedScene = factory.resolveSelection(
            configuration: configuration,
            flow: self,
            model: model
        )
        isPresented = true
    }

    public func showSelection(model: ServicedSelectionModel<some Any, some Any>) {
        prefersFullHeight = true
        interactiveDismissalCallback = model.model.callback
        presentedScene = factory.resolveSelection(
            configuration: configuration,
            flow: self,
            model: model
        )
        isPresented = true
    }

    public func close(with _: SelectionType?) {
        interactiveDismissalCallback = nil
        isPresented = false
    }

    fileprivate func dismissInteractively() {
        let callback = interactiveDismissalCallback
        interactiveDismissalCallback = nil
        callback?(nil)
        isPresented = false
    }

    fileprivate func didDismiss() {
        isPresented = false
        presentedScene = nil
        interactiveDismissalCallback = nil
    }
}

public struct SelectionFactorySwiftUI: ISelectionFactory {
    public typealias Controller = AnyView

    public init() {}

    public func resolveSelection(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: SelectionPresenterModel
    ) -> AnyView {
        let adapters = SUISelectionSceneAdapters()
        let presenter = SelectionPresenter(
            flow: WeakSelectionFlow(decoratee: flow).mainQueueDispatched,
            model: model,
            configuration: configuration
        )

        wire(presenter: presenter, adapters: adapters)
        configureSearch(input: presenter, adapters: adapters, configuration: configuration)

        var lifeCycleOutput: LifeCycleViewOutput = presenter
        if let analytics = model.screenViewAnalytics {
            lifeCycleOutput = lifeCycleOutput.withAnalytics(
                eventName: analytics.eventName,
                parameters: analytics.parameters,
                analytics: analytics.tracker
            )
        }

        return AnyView(SUISelectionScene(
            input: presenter,
            lifeCycleOutput: lifeCycleOutput,
            adapters: adapters,
            configuration: configuration
        ))
    }

    public func resolveSelection(
        configuration: SelectionFlow.Model,
        flow: SelectionFlow,
        model: ServicedSelectionModel<some Any, some Any>
    ) -> AnyView {
        let adapters = SUISelectionSceneAdapters()
        let presenter = SelectionPresenter(
            flow: WeakSelectionFlow(decoratee: flow).mainQueueDispatched,
            model: model.model,
            configuration: configuration
        )
        let servicePresenter = SelectionServiceProxy(
            decoratee: presenter,
            storage: model.storage,
            service: model.service,
            makeRequest: model.request,
            makeResponse: model.response
        )

        wire(presenter: presenter, adapters: adapters)
        adapters.refresh.display(model: .init(
            style: .init(
                tintColor: configuration.content.refreshColor,
                zPosition: 0
            ),
            onRefresh: servicePresenter.onRefresh,
            isLoading: false
        ))
        let refreshLoadingOutput: any LoadingOutput = adapters.refresh
        servicePresenter.view = refreshLoadingOutput.weakReferenced.mainQueueDispatched
        configureSearch(input: servicePresenter, adapters: adapters, configuration: configuration)

        var lifeCycleOutput: LifeCycleViewOutput = servicePresenter
        if let analytics = model.model.screenViewAnalytics {
            lifeCycleOutput = lifeCycleOutput.withAnalytics(
                eventName: analytics.eventName,
                parameters: analytics.parameters,
                analytics: analytics.tracker
            )
        }

        return AnyView(SUISelectionScene(
            input: presenter,
            lifeCycleOutput: lifeCycleOutput,
            adapters: adapters,
            configuration: configuration,
            isRefreshEnabled: true
        ))
    }

    private func wire(
        presenter: SelectionPresenter,
        adapters: SUISelectionSceneAdapters
    ) {
        presenter.view = adapters.selection.weakReferenced.mainQueueDispatched
        presenter.navBarView = adapters.header.weakReferenced.mainQueueDispatched
        presenter.resetButton = adapters.resetButton.weakReferenced.mainQueueDispatched
        presenter.selectButton = adapters.selectButton.weakReferenced.mainQueueDispatched
        presenter.emptyView = adapters.emptyView.weakReferenced.mainQueueDispatched
    }

    private func configureSearch(
        input: SelectionInput,
        adapters: SUISelectionSceneAdapters,
        configuration: SelectionFlow.Model
    ) {
        adapters.searchField.display(model: .init(
            accessibilityIdentifier: "selection.search",
            text: nil,
            isValid: true,
            isEnabledForEditing: true,
            placeholder: configuration.texts.searchTitle,
            isUserInteractionEnabled: true,
            isSecureTextEntry: false,
            autocapitalizationType: .none,
            inputType: .default,
            didChangeText: [input.onSearch]
        ))
    }
}

private final class WeakSelectionFlow: SelectionFlow {
    private weak var decoratee: (any SelectionFlow)?

    init(decoratee: any SelectionFlow) {
        self.decoratee = decoratee
    }

    func showSelection(model: SelectionPresenterModel) {
        decoratee?.showSelection(model: model)
    }

    func showSelection(model: ServicedSelectionModel<some Any, some Any>) {
        decoratee?.showSelection(model: model)
    }

    func close(with result: SelectionType?) {
        decoratee?.close(with: result)
    }
}

public struct SUISelectionSheetHost<Content: View>: View {
    @ObservedObject private var flow: SelectionFlowSwiftUI
    private let content: Content

    public init(
        flow: SelectionFlowSwiftUI,
        @ViewBuilder content: () -> Content
    ) {
        self.flow = flow
        self.content = content()
    }

    public var body: some View {
        content.sheet(
            isPresented: presentationBinding,
            onDismiss: flow.didDismiss,
            content: { presentedScene }
        )
    }

    private var presentationBinding: Binding<Bool> {
        Binding(
            get: { flow.isPresented },
            set: { isPresented in
                if !isPresented {
                    flow.dismissInteractively()
                }
            }
        )
    }

    @ViewBuilder
    private var presentedScene: some View {
        if #available(iOS 16.0, *) {
            scene
                .presentationDetents(flow.prefersFullHeight ? [.large] : [.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            scene
        }
    }

    @ViewBuilder
    private var scene: some View {
        if let presentedScene = flow.presentedScene {
            presentedScene
        } else {
            SwiftUI.EmptyView()
        }
    }
}
#endif
