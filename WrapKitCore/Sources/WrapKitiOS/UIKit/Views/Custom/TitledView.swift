//
//  TitledView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol TitledOutput<ContentView>: AnyObject {
    associatedtype ContentView
    func display(model: TitledViewPresentableModel<ContentView>?)
    func display(keyTitle: [TextAttributes])
    func display(valueTitle: [TextAttributes])
}

public struct TitledViewPresentableModel<ContentView> {
    public let contentView: ContentView
    public let keyTitle: [TextAttributes]
    public let valueTitle: [TextAttributes]
    
    public init(
        contentView: ContentView = UIView(),
        keyTitle: [TextAttributes] = [],
        valueTitle: [TextAttributes] = []
    ) {
        self.contentView = contentView
        self.keyTitle = keyTitle
        self.valueTitle = valueTitle
    }
}

#if canImport(UIKit)
import UIKit
import SwiftUI

open class TitledView<ContentView: UIView>: View {
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
    public func display(model: TitledViewPresentableModel<ContentView>?) {
        isHidden = model == nil
        guard let model = model else { return }
        self.contentView = model.contentView
        titlesView.keyLabel.display(model: .init(text: nil, attributes: model.keyTitle))
        titlesView.valueLabel.display(model: .init(text: nil, attributes: model.valueTitle))
    }
    public func display(keyTitle: [TextAttributes]) {
        titlesView.keyLabel.display(model: .init(text: nil, attributes: keyTitle))
    }
    
    public func display(valueTitle: [TextAttributes]) {
        titlesView.valueLabel.display(model: .init(text: nil, attributes: valueTitle))
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
