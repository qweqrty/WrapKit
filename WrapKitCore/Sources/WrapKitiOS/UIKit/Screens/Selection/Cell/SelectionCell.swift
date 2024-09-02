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
            
            if let color = model.circleColor, let color = UIColor(hexaRGB: color, alpha: 1) {
                mainContentView.leadingImageView.layer.cornerRadius = 10
                mainContentView.leadingImageContainerView.isHidden = false
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
