//
//  HKeyValueFieldView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

extension HKeyValueFieldView: KeyValueFieldViewOutput {
    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>?) {
        display(keyTitle: model?.first)
        display(valueTitle: model?.second)
    }
    
    public func display(keyTitle: TextOutputPresentableModel?) {
        keyLabel.isHidden = keyTitle == nil
        keyLabel.display(model: keyTitle)
        updateVisibility()
    }
    
    public func display(valueTitle: TextOutputPresentableModel?) {
        valueLabel.isHidden = valueTitle == nil
        valueLabel.display(model: valueTitle)
        updateVisibility()
    }
    
    public func display(bottomImage: ImageViewPresentableModel?) {
        bottomImageWrapperView.isHidden = bottomImage == nil
        bottomImageView.display(model: bottomImage)
        updateVisibility()
    }

    private func updateVisibility() {
        isHidden = keyLabel.isHidden && valueLabel.isHidden && bottomImageWrapperView.isHidden
    }
}

open class HKeyValueFieldView: ViewUIKit {
    public let contentStackView = StackView(axis: .vertical)
    public let mainView = ViewUIKit(backgroundColor: .clear)
    public let mainStackView: StackView
    public let keyLabel: Label
    public let valueLabel: Label
    public let bottomImageWrapperView = UIView(isHidden: true)
    public let bottomImageView = ImageView(tintColor: .black)
    
    public init(
        backgroundColor: UIColor = .clear,
        mainStackView: StackView = StackView(distribution: .fill),
        keyLabel: Label = Label(
            font: .systemFont(ofSize: 11),
            textColor: .black,
            numberOfLines: 1,
            minimumScaleFactor: 0.5,
            adjustsFontSizeToFitWidth: true
        ),
        valueLabel: Label = Label(
            font: .systemFont(ofSize: 16),
            textColor: .black,
            textAlignment: .right,
            numberOfLines: 1,
            minimumScaleFactor: 0.5,
            adjustsFontSizeToFitWidth: true
        ),
        spacing: CGFloat = 4,
        contentInsets: UIEdgeInsets = .zero,
        isHidden: Bool = false
    ) {
        self.mainStackView = mainStackView
        self.keyLabel = keyLabel
        self.valueLabel = valueLabel
        
        super.init(frame: .zero)
       
        self.backgroundColor = backgroundColor
        self.contentStackView.spacing = spacing
        self.contentStackView.layoutMargins = contentInsets
        self.mainStackView.spacing = spacing
        self.mainStackView.layoutMargins = .zero
        self.isHidden = isHidden
        
        setupSubviews()
        setupConstraints()
    }
    
    public override init(frame: CGRect) {
        mainStackView = StackView()
        keyLabel = Label(
            font: .systemFont(ofSize: 11),
            textColor: .black,
            numberOfLines: 1,
            minimumScaleFactor: 0.5,
            adjustsFontSizeToFitWidth: true
        )
        valueLabel = Label(
            font: .systemFont(ofSize: 16),
            textColor: .black,
            textAlignment: .right,
            numberOfLines: 1,
            minimumScaleFactor: 0.5,
            adjustsFontSizeToFitWidth: true
        )
        
        super.init(frame: frame)
        
        setupSubviews()
        setupConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HKeyValueFieldView {
    func setupSubviews() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(mainView)
        contentStackView.addArrangedSubview(bottomImageWrapperView)
        mainView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(keyLabel)
        mainStackView.addArrangedSubview(valueLabel)
        bottomImageWrapperView.addSubview(bottomImageView)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setupConstraints() {
        contentStackView.fillSuperview()
        mainStackView.fillSuperview()
        bottomImageView.anchor(
            .top(bottomImageWrapperView.topAnchor),
            .bottom(bottomImageWrapperView.bottomAnchor),
            .leading(bottomImageWrapperView.leadingAnchor),
            .trailingLessThanEqual(bottomImageWrapperView.trailingAnchor)
        )
    }
}

@available(iOS 13.0, *)
struct HKeyValueFieldViewKeyLabelValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> HKeyValueFieldView {
        let view = HKeyValueFieldView()
        view.mainView.backgroundColor = .cyan
        view.keyLabel.text = "Key Label"
        view.valueLabel.text = "Value Label"
        return view
    }

    func updateUIView(_ uiView: HKeyValueFieldView, context: Context) {
        // Leave this empty
    }
}

struct HKeyValueFieldViewKeyLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> HKeyValueFieldView {
        let view = HKeyValueFieldView()
        view.mainView.backgroundColor = .yellow
        view.keyLabel.text = "Key Label"
        return view
    }

    func updateUIView(_ uiView: HKeyValueFieldView, context: Context) {
        // Leave this empty
    }
}

struct HKeyValueFieldViewValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> HKeyValueFieldView {
        let view = HKeyValueFieldView()
        view.mainView.backgroundColor = .green
        view.valueLabel.text = "Value Label"
        return view
    }

    func updateUIView(_ uiView: HKeyValueFieldView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct HKeyValueFieldView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        VStack {
            HKeyValueFieldViewKeyLabelValueLabelRepresentable()
                .frame(height: 25)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")

            HKeyValueFieldViewKeyLabelRepresentable()
                .frame(height: 25)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")

            HKeyValueFieldViewValueLabelRepresentable()
                .frame(height: 25)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
            Spacer()
        }
    }
}
#endif
