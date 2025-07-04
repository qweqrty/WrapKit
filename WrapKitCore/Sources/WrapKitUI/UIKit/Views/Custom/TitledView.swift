//
//  TitledView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol TitledOutput: AnyObject {
    func display(model: TitledViewPresentableModel?)
    func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
    func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
    func display(leadingBottomTitle: TextOutputPresentableModel?)
    func display(trailingBottomTitle: TextOutputPresentableModel?)
    func display(isUserInteractionEnabled: Bool)
    func display(isHidden: Bool)
}

public struct TitledViewPresentableModel {
    public let titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    public let bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?
    public let isUserInteractionEnabled: Bool
    
    public init(
        titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>? = nil,
        bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>? = nil,
        isUserInteractionEnabled: Bool = true
    ) {
        self.titles = titles
        self.bottomTitles = bottomTitles
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

open class TitledView<ContentView: UIView>: ViewUIKit {
    public lazy var stackView = StackView(axis: .vertical, spacing: 4)
    public lazy var titlesView = HKeyValueFieldView(
        keyLabel: Label(),
        valueLabel: Label()
    )
    public lazy var contentView = ContentView()
    public lazy var closingTitleVFieldView = HKeyValueFieldView(isHidden: true)
    public lazy var wrappedErrorLabel = WrapperView(
        contentView: Label(font: .systemFont(ofSize: 14), textColor: .red),
        isHidden: true,
        contentViewConstraints: { contentView, wrapperView in
            contentView.fillSuperview()
        }
    )
    
    public var stackViewAnchoredConstraints: AnchoredConstraints?

    public init(
        titlesView: HKeyValueFieldView = HKeyValueFieldView(
            keyLabel: Label(),
            valueLabel: Label()
        ),
        contentView: ContentView = ContentView(),
        closingTitleVFieldView: HKeyValueFieldView = HKeyValueFieldView(
            keyLabel: Label(
                font: .systemFont(ofSize: 18),
                textColor: .black,
                numberOfLines: 1
            ),
            valueLabel: Label(
                isHidden: true,
                font: .systemFont(ofSize: 14),
                textColor: .gray,
                numberOfLines: 1,
                minimumScaleFactor: 0.5,
                adjustsFontSizeToFitWidth: true
            ),
            spacing: 4,
            contentInsets: .zero,
            isHidden: true
        ),
        wrappedErrorLabel: WrapperView<Label> = WrapperView(
            contentView: Label(font: .systemFont(ofSize: 14), textColor: .red), 
            isHidden: true,
            contentViewConstraints: { contentView, wrapperView in
                contentView.fillSuperview()
            }
        ),
        spacing: CGFloat = 4
    ) {
        super.init(frame: .zero)

        self.titlesView = titlesView
        self.contentView = contentView
        self.closingTitleVFieldView = closingTitleVFieldView
        self.stackView.spacing = spacing
        self.wrappedErrorLabel = wrappedErrorLabel
        
        setupSubviews()
        setupConstraints()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }
    
    public func applyNormalState(errorLabel: Label? = nil) {
        UIView.performAnimationsInSequence([
            (0.15, {
                (errorLabel ?? self.wrappedErrorLabel).isHidden = true
            }, nil),
            
            (0.15, {
                (errorLabel ?? self.wrappedErrorLabel).alpha = 0
            }, nil),
        ], completion: { finished in
            guard finished else { return }
            (errorLabel ?? self.wrappedErrorLabel).isHidden = true
            (errorLabel ?? self.wrappedErrorLabel).alpha = 0
        })
    }

    public func applyErrorState(errorLabel: Label? = nil) {
        UIView.performAnimationsInSequence([
            (0.15, {
                (errorLabel ?? self.wrappedErrorLabel).isHidden = false
            }, nil),
            (0.15, {
                (errorLabel ?? self.wrappedErrorLabel).alpha = 1
            }, nil),
        ], completion: { finished in
            guard finished else { return }
            (errorLabel ?? self.wrappedErrorLabel).isHidden = false
            (errorLabel ?? self.wrappedErrorLabel).alpha = 1
        })
    }
    
    private func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(titlesView)
        stackView.addArrangedSubview(contentView)
        stackView.addArrangedSubview(closingTitleVFieldView)
        stackView.addArrangedSubview(wrappedErrorLabel)
    }
    
    private func setupConstraints() {
        stackViewAnchoredConstraints = stackView.fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TitledView: TitledOutput {
    public func display(model: TitledViewPresentableModel?) {
        isHidden = model == nil
        if let titles = model?.titles { display(titles: titles) }
        if let bottomTitles = model?.bottomTitles { display(bottomTitles: bottomTitles) }
        if let isUserInteractionEnabled = model?.isUserInteractionEnabled { display(isUserInteractionEnabled: isUserInteractionEnabled) }
    }
    public func display(titles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        titlesView.display(model: titles)
    }
    
    public func display(bottomTitles: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        closingTitleVFieldView.display(model: bottomTitles)
    }
    
    public func display(leadingBottomTitle: TextOutputPresentableModel?) {
        closingTitleVFieldView.display(keyTitle: leadingBottomTitle)
    }
    
    public func display(trailingBottomTitle: TextOutputPresentableModel?) {
        closingTitleVFieldView.display(valueTitle: trailingBottomTitle)
    }
    
    public func display(isUserInteractionEnabled: Bool) {
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

@available(iOS 13.0, *)
struct TitledViewFullRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> TitledView<UIView> {
        let view = TitledView()
        view.backgroundColor = .cyan
        view.titlesView.keyLabel.text = "Key label"
        view.titlesView.valueLabel.text = "Value label"
        view.wrappedErrorLabel.contentView.text = "Wrapped Error"
        view.wrappedErrorLabel.isHidden = false
        view.closingTitleVFieldView.keyLabel.text = "Key Label"
        view.closingTitleVFieldView.valueLabel.text = "Value Label"
        view.closingTitleVFieldView.isHidden = false
        view.closingTitleVFieldView.valueLabel.isHidden = false
        return view
    }

    func updateUIView(_ uiView: TitledView<UIView>, context: Context) {
        // Leave this empty
    }
}

struct TitledViewWrappedLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> TitledView<UIView> {
        let view = TitledView()
        view.backgroundColor = .green
        view.titlesView.keyLabel.text = "Key Label"
        view.wrappedErrorLabel.isHidden = false
        view.closingTitleVFieldView.valueLabel.text = "Value Label"
        view.closingTitleVFieldView.isHidden = false
        view.closingTitleVFieldView.valueLabel.isHidden = false
        return view
    }

    func updateUIView(_ uiView: TitledView<UIView>, context: Context) {
        // Leave this empty
    }
}

struct TitledViewWrappedErrorRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> TitledView<UIView> {
        let view = TitledView()
        view.backgroundColor = .lightGray
        view.wrappedErrorLabel.contentView.text = "Wrapped Error"
        view.wrappedErrorLabel.isHidden = false
        view.closingTitleVFieldView.keyLabel.text = "Key Label"
        view.closingTitleVFieldView.isHidden = false
        view.closingTitleVFieldView.valueLabel.isHidden = false
        return view
    }

    func updateUIView(_ uiView: TitledView<UIView>, context: Context) {
        // Leave this empty
    }
}

struct TitledViewValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> TitledView<UIView> {
        let view = TitledView()
        view.backgroundColor = .yellow
        view.wrappedErrorLabel.contentView.text = "Wrapped Error"
        view.wrappedErrorLabel.isHidden = false
        view.closingTitleVFieldView.valueLabel.text = "Value Label"
        view.closingTitleVFieldView.isHidden = false
        view.closingTitleVFieldView.valueLabel.isHidden = false
        return view
    }

    func updateUIView(_ uiView: TitledView<UIView>, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct TitledView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        VStack {
            TitledViewFullRepresentable()
                .frame(height: 80)
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")

            TitledViewWrappedLabelRepresentable()
                .frame(height: 60)
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                .previewDisplayName("iPhone 12 Pro Max")

            TitledViewWrappedErrorRepresentable()
                .frame(height: 50)
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
                .previewDisplayName("iPad Pro (9.7-inch)")

            TitledViewValueLabelRepresentable()
                .frame(height: 50)
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
                .previewDisplayName("iPad Pro (9.7-inch)")
            Spacer()
        }
    }
}
#endif
