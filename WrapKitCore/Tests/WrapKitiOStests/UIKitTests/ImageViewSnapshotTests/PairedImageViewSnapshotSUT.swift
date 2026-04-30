//
//  PairedImageViewSnapshotSUT.swift
//  WrapKit
//
//  Created by Ulan Beishenkulov on 22/4/26.
//

import Foundation
import WrapKit
import WrapKitTestUtils
import SwiftUI

final class PairedImageViewSnapshotSUT: NSObject {
    let uiKitImageView = ImageView()
    let adapter = ImageViewOutputSwiftUIAdapter()
    let state = PairedImageSnapshotState()
    private var shouldCaptureSwiftUILoadingState = false

    func cleanup() {
        uiKitImageView.display(image: nil, completion: nil)
        uiKitImageView.display(onPress: nil)
        uiKitImageView.display(onLongPress: nil)
        uiKitImageView.viewWhileLoadingView = nil
        uiKitImageView.fallbackView = nil
        uiKitImageView.wrongUrlPlaceholderImage = nil

        state.backgroundColor = nil
        state.viewWhileLoadingView = nil
        state.fallbackView = nil
        state.fallbackColor = nil
        state.wrongUrlPlaceholderImage = nil
        state.isHidden = true
        state.alpha = nil

        adapter.display(model: nil, completion: nil)
        adapter.display(image: nil, completion: nil)
        adapter.display(onPress: nil)
        adapter.display(onLongPress: nil)
        adapter.display(size: nil)
        adapter.display(borderWidth: nil)
        adapter.display(borderColor: nil)
        adapter.display(cornerRadius: nil)
        adapter.display(alpha: nil)
        adapter.display(isHidden: true)
        shouldCaptureSwiftUILoadingState = false
        state.forceLoadingState = false
        state.forceFallbackState = false
    }
}

extension PairedImageViewSnapshotSUT {
    var backgroundColor: UIColor? {
        get { uiKitImageView.backgroundColor }
        set {
            uiKitImageView.backgroundColor = newValue
            state.backgroundColor = newValue
        }
    }

    var wrongUrlPlaceholderImage: UIImage? {
        get { uiKitImageView.wrongUrlPlaceholderImage }
        set {
            uiKitImageView.wrongUrlPlaceholderImage = newValue
            state.wrongUrlPlaceholderImage = newValue
        }
    }

    var viewWhileLoadingView: ViewUIKit? {
        get { uiKitImageView.viewWhileLoadingView }
        set {
            uiKitImageView.viewWhileLoadingView = newValue
            state.viewWhileLoadingView = newValue.map { AnyView(PairedUIKitView(view: $0)) }
            state.viewWhileLoadingColor = newValue?.backgroundColor
        }
    }

    var fallbackView: ViewUIKit? {
        get { uiKitImageView.fallbackView }
        set {
            uiKitImageView.fallbackView = newValue
            state.fallbackView = newValue.map { AnyView(PairedUIKitView(view: $0)) }
            state.fallbackColor = newValue?.backgroundColor
        }
    }

    var onPress: (() -> Void)? {
        get { uiKitImageView.onPress }
        set {
            uiKitImageView.onPress = newValue
            adapter.display(onPress: newValue)
        }
    }

    var onLongPress: (() -> Void)? {
        get { uiKitImageView.onLongPress }
        set {
            uiKitImageView.onLongPress = newValue
            adapter.display(onLongPress: newValue)
        }
    }
}

extension PairedImageViewSnapshotSUT: ImageViewOutput {
    func display(model: ImageViewPresentableModel?, completion: ((WrapKit.Image?) -> Void)?) {
        let shouldCaptureLoading = shouldCaptureLoadingState(
            hasCompletion: completion != nil,
            image: model?.image
        )
        if shouldCaptureLoading {
            uiKitImageView.display(model: model, completion: completion)
        } else {
            uiKitImageView.display(model: model) { [weak self] image in
                self?.syncSwiftUIFinalState(with: image)
                completion?(image)
            }
        }
        adapter.display(model: model)
        shouldCaptureSwiftUILoadingState = shouldCaptureLoading
        state.forceLoadingState = shouldCaptureSwiftUILoadingState
        if shouldCaptureSwiftUILoadingState {
            state.forceFallbackState = false
        }
    }

    func display(image: ImageEnum?, completion: ((WrapKit.Image?) -> Void)?) {
        let shouldCaptureLoading = shouldCaptureLoadingState(
            hasCompletion: completion != nil,
            image: image
        )
        if shouldCaptureLoading {
            uiKitImageView.display(image: image, completion: completion)
        } else {
            uiKitImageView.display(image: image) { [weak self] image in
                self?.syncSwiftUIFinalState(with: image)
                completion?(image)
            }
        }
        adapter.display(image: image)
        shouldCaptureSwiftUILoadingState = shouldCaptureLoading
        state.forceLoadingState = shouldCaptureSwiftUILoadingState
        if shouldCaptureSwiftUILoadingState {
            state.forceFallbackState = false
        }
    }

    func display(size: CGSize?) {
        uiKitImageView.display(size: size)
        adapter.display(size: size)
    }

    func display(onPress: (() -> Void)?) {
        uiKitImageView.display(onPress: onPress)
        adapter.display(onPress: onPress)
    }

    func display(onLongPress: (() -> Void)?) {
        uiKitImageView.display(onLongPress: onLongPress)
        adapter.display(onLongPress: onLongPress)
    }

