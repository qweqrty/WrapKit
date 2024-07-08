//
//  VKeyValueFieldView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import Foundation
import UIKit

//open class VKeyValueFieldView: UIView {
//    public lazy var keyLabel = Label(
//        font: .systemFont(ofSize: 11),
//        textColor: .black,
//        numberOfLines: 1
//    )
//    public lazy var valueLabel = Label(
//        font: .systemFont(ofSize: 14),
//        textColor: .black,
//        numberOfLines: 1,
//        minimumScaleFactor: 0.5,
//        adjustsFontSizeToFitWidth: true
//    )
//    
//    public var spacing: CGFloat = 0 {
//        didSet {
//            valueLabelConstraints?.top?.constant = spacing
//        }
//    }
//    
//    public var contentInsets: UIEdgeInsets = .zero {
//        didSet {
//            keyLabelConstraints?.top?.constant = contentInsets.top
//            keyLabelConstraints?.leading?.constant = contentInsets.left
//            keyLabelConstraints?.trailing?.constant = -contentInsets.right
//            
//            valueLabelConstraints?.top?.constant = contentInsets.top
//            valueLabelConstraints?.leading?.constant = contentInsets.left
//            valueLabelConstraints?.trailing?.constant = -contentInsets.right
//            valueLabelConstraints?.bottom?.constant = -contentInsets.bottom
//        }
//    }
//    
//    private(set) var keyLabelConstraints: AnchoredConstraints?
//    private(set) var valueLabelConstraints: AnchoredConstraints?
//    
//    public init(
//        keyLabel: Label = Label(
//            font: .systemFont(ofSize: 11),
//            textColor: .black,
//            numberOfLines: 0
//        ),
//        valueLabel: Label = Label(
//            font: .systemFont(ofSize: 14),
//            textColor: .black,
//            numberOfLines: 0,
//            minimumScaleFactor: 0.5,
//            adjustsFontSizeToFitWidth: true
//        ),
//        spacing: CGFloat = 4,
//        contentInsets: UIEdgeInsets = .zero,
//        isHidden: Bool = false
//    ) {
//        super.init(frame: .zero)
//        
//        self.keyLabel = keyLabel
//        self.valueLabel = valueLabel
//        self.isHidden = isHidden
//        self.spacing = spacing
//        self.contentInsets = contentInsets
//        self.valueLabel.addObserver(self, forKeyPath: "hidden", options: [.new], context: nil)
//        
//        setupSubviews()
//        setupConstraints()
//    }
//    
//    override open func observeValue(
//        forKeyPath keyPath: String?,
//        of object: Any?,
//        change: [NSKeyValueChangeKey: Any]?,
//        context: UnsafeMutableRawPointer?
//    ) {
//        guard keyPath == "hidden" else { return }
//        valueLabelConstraints?.height?.isActive = valueLabel.isHidden
//        UIView.animate(withDuration: 0.3) {
//            self.layoutIfNeeded()
//        }
//    }
//    
//    deinit {
//        valueLabel.removeObserver(self, forKeyPath: "hidden")
//    }
//    
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupSubviews()
//        setupConstraints()
//    }
//    
//    public required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setupSubviews() {
//        addSubview(keyLabel)
//        addSubview(valueLabel)
//    }
//    
//    func setupConstraints() {
//        keyLabelConstraints = keyLabel.anchor(
//            .top(topAnchor, constant: contentInsets.top),
//            .leading(leadingAnchor, constant: contentInsets.left),
//            .trailing(trailingAnchor, constant: contentInsets.right)
//        )
//        
//        valueLabelConstraints = valueLabel.anchor(
//            .top(keyLabel.bottomAnchor, constant: spacing),
//            .leading(leadingAnchor, constant: contentInsets.left),
//            .trailing(trailingAnchor, constant: contentInsets.right),
//            .bottom(bottomAnchor, constant: contentInsets.bottom),
//            .height(0, priority: .defaultLow)
//        )
//        valueLabelConstraints?.height?.isActive = false
//    }
//}

open class VKeyValueFieldView: UIView {
    public lazy var stackView = StackView(axis: .vertical, spacing: 4)
    public lazy var keyLabel = Label(
        font: .systemFont(ofSize: 11),
        textColor: .black,
        numberOfLines: 1
    )
    var keyShimmerView = ShimmerView()

    public lazy var valueLabel = Label(
        font: .systemFont(ofSize: 14),
        textColor: .black,
        numberOfLines: 1,
        minimumScaleFactor: 0.5,
        adjustsFontSizeToFitWidth: true
    )
    
    var valueShimmerView = ShimmerView()

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
        keyShimmerView.isHidden = true
        valueShimmerView.isHidden = true

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
    
    public func runShimmer(showKeyShimmer: Bool, showValueShimmer: Bool) {
        keyShimmerView.isHidden = !showKeyShimmer
        valueShimmerView.isHidden = !showValueShimmer
        keyShimmerView.startShimmering()
        valueShimmerView.startShimmering()
    }
    
    public func stopShimmer() {
        keyShimmerView.isHidden = true
        valueShimmerView.isHidden = true
        
        keyLabel.isHidden = false
        valueLabel.isHidden = false
    }
}

extension VKeyValueFieldView {
    func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(keyLabel)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(keyShimmerView)
        stackView.addArrangedSubview(valueShimmerView)
    }

    func setupConstraints() {
        stackView.anchor(
            .top(topAnchor),
            .bottom(bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor)
        )
        
        keyShimmerView.anchor(
            .height(8),
            .width(168)
        )
        valueShimmerView.anchor(
            .height(8),
            .width(88)
        )
    }
}
#endif
