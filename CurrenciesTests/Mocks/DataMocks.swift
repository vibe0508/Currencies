//
//  DataMocks.swift
//  CurrenciesTests
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation
@testable import Currencies

extension ExchangeRatesResponse {
    static let mocked = ExchangeRatesResponse(baseCurrency: "EUR", rates: [:])
}

extension CalculationBase {
    static let mocked = CalculationBase(currencyCode: "EUR", amount: 8)
}
