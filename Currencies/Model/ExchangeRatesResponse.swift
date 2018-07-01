//
//  ExchangeRatesResponse.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct ExchangeRatesResponse: Equatable, Decodable {
    let baseCurrency: String
    let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case baseCurrency = "base"
        case rates
    }
}
