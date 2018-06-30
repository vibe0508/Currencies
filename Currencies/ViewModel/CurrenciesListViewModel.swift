//
//  CurrenciesListViewModel.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Result
import ReactiveSwift

protocol CurrenciesListViewModel {
    var reloads: Signal<(), NoError> { get }
    var cells: [CurrencyCellViewModel] { get }
}
