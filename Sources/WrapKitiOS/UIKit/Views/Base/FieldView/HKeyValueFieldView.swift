//
//  HKeyValueFieldView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

open class HKeyValueFieldView: View {
    public let mainView = View(backgroundColor: .clear)
    public let mainStackView: StackView
    public let keyLabel: Label
    public let valueLabel: Label
    
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
        self.mainStackView.spacing = spacing
        self.mainStackView.layoutMargins = contentInsets
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
        addSubview(mainView)
        mainView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(keyLabel)
        mainStackView.addArrangedSubview(valueLabel)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setupConstraints() {
        mainView.fillSuperview()
        mainStackView.fillSuperview()
    }
}
#endif
