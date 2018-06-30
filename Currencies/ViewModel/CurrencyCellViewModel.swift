//
//  CurrencyCellViewModel.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 30/06/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

protocol CurrencyCellViewModel {

    //is always static
    var currencyCode: String? { get }

    // might be fetched from separated endpoint and appear after cell is displayed
    var currencyTitle: SignalProducer<String?, NoError> { get }
    var symbolicIcon: SignalProducer<String?, NoError> { get }

    var amountText: SignalProducer<String?, NoError> { get }
    var userInputAmount: Signal<String?, NoError>.Observer { get }

}
