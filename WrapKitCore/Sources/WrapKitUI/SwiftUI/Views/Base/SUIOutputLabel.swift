#if canImport(SwiftUI)
import SwiftUI

/// Renders label state that is owned by a parent component state model.
///
/// Composite components keep the state model alive when their label branch is
/// temporarily hidden, so an in-flight `TextOutput` animation keeps the same
/// completion and replay deadline as the standalone `SUILabel`.
struct SUIOutputLabel: View {
    @ObservedObject private var stateModel: SUILabelStateModel

    private let font: Font
    private let textColor: Color
    private let textAlignment: TextAlignment

    init(
        stateModel: SUILabelStateModel,
        font: Font,
        textColor: Color,
        textAlignment: TextAlignment
    ) {
        self.stateModel = stateModel
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
    }

    @ViewBuilder
    var body: some View {
        Group {
            if !stateModel.isHidden {
                SUILabelView(
                    model: stateModel.presentable,
                    font: font,
                    textColor: textColor,
                    textAlignment: textAlignment
                )
                .id(stateModel.animationRenderGeneration)
            }
        }
        .onAppear(perform: stateModel.animationRenderingDidAppear)
    }
}
#endif
