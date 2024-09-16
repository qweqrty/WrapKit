//
//  SelectionCell.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

#if canImport(UIKit)
import UIKit
import Kingfisher
import Combine

public class SelectionCell: TableViewCell<SelectionCellContentView> {
    private var cancellables = Set<AnyCancellable>()

    public var model: SelectionType.SelectionCellPresentableModel? {
        didSet {
            guard let model = model else { return }
            mainContentView.titleLabel.text = model.title
            mainContentView.trailingLabel.text = model.trailingTitle
            model.isSelected
                .publisher
                .sink { [weak self] isSelected in
                    let isSelected = isSelected ?? false
                    let image = isSelected ? model.configuration.selectedImage : model.configuration.notSelectedImage
                    self?.mainContentView.titleLabel.textColor = isSelected ? (model.configuration.selectedTitleColor ?? model.configuration.titleColor) : model.configuration.titleColor
                    self?.mainContentView.trailingImageView.image = image
                    self?.mainContentView.trailingImageContainerView.isHidden = image == nil
                }
                .store(in: &cancellables)
            mainContentView.leadingImageContainerView.isHidden = model.leadingImage == nil
            if let color = model.circleColor, let color = UIColor(hexaRGB: color, alpha: 1) {
                mainContentView.leadingImageView.layer.cornerRadius = 10
                mainContentView.leadingImageView.backgroundColor = color
            }
            switch model.leadingImage {
            case .asset(let image):
                mainContentView.leadingImageView.image = image
            case .url(let urlString):
                mainContentView.leadingImageView.kf.setImage(with: urlString.asUrl)
            default:
                break
            }
            
            mainContentView.lineView.backgroundColor = model.configuration.lineColor
            mainContentView.trailingLabel.textColor = model.configuration.trailingColor
            mainContentView.titleLabel.font = model.configuration.titleFont
            mainContentView.trailingLabel.font = model.configuration.trailingFont
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        mainContentView.trailingImageView.image = nil
        mainContentView.leadingImageView.image = nil
        
        cancellables.removeAll()
    }
}
#endif

//
//  SelectionCellContentView.swift
//  WrapKit
//
//  Created by Daniiar Erkinov on 3/7/24.
//

public class SelectionCellContentView: View {
    public lazy var titleLabel = makeTitleLabel()
    public lazy var trailingLabel = makeTrailingLabel()
    public lazy var trailingStackView = makeTrailingStackView()
    public let leadingImageContainerView = View(isHidden: true)
    public let leadingImageView = ImageView()
    public let trailingImageContainerView = View(isHidden: true)
    public let trailingImageView = ImageView()
    public let leadingStackView = StackView(axis: .horizontal, spacing: 8)
    public let lineView = View(backgroundColor: .gray)
    
    private(set) public var leadingImageViewConstraints: AnchoredConstraints?
    
    public init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
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

extension SelectionCellContentView {
    private func makeTrailingStackView() -> StackView {
        let trailingStackView = StackView(
            axis: .horizontal,
            spacing: 8,
            contentInset: .init(top: 0, left: 0, bottom: 0, right: 4)
        )
        return trailingStackView
    }
    
    private func makeTitleLabel() -> Label {
        let titleLabel = Label(
            font: .systemFont(ofSize: 16),
            textColor: UIColor.black,
            numberOfLines: 0
        )
        return titleLabel
    }
    
    private func makeTrailingLabel() -> Label {
        let trailingLabel = Label(
            font: .systemFont(ofSize: 16),
            textColor: UIColor.gray,
            textAlignment: .center
        )
        return trailingLabel
    }
}

extension SelectionCellContentView {
    func setupSubviews() {
        addSubviews(leadingStackView, trailingStackView, lineView)
        leadingImageContainerView.addSubview(leadingImageView)
        trailingImageContainerView.addSubview(trailingImageView)
        leadingStackView.constrainHeight(56)
        leadingStackView.addArrangedSubviews(
            leadingImageContainerView,
            titleLabel
        )
        trailingStackView.addArrangedSubviews(
            trailingLabel,
            trailingImageContainerView
        )
    }
    
    func setupConstraints() {
        leadingImageViewConstraints = leadingImageView.anchor(
            .centerY(leadingImageContainerView.centerYAnchor),
            .centerX(leadingImageContainerView.centerXAnchor),
            .height(20),
            .width(20)
        )
        trailingImageView.anchor(
            .centerY(trailingImageContainerView.centerYAnchor),
            .centerX(trailingImageContainerView.centerXAnchor)
        )
        trailingImageContainerView.constrainWidth(24)
        leadingImageContainerView.constrainWidth(24)
        
        leadingStackView.anchor(
            .top(topAnchor),
            .leading(leadingAnchor),
            .trailing(trailingStackView.leadingAnchor, constant: 8)
        )
        
        trailingStackView.anchor(
            .centerY(leadingStackView.centerYAnchor),
            .trailing(trailingAnchor)
        )
        
        lineView.anchor(
            .top(leadingStackView.bottomAnchor),
            .leading(leadingAnchor),
            .trailing(trailingAnchor),
            .height(1),
            .bottom(bottomAnchor)
        )
    }
}
