#if canImport(SwiftUI)
import SwiftUI

public struct SUICubeTransitionPage: Identifiable {
    public let id: String
    public let backgroundColor: Color?
    public let content: AnyView

    public init<Content: View>(
        id: String = UUID().uuidString,
        backgroundColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.backgroundColor = backgroundColor
        self.content = AnyView(content())
    }

    public static func color(_ color: Color, id: String = UUID().uuidString) -> SUICubeTransitionPage {
        SUICubeTransitionPage(id: id, backgroundColor: color) {
            SwiftUIColor.clear
        }
    }
}

public final class SUICubeTransitionStateModel: ObservableObject {
    public var didChangeCurrentIndex: (() -> Void)?

    @Published public private(set) var currentIndex: Int?
    @Published fileprivate var pages: [SUICubeTransitionPage] = []
    @Published fileprivate var scrollCommand: ScrollCommand?

    public var currentView: SUICubeTransitionPage? {
        guard let currentIndex else { return nil }
        guard pages.indices.contains(currentIndex) else { return nil }
        return pages[currentIndex]
    }

    public init() {}

    public func addChildViews(_ views: [SUICubeTransitionPage]) {
        pages.append(contentsOf: views)
    }

    public func addChildView(_ view: SUICubeTransitionPage) {
        addChildViews([view])
    }

    public func scrollToViewAtIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < pages.count else { return }
        scrollCommand = ScrollCommand(index: index, animated: animated)
    }

    fileprivate func didEndDecelerating(at index: Int) {
        guard currentIndex != index else { return }
        currentIndex = index
        didChangeCurrentIndex?()
    }

    fileprivate struct ScrollCommand: Equatable {
        let id = UUID()
        let index: Int
        let animated: Bool
    }
}

public struct SUICubeTransitionView: View {
    @ObservedObject private var stateModel: SUICubeTransitionStateModel
    @State private var selectedIndex = 0

    public init(stateModel: SUICubeTransitionStateModel = .init()) {
        self.stateModel = stateModel
    }

    public var body: some View {
        GeometryReader { proxy in
            TabView(selection: $selectedIndex) {
                ForEach(Array(stateModel.pages.enumerated()), id: \.element.id) { index, page in
                    page.content
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(backgroundColor(for: page))
                        .modifier(
                            CubePage3DRotation(
                                pageIndex: index,
                                selectedIndex: selectedIndex
                            )
                        )
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: proxy.size.width, height: proxy.size.height)
            .onAppear {
                selectedIndex = min(selectedIndex, max(stateModel.pages.count - 1, 0))
            }
            .onChange(of: selectedIndex) { newValue in
                stateModel.didEndDecelerating(at: newValue)
            }
            .onChange(of: stateModel.pages.count) { _ in
                selectedIndex = min(selectedIndex, max(stateModel.pages.count - 1, 0))
            }
            .onReceive(stateModel.$scrollCommand.compactMap { $0 }) { command in
                guard stateModel.pages.indices.contains(command.index) else { return }
                if command.animated {
                    withAnimation {
                        selectedIndex = command.index
                    }
                } else {
                    var transaction = Transaction()
                    transaction.animation = nil
                    withTransaction(transaction) {
                        selectedIndex = command.index
                    }
                }
            }
        }
        .clipped()
    }

    private func backgroundColor(for page: SUICubeTransitionPage) -> some View {
        Group {
            if let color = page.backgroundColor {
                SwiftUIColor(color)
            } else {
                SwiftUIColor.clear
            }
        }
    }
}

private struct CubePage3DRotation: ViewModifier {
    let pageIndex: Int
    let selectedIndex: Int

    func body(content: Content) -> some View {
        let relativeOffset = CGFloat(pageIndex - selectedIndex)
        let angle = max(-60, min(60, -60 * relativeOffset))
        let anchorX: CGFloat = relativeOffset > 0 ? 0 : 1

        return content
            .rotation3DEffect(
                .degrees(Double(angle)),
                axis: (x: 0, y: 1, z: 0),
                anchor: UnitPoint(x: anchorX, y: 0.5),
                perspective: 0.5
            )
            .opacity(opacity(relativeOffset: relativeOffset))
    }

    private func opacity(relativeOffset: CGFloat) -> Double {
        let normalized = min(abs(relativeOffset), 1)
        return Double(1 - 0.5 * normalized)
    }
}
#endif
