//
//  Configurable.swift
//  ASSegmentedControl
//
//  Created by Aleksei Smirnov on 26.06.2020.
//  Copyright © 2020 Aleksei Smirnov. All rights reserved.
//

protocol ViewModelProtocol { }

protocol Configurable {

    associatedtype ViewModel: ViewModelProtocol

    func configure(model: ViewModel)

}
