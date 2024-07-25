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

#endif
