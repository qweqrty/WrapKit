//
//  SearchBar.swift
//
//
//  Created by Daniiar Erkinov on 3/7/24.
//

import Foundation

public protocol SearchBarOutput: AnyObject {
    func display(model: SearchBarPresentableModel?)
    func display(textField: TextInputPresentableModel?)
    func display(leftView: ButtonPresentableModel?)
    func display(rightView: ButtonPresentableModel?)
    func display(placeholder: String?)
    func display(backgroundColor: Color?)
    func display(spacing: CGFloat)
}

public struct SearchBarPresentableModel {
    public let textField: TextInputPresentableModel?
    public let leftView: ButtonPresentableModel?
    public let rightView: ButtonPresentableModel?
    public let placeholder: String?
    public let backgroundColor: Color?
    public let spacing: CGFloat?
    
    public init(
        textField: TextInputPresentableModel? = nil,
        leftView: ButtonPresentableModel? = nil,
        rightView: ButtonPresentableModel? = nil,
        placeholder: String? = nil,
        backgroundColor: Color? = nil,
        spacing: CGFloat? = nil
    ) {
        self.textField = textField
        self.leftView = leftView
        self.rightView = rightView
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.spacing = spacing
    }
}

#if canImport(UIKit)
import UIKit

public class SearchBar: ViewUIKit {
    public let stackView = StackView(axis: .horizontal)
    public let leftView: Button = Button()
    public let textfield: Textfield
    public var rightView: Button = Button()
    
    public init(
        textfield: Textfield,
        spacing: CGFloat = 8
    ) {
        self.textfield = textfield
        self.stackView.spacing = spacing
        
        super.init(frame: .zero)
        
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(leftView)
        stackView.addArrangedSubview(textfield)
        stackView.addArrangedSubview(rightView)
        
        leftView.setContentHuggingPriority(.required, for: .horizontal)
        rightView.setContentHuggingPriority(.required, for: .horizontal)
        
        leftView.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        textfield.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textfield.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        leftView.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightView.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        leftView.isHidden = true
        rightView.isHidden = true
    }
    
    func setupConstraints() {
        stackView.fillSuperview()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchBar: SearchBarOutput {
    public func display(model: SearchBarPresentableModel?) {
        isHidden = model == nil
        guard let model = model else { return }
        
        display(textField: model.textField)
        display(leftView: model.leftView)
        display(rightView: model.rightView)
        display(placeholder: model.placeholder)
        display(backgroundColor: model.backgroundColor)
        if let spacing = model.spacing {
            display(spacing: spacing)
        }
    }
    
    public func display(textField: TextInputPresentableModel?) {
        textfield.display(model: textField)
    }
    
    public func display(leftView: ButtonPresentableModel?) {
        self.leftView.isHidden = leftView == nil
        self.leftView.display(model: leftView)
    }
    
    public func display(rightView: ButtonPresentableModel?) {
        self.rightView.isHidden = rightView == nil
        self.rightView.display(model: rightView)
    }
    
    public func display(placeholder: String?) {
        textfield.display(placeholder: placeholder)
    }
    
    public func display(backgroundColor: Color?) {
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
    }
    
    public func display(spacing: CGFloat) {
        stackView.spacing = spacing
    }
}
#endif
