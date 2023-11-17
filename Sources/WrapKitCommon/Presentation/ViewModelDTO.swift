//
//  ViewModelDTO.swift
//  WrapKit
//
//  Created by Stas Lee on 1/8/23.
//

import Foundation

public protocol ViewModelDTO<ViewModel> {
    associatedtype ViewModel
    var viewModel: ViewModel { get }
}

