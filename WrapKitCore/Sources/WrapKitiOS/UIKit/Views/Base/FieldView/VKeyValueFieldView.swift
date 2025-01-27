//
//  VKeyValueFieldView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

public protocol KeyValueFieldViewOutput: AnyObject {
    func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>)
    func display(keyTitle: TextOutputPresentableModel?)
    func display(valueTitle: TextOutputPresentableModel?)
}

#if canImport(UIKit)
import UIKit
import SwiftUI

extension VKeyValueFieldView: KeyValueFieldViewOutput {
    public func display(model: Pair<TextOutputPresentableModel?, TextOutputPresentableModel?>) {
        isHidden = model.first == nil && model.second == nil
        display(keyTitle: model.first)
        display(valueTitle: model.second)
    }
    
    public func display(keyTitle: TextOutputPresentableModel?) {
        isHidden = keyTitle == nil && valueLabel.isHidden
        keyLabel.isHidden = keyTitle == nil
        keyLabel.display(model: keyTitle)
    }
    
    public func display(valueTitle: TextOutputPresentableModel?) {
        isHidden = valueTitle == nil && keyLabel.isHidden
        valueLabel.isHidden = valueTitle == nil
        valueLabel.display(model: valueTitle)
    }
}

open class VKeyValueFieldView: UIView {
    public lazy var stackView = StackView(axis: .vertical, spacing: 4)
    public lazy var keyLabel = Label(
        font: .systemFont(ofSize: 11),
        textColor: .black,
        numberOfLines: 1
    )
    public lazy var valueLabel = Label(
        font: .systemFont(ofSize: 14),
        textColor: .black,
        numberOfLines: 1,
        minimumScaleFactor: 0.5,
        adjustsFontSizeToFitWidth: true
    )

    public init(
        keyLabel: Label = Label(
            font: .systemFont(ofSize: 11),
            textColor: .black,
            numberOfLines: 1
        ),
        valueLabel: Label = Label(
            font: .systemFont(ofSize: 14),
            textColor: .black,
            numberOfLines: 1,
            minimumScaleFactor: 0.5,
            adjustsFontSizeToFitWidth: true
        ),
        spacing: CGFloat = 4,
        contentInsets: UIEdgeInsets = .zero,
        isHidden: Bool = false
    ) {
        super.init(frame: .zero)

        self.stackView = StackView(axis: .vertical, spacing: spacing, contentInset: contentInsets)
        self.keyLabel = keyLabel
        self.valueLabel = valueLabel
        self.isHidden = isHidden

        setupSubviews()
        setupConstraints()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VKeyValueFieldView {
    func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(valueLabel)
    }

    func setupConstraints() {
        stackView.anchor(
            .top(topAnchor),
            .bottom(bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
    }
}

@available(iOS 13.0, *)
struct VKeyValueFieldViewKeyLabelValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> VKeyValueFieldView {
        let view = VKeyValueFieldView()
        view.backgroundColor = .cyan
        view.keyLabel.text = "Key Label"
        view.valueLabel.text = "Value Label"
        return view
    }

    func updateUIView(_ uiView: VKeyValueFieldView, context: Context) {
        // Leave this empty
    }
}

struct VKeyValueFieldViewKeyLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> VKeyValueFieldView {
        let view = VKeyValueFieldView()
        view.backgroundColor = .yellow
        view.keyLabel.text = "Key Label"
        view.valueLabel.isHidden = true
        return view
    }

    func updateUIView(_ uiView: VKeyValueFieldView, context: Context) {
        // Leave this empty
    }
}

struct VKeyValueFieldViewValueLabelRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> VKeyValueFieldView {
        let view = VKeyValueFieldView()
        view.backgroundColor = .green
        view.keyLabel.isHidden = true
        view.valueLabel.text = "Value Label"
        return view
    }

    func updateUIView(_ uiView: VKeyValueFieldView, context: Context) {
        // Leave this empty
    }
}

@available(iOS 13.0, *)
struct VKeyValueFieldView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        VStack {
            VKeyValueFieldViewKeyLabelValueLabelRepresentable()
                .frame(height: 35)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")

            VKeyValueFieldViewKeyLabelRepresentable()
                .frame(height: 25)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")

            VKeyValueFieldViewValueLabelRepresentable()
                .frame(height: 25)
                .padding()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE (2nd generation)")
            Spacer()
        }
    }
}
#endif
