//
//  ViewModelDTO.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

@available(*, deprecated, message: "ViewModelDTO is going to be deprecated. Use asPresentableModel instead")
public protocol ViewModelDTO<ViewModel> {
    associatedtype ViewModel
    var viewModel: ViewModel { get }
}

