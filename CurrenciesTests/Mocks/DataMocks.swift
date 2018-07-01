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
    static let mocked = ExchangeRatesResponse(baseCurrency: "EUR", rates: [.mocked])
}

extension ExchangeRate {
    static let mocked = ExchangeRate(currencyCode: "EUR", rate: 1.0)
}
