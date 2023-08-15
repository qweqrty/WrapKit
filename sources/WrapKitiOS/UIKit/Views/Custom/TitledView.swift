//
//  TitledView.swift
//  WrapKit
//
//  Created by Stas Lee on 5/8/23.
//

#if canImport(UIKit)
import UIKit

open class TitledView<ContentView: UIView>: View {
    public lazy var stackView = StackView(axis: .vertical, spacing: 4)
    public lazy var titleLabel = Label(
        font: .systemFont(ofSize: 18),
        textColor: .black,
        numberOfLines: 0
    )
    public lazy var contentView = ContentView()
    public lazy var closingTitleVFieldView = HKeyValueFieldView()
    public lazy var errorView = Label(font: .systemFont(ofSize: 14), textColor: .red)
    
    public var stackViewAnchoredConstraints: AnchoredConstraints?

    public init(
        titleLabel: Label = Label(
        font: .systemFont(ofSize: 18),
        textColor: .black,
        numberOfLines: 0
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
            isHidden: false
        ),
        spacing: CGFloat = 4
    ) {
        super.init(frame: .zero)

        self.titleLabel = titleLabel
        self.contentView = contentView
        self.closingTitleVFieldView = closingTitleVFieldView
        self.stackView.spacing = spacing
        
        setupSubviews()
        setupConstraints()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
    }
    
    public func applyErrorState() {
        UIView.animate(withDuration: 0.3) {
            self.errorView.isHidden = false
            self.errorView.alpha = 1
        }
    }
    
    public func applyNormalState() {
        UIView.animate(withDuration: 0.3) {
            self.errorView.isHidden = true
            self.errorView.alpha = 0
        }
    }
    
    private func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentView)
        stackView.addArrangedSubview(closingTitleVFieldView)
        stackView.addArrangedSubview(errorView)
    }
    
    private func setupConstraints() {
        stackViewAnchoredConstraints = stackView.fillSuperview()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension TitledView where ContentView == WrapperView<Textfield> {
//    @discardableResult
//    func validate() -> Bool {
//        guard contentView.contentView.validate() else {
//            applyErrorState()
//            return false
//        }
//        applyNormalState()
//        return true
//    }
//
//    func applyNormalState() {
//        contentView.contentView.applyNormalState()
//        UIView.animate(withDuration: 0.3) {
//            self.errorView.alpha = 0
//            self.errorView.isHidden = true
//        } completion: { finished in
//            guard finished else { return }
//            self.errorView.isHidden = true
//            self.errorView.alpha = 0
//        }
//    }
//
//    func applyErrorState() {
//        contentView.contentView.applyErrorState()
//        UIView.animate(withDuration: 0.3) {
//            self.errorView.alpha = 1
//            self.errorView.isHidden = false
//        } completion: { finished in
//            guard finished else { return }
//            self.errorView.isHidden = false
//            self.errorView.alpha = 1
//        }
//    }
//}
//
//extension TitledView where ContentView == Textfield {
//    @discardableResult
//    func validate() -> Bool {
//        guard contentView.validate() else {
//            applyErrorState()
//            return false
//        }
//        applyNormalState()
//        return true
//    }
//
//    func applyNormalState() {
//        contentView.applyNormalState()
//        UIView.animate(withDuration: 0.3) {
//            self.errorView.alpha = 0
//            self.errorView.isHidden = true
//        } completion: { finished in
//            guard finished else { return }
//            self.errorView.isHidden = true
//            self.errorView.alpha = 0
//        }
//    }
//
//    func applyErrorState() {
//        contentView.applyErrorState()
//        UIView.animate(withDuration: 0.3) {
//            self.errorView.alpha = 1
//            self.errorView.isHidden = false
//        } completion: { finished in
//            guard finished else { return }
//            self.errorView.isHidden = false
//            self.errorView.alpha = 1
//        }
//    }
//}
//
//extension TitledView where ContentView == InputRangeFilterView {
//    @discardableResult
//    func validate() -> Bool {
//        guard contentView.leftTextField.validate() && contentView.rightTextField.validate() else {
//            applyErrorState()
//            return false
//        }
//        applyNormalState()
//        return true
//    }
//
//    func applyNormalState() {
//        contentView.leftTextField.applyNormalState()
//        contentView.rightTextField.applyNormalState()
//        UIView.animate(withDuration: 0.3) {
//            self.errorView.alpha = 0
//            self.errorView.isHidden = true
//        } completion: { finished in
//            guard finished else { return }
//            self.errorView.isHidden = true
//            self.errorView.alpha = 0
//        }
//    }
//
//    func applyErrorState() {
//        contentView.leftTextField.applyErrorState()
//        contentView.rightTextField.applyErrorState()
//        UIView.animate(withDuration: 0.3) {
//            self.errorView.alpha = 1
//            self.errorView.isHidden = false
//        } completion: { finished in
//            guard finished else { return }
//            self.errorView.isHidden = false
//            self.errorView.alpha = 1
//        }
//    }
//}
#endif