    func display(contentModeIsFit: Bool) {
        uiKitImageView.display(contentModeIsFit: contentModeIsFit)
        adapter.display(contentModeIsFit: contentModeIsFit)
    }

    func display(borderWidth: CGFloat?) {
        uiKitImageView.display(borderWidth: borderWidth)
        adapter.display(borderWidth: borderWidth)
    }

    func display(borderColor: WrapKit.Color?) {
        uiKitImageView.display(borderColor: borderColor)
        adapter.display(borderColor: borderColor)
    }

    func display(cornerRadius: CGFloat?) {
        uiKitImageView.display(cornerRadius: cornerRadius)
        adapter.display(cornerRadius: cornerRadius)
    }

    func display(alpha: CGFloat?) {
        uiKitImageView.display(alpha: alpha)
        adapter.display(alpha: alpha)
        state.alpha = alpha
    }

    func display(isHidden: Bool) {
        uiKitImageView.display(isHidden: isHidden)
        adapter.display(isHidden: isHidden)
        state.isHidden = isHidden
    }
}

private extension PairedImageViewSnapshotSUT {
    func shouldCaptureLoadingState(hasCompletion: Bool, image: ImageEnum?) -> Bool {
        guard hasCompletion == false, image?.isRemote == true else { return false }
        return state.viewWhileLoadingView != nil && state.fallbackView == nil
    }

    func syncSwiftUIFinalState(with image: WrapKit.Image?) {
        state.forceLoadingState = false
        state.forceFallbackState = image == nil && state.fallbackView != nil

        if let image {
            adapter.display(image: .asset(image.withRenderingMode(.alwaysOriginal)))
        } else {
            adapter.display(image: nil)
        }
    }
}

extension PairedImageViewSnapshotSUT {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiKitImageView.touchesBegan(touches, with: event)
        adapter.display(alpha: uiKitImageView.alpha)
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        uiKitImageView.touchesEnded(touches, with: event)
        adapter.display(alpha: uiKitImageView.alpha)
    }

    func showFallbackForSnapshot() {
        state.forceLoadingState = false
        state.forceFallbackState = state.fallbackView != nil || state.fallbackColor != nil
    }

    func showLoadingForSnapshot(color: UIColor?) {
        state.forceFallbackState = false
        state.forceLoadingState = true
        if let color {
            state.viewWhileLoadingColor = color
        }
    }
}

@available(iOS 17, *)
extension PairedImageViewSnapshotSUT {
    func swiftUISnapshot(for style: ColorScheme) -> UIImage {
        let configuration = SUISnapshotConfiguration.iPhone(style: style)
        let rootView = PairedImageSnapshotContainer(adapter: adapter, state: state)
            .build(configuration: configuration, background: .clear)

        let hostingController = UIHostingController(rootView: rootView.ignoresSafeArea(.all))
        hostingController.view.backgroundColor = .clear
        let warmup = shouldCaptureSwiftUILoadingState ? 0.01 : 0.12
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(warmup))

        return hostingController.snapshot(
            for: .iPhone(style: style == .dark ? .dark : .light)
        )
    }
}

private extension ImageEnum {
    var isRemote: Bool {
        switch self {
        case .url, .urlString:
            return true
        case .asset, .data:
            return false
        }
    }
}

final class PairedImageSnapshotState: ObservableObject {
    @Published var backgroundColor: UIColor?
    @Published var viewWhileLoadingView: AnyView?
    @Published var viewWhileLoadingColor: UIColor?
    @Published var fallbackView: AnyView?
    @Published var fallbackColor: UIColor?
    @Published var wrongUrlPlaceholderImage: UIImage?
    @Published var forceLoadingState: Bool = false
    @Published var forceFallbackState: Bool = false
    @Published var isHidden: Bool = false
    @Published var alpha: CGFloat?
}

private struct PairedImageSnapshotContainer: View {
    let adapter: ImageViewOutputSwiftUIAdapter
    @ObservedObject var state: PairedImageSnapshotState

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: .zero) {
                ZStack(alignment: .topLeading) {
                    if !state.isHidden, let backgroundColor = state.backgroundColor {
                        SwiftUIColor(backgroundColor).opacity(state.alpha ?? 1)
                    }

                    SUIImageView(
                        adapter: adapter,
                        viewWhileLoadingView: state.viewWhileLoadingView,
                        fallbackView: state.fallbackView,
                        wrongUrlPlaceholderImage: state.wrongUrlPlaceholderImage,
                        backgroundColor: state.backgroundColor.map(SwiftUIColor.init)
                    )
                }
                .frame(height: 150, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

            if state.forceLoadingState, let loading = state.viewWhileLoadingView {
                Group {
                    if let color = state.viewWhileLoadingColor {
                        SwiftUIColor(color)
                    } else {
                        loading
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 150, alignment: .topLeading)
            }

            if state.forceFallbackState, let fallback = state.fallbackView {
                Group {
                    if let color = state.fallbackColor {
                        SwiftUIColor(color)
                    } else {
                        fallback
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 150, alignment: .topLeading)
            }
        }
    }
}

private struct PairedUIKitView: UIViewRepresentable {
    let view: UIView

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        view.removeFromSuperview()
        container.addSubview(view)
        view.frame = container.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if view.superview !== uiView {
            view.removeFromSuperview()
            uiView.addSubview(view)
            view.frame = uiView.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
}
