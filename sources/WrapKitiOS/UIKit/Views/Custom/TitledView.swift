//
//  TitledView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

open class TitledView<ContentView: UIView>: View {
    public lazy var stackView = StackView(axis: .vertical, spacing: 4)
    public lazy var wrappedTitleLabel = WrapperView(
        contentView: Label(
            font: .systemFont(ofSize: 18),
            textColor: .black,
            numberOfLines: 0
        )
    )
    public lazy var contentView = ContentView()
    public lazy var closingTitleVFieldView = HKeyValueFieldView(isHidden: true)
    public lazy var wrappedErrorLabel = WrapperView(contentView: Label(font: .systemFont(ofSize: 14), textColor: .red), isHidden: true)
    
    public var stackViewAnchoredConstraints: AnchoredConstraints?

    public init(
        wrappedTitleLabel: WrapperView<Label> = WrapperView(
            contentView: Label(
                font: .systemFont(ofSize: 18),
                textColor: .black,
                numberOfLines: 0
            )
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
        wrappedErrorLabel: WrapperView<Label> = WrapperView(contentView: Label(font: .systemFont(ofSize: 14), textColor: .red), isHidden: true),
        spacing: CGFloat = 4
    ) {
        super.init(frame: .zero)

        self.wrappedTitleLabel = wrappedTitleLabel
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
    
    public func applyNormalState() {
        UIView.performAnimationsInSequence([
            (0.15, {
                self.wrappedErrorLabel.isHidden = true
            }, nil),
            
            (0.15, {
                self.wrappedErrorLabel.alpha = 0
            }, nil),
        ], completion: { finished in
            guard finished else { return }
            self.wrappedErrorLabel.isHidden = true
            self.wrappedErrorLabel.alpha = 0
        })
    }

    public func applyErrorState() {
        UIView.performAnimationsInSequence([
            (0.15, {
                self.wrappedErrorLabel.isHidden = false
            }, nil),
            (0.15, {
                self.wrappedErrorLabel.alpha = 1
            }, nil),
        ], completion: { finished in
            guard finished else { return }
            self.wrappedErrorLabel.isHidden = false
            self.wrappedErrorLabel.alpha = 1
        })
    }
    
    private func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(wrappedTitleLabel)
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

@available(iOS 13.0, *)
struct TitledViewFullRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> TitledView<UIView> {
        let view = TitledView()
        view.backgroundColor = .cyan
        view.wrappedTitleLabel.contentView.text = "Wrapped Label"
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
        view.wrappedTitleLabel.contentView.text = "Wrapped Label"
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
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")

            TitledViewWrappedLabelRepresentable()
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                .previewDisplayName("iPhone 12 Pro Max")

            TitledViewWrappedErrorRepresentable()
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
                .previewDisplayName("iPad Pro (9.7-inch)")
            
            TitledViewValueLabelRepresentable()
                .padding(.horizontal)
                .padding(.top, 20)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
                .previewDisplayName("iPad Pro (9.7-inch)")
        }
    }
}

#endif
