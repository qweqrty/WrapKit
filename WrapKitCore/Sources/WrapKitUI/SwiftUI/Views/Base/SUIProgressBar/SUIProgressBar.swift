//
//  SUIProgressBar.swift
//  WrapKit
//
//  Created by Urmatbek Marat Uulu on 22/4/26.
//

import SwiftUI

public struct SUIProgressBar: View {
    @StateObject var stateModel: SUIProgressBarStateModel
    
    public init(adaper: ProgressBarOutputSwiftUIAdapter) {
        _stateModel = .init(wrappedValue: .init(adapter: adaper))
    }

    init(stateModel: SUIProgressBarStateModel) {
        _stateModel = .init(wrappedValue: stateModel)
    }
    
    public var body: some View {
        if !stateModel.isHidden {
            SUIProgressBarView(
                progress: stateModel.progress,
                style: stateModel.style,
                animatesProgressChanges: stateModel.animatesProgressChanges,
                layoutHeight: stateModel.layoutHeight
            )
        }
    }
}

public struct SUIProgressBarView: View {
    let progress: CGFloat // 0-100
    let style: ProgressBarStyle?
    let animatesProgressChanges: Bool
    private let layoutHeight: CGFloat?
    
    public init(
        progress: CGFloat = 0,
        style: ProgressBarStyle? = nil,
        animatesProgressChanges: Bool = true
    ) {
        self.progress = progress
        self.style = style
        self.animatesProgressChanges = animatesProgressChanges
        self.layoutHeight = nil
    }

    init(
        progress: CGFloat,
        style: ProgressBarStyle?,
        animatesProgressChanges: Bool,
        layoutHeight: CGFloat
    ) {
        self.progress = progress
        self.style = style
        self.animatesProgressChanges = animatesProgressChanges
        self.layoutHeight = layoutHeight
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                SUIProgressBarCornerShape(style: cornerStyle)
                    .fill(style?.backgroundColor.map { SwiftUIColor($0) } ?? .clear)
                    .frame(height: trackHeight)

                if normalizedProgress > 0 {
                    SUIProgressBarCornerShape(style: cornerStyle)
                        .fill(style?.progressBarColor.map { SwiftUIColor($0) } ?? SwiftUIColor(.systemBlue))
                        .frame(
                            width: geo.size.width * normalizedProgress,
                            height: fillHeight
                        )
                        .animation(animatesProgressChanges ? .easeInOut : nil, value: normalizedProgress)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(height: layoutHeight ?? style?.height ?? 4)
    }

    private var trackHeight: CGFloat {
        let fillHeight = style?.height ?? 4
        return style?.trackHeight ?? (fillHeight - (fillHeight / 3).rounded(.up))
    }

    private var fillHeight: CGFloat {
        layoutHeight ?? style?.height ?? 4
    }

    private var normalizedProgress: CGFloat {
        max(0, min(1, progress / 100))
    }

    private var cornerStyle: CornerStyle {
        style?.cornerStyle ?? .fixed(4)
    }
}

private struct SUIProgressBarCornerShape: Shape {
    let style: CornerStyle

    func path(in rect: CGRect) -> Path {
        if #available(iOS 26, tvOS 26, visionOS 26, *) {
            return SUICornerShape(style: style).path(in: rect)
        }
        return legacyUIKitPath(in: rect)
    }

    private func legacyUIKitPath(in rect: CGRect) -> Path {
        let radii = legacyUIKitCornerRadii(in: rect)
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + radii.topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radii.topRight, y: rect.minY))
        addArc(
            to: &path,
            center: CGPoint(x: rect.maxX - radii.topRight, y: rect.minY + radii.topRight),
            radius: radii.topRight,
            startAngle: -90,
            endAngle: 0
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radii.bottomRight))
        addArc(
            to: &path,
            center: CGPoint(x: rect.maxX - radii.bottomRight, y: rect.maxY - radii.bottomRight),
            radius: radii.bottomRight,
            startAngle: 0,
            endAngle: 90
        )
        path.addLine(to: CGPoint(x: rect.minX + radii.bottomLeft, y: rect.maxY))
        addArc(
            to: &path,
            center: CGPoint(x: rect.minX + radii.bottomLeft, y: rect.maxY - radii.bottomLeft),
            radius: radii.bottomLeft,
            startAngle: 90,
            endAngle: 180
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radii.topLeft))
        addArc(
            to: &path,
            center: CGPoint(x: rect.minX + radii.topLeft, y: rect.minY + radii.topLeft),
            radius: radii.topLeft,
            startAngle: 180,
            endAngle: 270
        )
        path.closeSubpath()
        return path
    }

    private func addArc(
        to path: inout Path,
        center: CGPoint,
        radius: CGFloat,
        startAngle: Double,
        endAngle: Double
    ) {
        guard radius > 0 else {
            path.addLine(to: center)
            return
        }
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
    }

    private func legacyUIKitCornerRadii(in rect: CGRect) -> CornerStyle.Corners {
        switch style {
        case .automatic:
            return .init(all: min(rect.width, rect.height) / 2)
        case .fixed(let radius):
            return .init(all: max(radius, 0))
        case .corners(let corners):
            let radius = max(corners.maximum, 0)
            return .init(
                topLeft: corners.topLeft > 0 ? radius : 0,
                topRight: corners.topRight > 0 ? radius : 0,
                bottomLeft: corners.bottomLeft > 0 ? radius : 0,
                bottomRight: corners.bottomRight > 0 ? radius : 0
            )
        case .none:
            return .init(all: 0)
        }
    }
}

#Preview {
    SUIProgressBarView(
        progress: 50,
        style: .init(
            backgroundColor: .lightGray,
            progressBarColor: .systemBlue,
            height: 20,
            cornerStyle: .fixed(16)
        )
    )
    .padding()
}
