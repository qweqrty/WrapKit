//
//  VKeyValueFieldView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

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
            .topGreaterThanEqual(topAnchor),
            .bottomLessThanEqual(bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .centerY(centerYAnchor)
        )
    }
}
#endif
