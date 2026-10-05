import Foundation

#if canImport(SwiftUI)
import SwiftUI

public extension View {

    func measureSize(_ size: Binding<CGSize>) -> some View {
        modifier(SizeReader(size: size))
    }

    func measureFrame(_ rect: Binding<CGRect>, offset: CGPoint = .zero) -> some View {
        modifier(FrameReader(rect: rect, offset: offset))
    }
}

struct ViewSizeKey: PreferenceKey {

    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeReader: ViewModifier {

    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    SwiftUIColor.clear
                        .preference(key: ViewSizeKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(ViewSizeKey.self) { newSize in
                Task { @MainActor in
                    size = newSize
                }
            }
    }
}

struct ViewFrameKey: PreferenceKey {

    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct FrameReader: ViewModifier {

    @Binding var rect: CGRect
    let offset: CGPoint

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    geometryReaderContent(proxy: proxy)
                }
            )
            .onPreferenceChange(ViewFrameKey.self) { newRect in
                Task { @MainActor in
                    guard !newRect.isEmpty else { return }
                    rect = offsetRect(newRect)
                }
            }
    }

    @ViewBuilder
    private func geometryReaderContent(proxy: GeometryProxy) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            SwiftUIColor.clear
                .preference(key: ViewFrameKey.self, value: proxy.frame(in: .global))
                .onGeometryChange(for: CGRect.self) { geometry in
                    geometry.frame(in: .global)
                } action: { newValue in
                    rect = offsetRect(newValue)
                }
                .onAppear {
                    rect = offsetRect(proxy.frame(in: .global))
                }
        } else {
            SwiftUIColor.clear
                .preference(key: ViewFrameKey.self, value: proxy.frame(in: .global))
                .onAppear {
                    rect = offsetRect(proxy.frame(in: .global))
                }
        }
    }

    private func offsetRect(_ rect: CGRect) -> CGRect {
        var value = rect

        value.origin.x += offset.x
        value.origin.y += offset.y

        return value
    }
}

#endif
