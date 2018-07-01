//
//  CalculatorMock.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
@testable import Currencies

class CalculatorMock: AmountCalculatorWrapper, AmountProvider {

    private(set) var basePassed: CalculationBase?
    private(set) var dataPassed: ExchangeRatesResponse?

    private(set) var currencyPassed: String?
    var amountToReturn: Double?

    func set(_ base: CalculationBase) {
        basePassed = base
    }

    func set(_ data: ExchangeRatesResponse) {
        dataPassed = data
    }

    func amount(for currency: String) -> Double? {
        currencyPassed = currency
        return amountToReturn
    }
}
