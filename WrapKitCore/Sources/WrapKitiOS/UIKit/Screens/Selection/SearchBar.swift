//
//  File.swift
//  
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation
import UIKit

public class SearchBar: View {
    let stackView = StackView(axis: .horizontal)
    let leftView: Button
    let textfield: Textfield
    let rightView: Button
    
    public init(
        leftView: Button = Button(isHidden: true),
        textfield: Textfield,
        rightView: Button = Button(isHidden: true),
        spacing: CGFloat = 8
    ) {
        self.leftView = leftView
        self.textfield = textfield
        self.rightView = rightView
        self.stackView.spacing = spacing
        
        super.init(frame: .zero)

        setupSubviews()
        setupConstraints()
        textfield.backgroundColor = UIColor.white
        textfield.appearance.colors.deselectedBackgroundColor = UIColor.white
    }
    
    func setupSubviews() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(leftView)
        stackView.addArrangedSubview(textfield)
        stackView.addArrangedSubview(rightView)
        
        leftView.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setupConstraints() {
        stackView.fillSuperview()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
