//
//  ExchangeRatesResponse.swift
//  Currencies
//
//  Created by Вячеслав Бельтюков on 01/07/2018.
//  Copyright © 2018 Vyacheslav Beltyukov. All rights reserved.
//

import Foundation

struct ExchangeRatesResponse {
    let baseCurrency: String
    let rates: [String: Double]
}

extension ExchangeRatesResponse: Decodable {
    private enum DecodingKey: String, CodingKey {
        case baseCurrency = "base"
        case rates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodingKey.self)
        baseCurrency = try container.decode(String.self, forKey: .baseCurrency)
        rates = try container.decode([String: Double].self, forKey: .rates)
    }
}
