import SwiftUI
import UIKit
import WrapKit

@available(iOS 16.0, *)
struct HeaderAfterPopFixture: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        let coordinator = context.coordinator
        coordinator.navigationController = navigationController
        let rootView = HeaderAfterPopRootView(
            state: coordinator.rootState,
            onPush: { [weak coordinator] in coordinator?.pushChild() }
        )
        let root = SUIHostingController(rootView: NavigationStack { rootView })
        navigationController.setViewControllers([root], animated: false)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    final class Coordinator {
        fileprivate let rootState = HeaderAfterPopRootState()
        weak var navigationController: UINavigationController?

        func pushChild() {
            let header = HeaderOutputSwiftUIAdapter()
            header.display(model: .init(
                centerView: .keyValue(.init(.text("Details"), nil)),
                leadingCard: .init(
                    accessibilityIdentifier: "headerAfterPop.back",
                    accessibility: .init(label: "Back"),
                    leadingImage: .init(image: .asset(UIImage(systemName: "chevron.backward"))),
                    onPress: { [weak navigationController] in
                        navigationController?.popViewController(animated: true)
                    }
                )
            ))
            let child = SUIHostingController(rootView: NavigationStack {
                VStack {
                    Text("Child screen").accessibilityIdentifier("headerAfterPop.child")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(SwiftUI.Color(uiColor: .systemGroupedBackground))
                .navigationHeader(adapter: header)
            })
            navigationController?.pushViewController(child, animated: true)
        }
    }
}

@available(iOS 16.0, *)
private final class HeaderAfterPopRootState: ObservableObject, LifeCycleViewOutput {
    let header = HeaderOutputSwiftUIAdapter()
    @Published var pressCount = 0

    func viewDidLoad() {
        header.display(model: .init(
            centerView: .keyValue(.init(.text("Plans"), nil)),
            leadingCard: .init(
                accessibilityIdentifier: "headerAfterPop.reset",
                accessibility: .init(label: "Reset"),
                leadingImage: .init(image: .asset(UIImage(systemName: "arrow.counterclockwise"))),
                onPress: { [weak self] in self?.pressCount = 0 }
            )
        ))
    }

    func viewWillAppear() {
        header.display(primeTrailingImage: .init(
            accessibilityIdentifier: "headerAfterPop.search",
            accessibility: .init(label: "Search"),
            image: UIImage(systemName: "magnifyingglass"),
            onPress: { [weak self] in self?.pressCount += 1 }
        ))
    }
}

@available(iOS 16.0, *)
private struct HeaderAfterPopRootView: View {
    @ObservedObject var state: HeaderAfterPopRootState
    let onPush: () -> Void

    var body: some View {
        LifeCycleView(lifeCycleOutput: state) {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Header root").accessibilityIdentifier("headerAfterPop.root")
                    Text("Presses: \(state.pressCount)")
                        .accessibilityIdentifier("headerAfterPop.pressCount")
                    SwiftUI.Button("Open child", action: onPush)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("headerAfterPop.push")
                    ForEach(0..<12) { index in
                        Text("Plan \(index)")
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(SwiftUI.Color(uiColor: .secondarySystemGroupedBackground))
                    }
                }
                .padding()
            }
            .background(SwiftUI.Color(uiColor: .systemGroupedBackground))
        }
        .navigationHeader(adapter: state.header)
    }
}
